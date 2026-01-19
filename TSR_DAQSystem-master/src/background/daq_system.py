import asyncio
from asyncio import Event
from typing import List, Dict
from PySide6.QtCore import QThread, Signal

from lib.daq import DAQ
from lib.daq.ni_device import NIDevice
from lib.daq.ni_device.channel_initializers import VibChannelInitializer, TempChannelInitializer

from config import NIDeviceConfig, NIDeviceType, DAQSystemConfig, MachineConfig
from .data_saver import DataSaver
from .data_sender import DataSender
from .machine import Machine, EventHandler, MachineEvent


class DAQSystem(QThread):
    event_signal = Signal(tuple)

    def __init__(self, conf: DAQSystemConfig):
        super().__init__()
        self._conf = conf
        self._event = Event()

        # 센서 타입 매핑과 장비/머신 인스턴스 구성
        self.sensor_types: Dict[str, NIDeviceType] = {}
        self._ni_devices: List[NIDevice] = [self.create_ni_device(ni_conf) for ni_conf in self._conf.NI_DEVICES]
        self._machines: List[Machine] = [self.create_machine(m_conf) for m_conf in self._conf.MACHINES]

        self._daq: DAQ = DAQ(ni_devices=self._ni_devices)
        for machine in self._machines:
            self._daq.register_data_handler(machine)

        self._loop = asyncio.get_event_loop()
        # UI 업데이트용 시그널 브리지
        self._event_sender: EventSender = EventSender(self.event_signal)

    def create_ni_device(self, d_conf: NIDeviceConfig) -> NIDevice:
        if d_conf.TYPE == NIDeviceType.VIB:
            channel_initializer = VibChannelInitializer()
        elif d_conf.TYPE == NIDeviceType.TEMP:
            channel_initializer = TempChannelInitializer()
        else:
            raise RuntimeError('invalid device type')

        # NI-DAQ 장치 생성 및 센서 등록
        ni_device = NIDevice(name=d_conf.NAME,
                             rate=d_conf.RATE,
                             channel_initializer=channel_initializer)

        for s_conf in d_conf.SENSORS:
            self.sensor_types[s_conf.NAME] = d_conf.TYPE
            ni_device.add_sensor(sensor_name=s_conf.NAME,
                                 channel=s_conf.CHANNEL,
                                 options=s_conf.OPTIONS)

        return ni_device

    def create_machine(self, m_conf: MachineConfig) -> Machine:
        machine = Machine(name=m_conf.NAME,
                          sensors=m_conf.SENSORS,
                          fault_detectable=m_conf.FAULT_DETECTABLE,
                          fault_threshold=m_conf.FAULT_THRESHOLD)

        # 데이터 전송/저장 모드에 따라 핸들러 등록
        send_conf = m_conf.DATA_SEND_MODE
        if send_conf.ACTIVATION:
            cur_sensor_types = {sensor: s_type for sensor, s_type in self.sensor_types.items() if sensor in m_conf.SENSORS}
            data_sender = DataSender(name=m_conf.NAME,
                                     host=send_conf.HOST,
                                     port=send_conf.PORT,
                                     timeout=send_conf.TIMEOUT,
                                     sensor_types=cur_sensor_types)
            machine.register_handler(data_sender)

        save_conf = m_conf.DATA_SAVE_MODE
        if save_conf.ACTIVATION:
            data_saver = DataSaver(name=m_conf.NAME,
                                   sensors=m_conf.SENSORS,
                                   external_path=save_conf.PATH)
            machine.register_handler(data_saver)

        return machine

    def get_machines(self):
        return self._machines

    def get_conf(self):
        return self._conf

    def run(self) -> None:
        # DAQ 읽기 루프 시작 후 종료 이벤트 대기
        self._daq.read_start()
        self._loop.run_until_complete(self._event.wait())

    def set_monitoring_target(self, machine: Machine):
        # GUI가 관측할 대상 머신 변경
        self._event_sender.set_machine(machine)

    def stop(self):
        # 스레드 종료 플래그 설정 및 정리
        self._event.set()
        self.quit()
        self.wait(3000)


class EventSender(EventHandler):
    def __init__(self, signal):
        self._signal = signal
        self._machine: Machine = None

    def set_machine(self, machine: Machine):
        # 관측 대상 변경 시 핸들러 재등록
        if self._machine is not None:
            self._machine.remove_handler(self)
        self._machine = machine
        self._machine.register_handler(self)

    async def event_handle(self, event: MachineEvent, data: Dict) -> None:
        # GUI 스레드로 이벤트 전달
        zipped_data = (event, data)
        self._signal.emit(zipped_data)
