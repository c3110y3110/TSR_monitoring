const Map<String, String> machineNameMapKorToEng = {"쇼트블라스트": "1R_bearing_5", "인산염피막기": "AROPump", "비형상도포기": "Dispenser",
  "진공펌프": "VacuumPump", "진공펌프1": "VacuumPump1","진공펌프2": "VacuumPump2"};
const Map<String, String> machineNameMapEngToKor = {"1R_bearing_5": "쇼트블라스트", "ShotBlast": "쇼트블라스트", "AROPump": "인산염피막기", "Dispenser": "비형상도포기",
  "VacuumPump": "진공펌프", "VacuumPump1": "진공펌프1", "VacuumPump2": "진공펌프2"};
const Map<String, String> channelNameMap = {"Motor_vib1": "쇼트블라스트1", "Motor_vib2": "쇼트블라스트2", "shot_blast_vib1": "쇼트블라스트1", "shot_blast_vib2": "쇼트블라스트2", "aro_vib1": "입출부",
  "aro_vib2": "토출부", "dispenser_vib": "비형상도포기", "pump1_vib": "진공펌프1", "pump2_vib": "진공펌프2"};
const Map<String, String> unitMapKorToEng = {"시": "hour", "일": "day", "월": "month", "년": "year"};
const List machineList = ["쇼트블라스트", "인산염피막기", "비형상도포기", "진공펌프"];
const List avgList = ["시", "일", "월", "년"];
const SHOT_BLAST = "쇼트블라스트";
const ARO_PUMP = "인산염피막기";
const DISPENSING_MACHINE = "비형상도포기";
const VACUUM_PUMP = "진공펌프";
//const BASE_URL = "http://14.46.226.218:8080";
const BASE_URL = "http://100.88.22.119:8445";
const REQUEST_DATE_FORMAT = "yyyy-MM-dd";

const ANOMALY_EVENT = "anomaly";
const INITIALIZE_EVENT = "initialize";
const UPDATE_EVENT = "update";
const SCORE = "score";
const THRESHOLD = "threshold";

//******* REQUEST URL *******//
const SHOT_BLAST_URL = "/sio/1R_bearing_5";
const ARO_PUMP_URL = "/sio/AROPump";
const DISPENSING_MACHINE_URL = "/sio/Dispenser";
const VACUUM_PUMP1_URL = "/sio/VacuumPump1";
const VACUUM_PUMP2_URL = "/sio/VacuumPump2";


//******* CHANNEL NAME *******//
const SHOT_BLAST1_CHANNEL_NAME = 'Motor_vib1';
const SHOT_BLAST2_CHANNEL_NAME = 'Motor_vib2';

const ARO_PUMP1_CHANNEL_NAME = "aro_vib1";
const ARO_PUMP2_CHANNEL_NAME = "aro_vib2";

const DISPENSING_MACHINE_CHANNEL_NAME = 'dispenser_vib';

const VACUUM_PUMP1_CHANNEL_NAME = "pump1_vib";
const VACUUM_PUMP2_CHANNEL_NAME = "pump2_vib";


//******* CHANNEL NAME ARRAY *******//
const SHOT_BLAST_CHANNEL_NAME_ARRAY = [SHOT_BLAST1_CHANNEL_NAME, SHOT_BLAST2_CHANNEL_NAME];
const ARO_PUMP_CHANNEL_NAME_ARRAY = [ARO_PUMP1_CHANNEL_NAME, ARO_PUMP2_CHANNEL_NAME];
const DISPENSING_MACHINE_CHANNEL_NAME_ARRAY = [DISPENSING_MACHINE_CHANNEL_NAME];
const VACUUM_PUMP_CHANNEL_NAME_ARRAY = [VACUUM_PUMP1_CHANNEL_NAME, VACUUM_PUMP2_CHANNEL_NAME];

const Map<String, String> sioUrlMap = {SHOT_BLAST1_CHANNEL_NAME: SHOT_BLAST_URL, SHOT_BLAST2_CHANNEL_NAME: SHOT_BLAST_URL,
  ARO_PUMP1_CHANNEL_NAME: ARO_PUMP_URL, ARO_PUMP2_CHANNEL_NAME: ARO_PUMP_URL, DISPENSING_MACHINE_CHANNEL_NAME: DISPENSING_MACHINE_URL,
  VACUUM_PUMP1_CHANNEL_NAME: VACUUM_PUMP1_URL, VACUUM_PUMP2_CHANNEL_NAME: VACUUM_PUMP2_URL};


class Machine {
  final String name;
  final String url;
  final List channelName;
  final int type;

  Machine(this.name, this.url, this.channelName, this.type);
}

List getChanelNameList(String name) {
  switch(name) {
    case "쇼트블라스트":
      return SHOT_BLAST_CHANNEL_NAME_ARRAY;
    case "인산염피막기":
      return ARO_PUMP_CHANNEL_NAME_ARRAY;
    case "비형상도포기":
      return DISPENSING_MACHINE_CHANNEL_NAME_ARRAY;
    case "진공펌프":
      return VACUUM_PUMP_CHANNEL_NAME_ARRAY;
    default:
      return [];
  }
}

bool getIsOneSocket(String name) {
  switch(name) {
    case "쇼트블라스트":
      return true;
    case "인산염피막기":
      return true;
    case "비형상도포기":
      return true;
    case "진공펌프":
      return false;
    default:
      return false;
  }
}
