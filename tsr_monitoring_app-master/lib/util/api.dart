import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constants.dart';


Future<List> getMachineList() async {
  // 서버 DB 기준 머신 목록 조회
  String url = "$BASE_URL/stat/machineList";
  http.Response response = await http.get(Uri.parse(url));
  return jsonDecode(response.body)['machine_list'] as List;
}

Future<List> getAVGData(String url) async {
  // 통계 API 응답에서 평균 목록 반환
  http.Response response = await http.get(Uri.parse(url));
  return jsonDecode(response.body)['avg'] as List;
}
