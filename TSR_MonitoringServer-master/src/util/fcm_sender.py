from datetime import datetime, timedelta

import firebase_admin

from firebase_admin import credentials, messaging
from config import FCMConfig


# TODO 싱글톤 문제 있는 것으로 보임, 추후 개선 요망
class FCMSender(object):
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, "_instance"):
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        cls = type(self)
        if not hasattr(cls, "_init"):
            # Firebase 초기화는 1회만 수행
            self._init_fcm()
            self.limit_time = datetime.now()
            self.timeout = FCMConfig.TIMEOUT
            cls._init = True

    def _init_fcm(self):
        try:
            self.cred = credentials.Certificate(FCMConfig.CRED_PATH)
            firebase_admin.initialize_app(self.cred)
            self.open = True
        except:
            self.open = False

    async def send(self, topic: str, title, body):
        # 알림 스팸 방지를 위해 시간 간격 제한
        if self.open and self.limit_time < datetime.now():
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                topic=topic
            )
            messaging.send(message)
            self.limit_time = self.limit_time + timedelta(seconds=self.timeout)
