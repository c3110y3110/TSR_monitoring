import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constants.dart';


Future<List> getMachineList() async {
  String url = "$BASE_URL/stat/machineList";
  http.Response response = await http.get(Uri.parse(url));
  return jsonDecode(response.body)['machine_list'] as List;
}

Future<List> getAVGData(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  return jsonDecode(response.body)['avg'] as List;
}
