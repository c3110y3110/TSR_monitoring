import os
import sys

from app import App

if sys.stderr is None:
    # 배포 환경에서 콘솔이 없을 때 오류 출력이 죽는 것을 방지
    sys.stderr = open(os.devnull, 'w')
if sys.stdout is None:
    # 배포 환경에서 표준 출력이 없을 때 예외 방지
    sys.stdout = open(os.devnull, 'w')

if __name__ == '__main__':
    # GUI 앱 시작 지점
    app = App()
    app.run()
