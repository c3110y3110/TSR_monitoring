import abc
import asyncio

from typing import Tuple
from multiprocessing import Process, Pipe

from monitoring_app.machine_server.pipe_serialize import pipe_deserialize, MachineThreadEvent
from .data_handler import MachineEvent
from .machine_thread import MachineThread


class EventHandler(abc.ABC):
    @abc.abstractmethod
    async def __call__(self,
                       event: MachineThreadEvent,
                       machine_name: str,
                       machine_event: MachineEvent,
                       data: any):
        pass


class Runner:
    def __init__(self,
                 host: str,
                 port: int,
                 event_handler: EventHandler):
        self.host = host
        self.port = port
        self.event_handler = event_handler
        self.r_conn, self.w_conn = Pipe(duplex=False)

        self.machine_server_process = None

    def _run_machine_server(self):
        try:
            loop = asyncio.get_event_loop()
            # TCP 서버를 별도 프로세스에서 실행
            server = loop.run_until_complete(
                loop.create_server(
                    protocol_factory=lambda: MachineThread(self.w_conn),
                    host=self.host,
                    port=self.port
                )
            )
            loop.run_until_complete(server.wait_closed())
        except KeyboardInterrupt:
            self.w_conn.close()

    async def pipe_rcv_event(self):
        loop = asyncio.get_event_loop()
        # 별도 프로세스에서 전달된 이벤트를 메인 루프로 전달
        while True:
            pipe_msg: bytes = await loop.run_in_executor(None, self.r_conn.recv)
            if pipe_msg is None:
                break

            machine_thread_event, machine_name, machine_event, data = pipe_deserialize(pipe_msg)
            await self.event_handler(machine_thread_event, machine_name, machine_event, data)

    def run(self):
        loop = asyncio.get_event_loop()
        loop.create_task(self.pipe_rcv_event())

        # TCP 서버 프로세스 실행
        self.machine_server_process = Process(target=self._run_machine_server, daemon=True)
        self.machine_server_process.start()

    def stop(self):
        # 프로세스 종료 및 파이프 정리
        self.r_conn.close()
        self.machine_server_process.join()
