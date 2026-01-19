import pickle
from typing import Dict
from os import path, makedirs

from .configs import DAQSystemConfig
from .paths import CONFIG_PATH


class ConfigLoader:
    @staticmethod
    def load_conf() -> DAQSystemConfig:
        if not path.isfile(CONFIG_PATH):
            dir_path = path.dirname(CONFIG_PATH)
            makedirs(dir_path, exist_ok=True)
            open(CONFIG_PATH, 'wb').close()

        with open(CONFIG_PATH, 'rb') as conf_file:
            try:
                # pickle로 저장된 설정 로드
                conf = pickle.load(conf_file)
            except:
                conf = None
            if not is_valid_conf(conf):
                # 설정이 없거나 손상된 경우 기본값
                conf = DAQSystemConfig([], [])

        return conf

    @staticmethod
    def save_conf(conf: DAQSystemConfig) -> None:
        if not path.isfile(CONFIG_PATH):
            dir_path = path.dirname(CONFIG_PATH)
            makedirs(dir_path, exist_ok=True)
            open(CONFIG_PATH, 'wb').close()

        with open(CONFIG_PATH, 'wb') as conf_file:
            # GUI에서 저장한 설정을 그대로 직렬화
            pickle.dump(conf, conf_file)


def is_valid_conf(conf: Dict) -> bool:
    if conf is None:
        return False
    return True
