import asyncio
import uvicorn
import logging
import socketio

from uvicorn import Config, Server
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from util import logger
from config import ServerConfig, LoggerConfig

from .routers import get_sio_router, stat_router
from .machine_server import Runner, MachineThreadEvent, MachineEvent, EventHandler
from .custom_namespace import CustomNamespace


class MachineHandler(EventHandler):
    def __init__(self, sio, machine_logger, sio_logger):
        self.sio = sio
        self.machine_logger = machine_logger
        self.sio_logger = sio_logger

    async def __call__(self,
                       event: MachineThreadEvent,
                       machine_name: str,
                       machine_event: MachineEvent,
                       data: any):
        # TCP 수신 이벤트를 Socket.IO 네임스페이스로 브릿지
        if machine_name is not None:
            namespace = f'{ServerConfig.SIO_PREFIX}/{machine_name}'

            if event == MachineThreadEvent.DATA_UPDATE:
                await self.sio.namespace_handlers[namespace].send_machine_event(
                    machine_event=machine_event,
                    data=data
                )

            elif event == MachineThreadEvent.CONNECT:
                # 머신 접속 시 네임스페이스 동적 등록
                machine_namespace = CustomNamespace(
                    namespace=namespace,
                    logger=self.sio_logger
                )
                self.sio.register_namespace(namespace_handler=machine_namespace)
                self.machine_logger.info(f'{machine_name} connected')

            elif event == MachineThreadEvent.DISCONNECT:
                # 머신 연결 해제 시 네임스페이스 제거
                del self.sio.namespace_handlers[namespace]
                self.machine_logger.info(f'{machine_name} disconnected')


class MonitoringApp:
    def __init__(self):
        self.host = ServerConfig.HOST
        self.port = ServerConfig.PORT
        self.app = FastAPI()
        # 웹/앱 클라이언트를 위한 CORS 설정
        self.app.add_middleware(CORSMiddleware,
                                allow_origins=ServerConfig.CORS_ORIGINS,
                                allow_credentials=True,
                                allow_methods=['*'],
                                allow_headers=['*'],)
        self.sio = socketio.AsyncServer(async_mode='asgi',
                                        cors_allowed_origins='*',)
        self.loop = asyncio.get_event_loop()

        self._set_logger()
        self._configure_event()
        self._configure_routes()

        # DAQ TCP 수신 서버 프로세스
        self.machine_server_runner = Runner(host=self.host,
                                            port=ServerConfig.TCP_PORT,
                                            event_handler=MachineHandler(self.sio, self.machine_logger, self.sio_logger))

    def _server_load(self) -> Server:
        uvicorn_log_config = uvicorn.config.LOGGING_CONFIG
        uvicorn_log_config['formatters']['access']['fmt'] = LoggerConfig.FORMAT
        uvicorn_log_config["formatters"]["default"]["fmt"] = LoggerConfig.FORMAT

        # FastAPI + Socket.IO ASGI 결합
        socket_app = socketio.ASGIApp(self.sio, self.app)
        config = Config(app=socket_app,
                        host=self.host,
                        port=self.port,
                        loop=self.loop)
        return Server(config)

    def _set_logger(self):
        # 머신/소켓 로그 분리
        self.machine_logger = logger.get_logger(name='machine', log_level=logging.INFO, save_path=LoggerConfig.PATH)
        self.sio_logger = logger.get_logger(name='sio.access', log_level=logging.INFO, save_path=LoggerConfig.PATH)

    def _configure_event(self):
        @self.app.on_event("startup")
        async def startup_event():
            # uvicorn 로그를 파일로 수집
            uvicorn_error = logging.getLogger('uvicorn.error')
            uvicorn_access = logging.getLogger('uvicorn.access')
            uvicorn_error.setLevel(logging.ERROR)

            formatter = logging.Formatter(LoggerConfig.FORMAT)
            uvicorn_error.addHandler(
                logger.get_file_handler(
                    path=LoggerConfig.PATH,
                    name=uvicorn_error.name,
                    formatter=formatter
                )
            )
            uvicorn_access.addHandler(
                logger.get_file_handler(
                    path=LoggerConfig.PATH,
                    name=uvicorn_access.name,
                    formatter=formatter
                )
            )

    def _configure_routes(self):
        # REST 라우터 등록
        sio_router = get_sio_router(self.sio)

        self.app.include_router(sio_router)
        self.app.include_router(stat_router)

    def run(self):
        try:
            self.loop = asyncio.get_event_loop()
            web_server = self._server_load()

            # TCP 서버 프로세스 실행 후 웹 서버 구동
            self.machine_server_runner.run()
            self.loop.run_until_complete(web_server.serve())

            self.machine_server_runner.stop()
        except Exception as e:
            print(f"An error occurred: {e}")
