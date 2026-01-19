import asyncio
from typing import Dict
from scipy import signal

from config import NIDeviceType
from .machine_client import MachineClient
from .machine import EventHandler
from .machine.machine_event import MachineEvent

MAXIMUM_RATE: int = 30


class DataSender(EventHandler):
    def __init__(self,
                 name: str,
                 host: str,
                 port: int,
                 timeout: int,
                 sensor_types: Dict[str, NIDeviceType]):
        self.name = name
        self.host = host
        self.port = port
        self.timeout = timeout
        self.sensor_types = sensor_types

        self.transport = None
        self.protocol = None
        self.conn = None

        # 서버와의 연결을 백그라운드로 유지
        self._loop = asyncio.get_event_loop()
        self._loop.create_task(self.permanent_connection())

    async def permanent_connection(self) -> None:
        # 연결이 끊기면 재시도
        while True:
            try:
                self.conn = self._loop.create_connection(protocol_factory=lambda: MachineClient(self.name),
                                                         host=self.host,
                                                         port=self.port)
                self.transport, self.protocol = await self.conn
                await self.protocol.wait()
            except Exception:
                await asyncio.sleep(self.timeout)

    async def event_handle(self, event: MachineEvent, data: Dict) -> None:
        # 서버 연결이 있을 때만 데이터 전송
        if not self.is_closing():
            event, data = self.convert(event, data)
            self.protocol.send_data(event=event, data=data)

    def is_closing(self) -> bool:
        return self.protocol is None or self.protocol.is_closing()

    def convert(self, event: MachineEvent, data: Dict):
        if event is MachineEvent.DataUpdate:
            # 전송량을 줄이기 위해 일정 길이로 리샘플링
            data = {
                sensor: {
                    'type': self.sensor_types[sensor].name,
                    'data': signal.resample(s_data, MAXIMUM_RATE).tolist() if MAXIMUM_RATE < len(s_data) else s_data
                } for sensor, s_data in data.items()
            }
        elif event is MachineEvent.FaultDetect:
            """
            data = {
                'score': int,
                'threshold': int
            }
            """
            pass
        else:
            raise RuntimeError('Undefined Event')

        return event.name, data
