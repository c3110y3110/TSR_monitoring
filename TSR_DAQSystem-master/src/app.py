from PySide6.QtGui import QIcon
from PySide6.QtWidgets import QApplication

from background import DAQSystem
from config import ConfigLoader
from config.paths import ICON_IMG
from gui.main_window import MainWindow
from gui.setting.setting_widget import QSettingWidget
from gui.startup import QStartupWidget
from gui.tray_icon import TrayIcon
from gui.running.daq_system_monitor import QDAQSystemMonitor


class App:
    def __init__(self):
        # Qt 애플리케이션 초기화 (트레이 아이콘 사용을 위해 창 종료 시 앱 유지)
        self._app = QApplication([])
        self._app.setQuitOnLastWindowClosed(False)

        self._bg_system: DAQSystem = None

        # 메인 윈도우 생성 후 시작 화면 배치
        self._main_window = MainWindow(None)
        self.startup_step()

        # 트레이 아이콘 및 종료 훅 설정
        icon = QIcon(ICON_IMG)
        self._tray = TrayIcon(main_window=self._main_window, icon=icon)
        self._tray.set_exit_event(self.exit_event)

    def startup_step(self) -> None:
        # 시작 화면: 설정 또는 실행 선택
        startup_widget = QStartupWidget(set_step=self.setting_step,
                                        run_step=self.running_step)
        self._main_window.setCentralWidget(startup_widget)

    def setting_step(self) -> None:
        # 설정 화면: 저장 완료 시 다시 시작 화면으로 복귀
        setting_widget = QSettingWidget()
        setting_widget.setting_end.connect(self.startup_step)
        self._main_window.setCentralWidget(setting_widget)

    def running_step(self) -> None:
        # 설정 로드 후 DAQ 백그라운드 스레드를 구동
        conf = ConfigLoader.load_conf()
        self._bg_system = DAQSystem(conf)
        self._bg_system.start()

        # 실시간 모니터 화면으로 전환
        machine_monitor = QDAQSystemMonitor(self._bg_system)
        self._main_window.setCentralWidget(machine_monitor)

    def run(self) -> None:
        self._app.exec()

    def exit_event(self) -> None:
        # 종료 시 백그라운드 스레드 정리
        if self._bg_system is not None:
            self._bg_system.stop()
        self._app.exit()
