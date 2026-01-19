import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsr_monitoring_app/util/constants.dart';
import 'package:http/http.dart' as http;

class AnomalyData {
  final DateTime date;
  final double threshold;
  final double score;
  final String name;

  AnomalyData(this.name, this.date, this.threshold, this.score);
}

class AnomalyListView extends StatefulWidget {
  late String machineName;

  AnomalyListView(this.machineName);

  @override
  _AnomalyListView createState() => _AnomalyListView(machineName);
}

class _AnomalyListView extends State<AnomalyListView> {
  late String machineName;
  DateTime curDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List dataList = [];

  _AnomalyListView(this.machineName);

  @override
  void initState() {
    super.initState();
    // 초기 진입 시 기본 기간(최근 30일) 로드
    getDataList();
  }

  String getUrl() {
    // 전체/개별 머신에 따라 API 엔드포인트 선택
    if(machineName == 'all') {
      String url = "$BASE_URL/stat/anomaly/all?start=${DateFormat(REQUEST_DATE_FORMAT).format(_startDate)}&end=${DateFormat(REQUEST_DATE_FORMAT).format(_endDate)}";
      return url;
    } else {
      String url = "$BASE_URL/stat/anomaly?machine=${machineNameMapKorToEng[machineName]!}&start=${DateFormat(REQUEST_DATE_FORMAT).format(_startDate)}&end=${DateFormat(REQUEST_DATE_FORMAT).format(_endDate)}";
      return url;
    }

  }

  void getDataList() async{
    dataList = [];
    final url = Uri.parse(getUrl());
    final res = await http.get(url);
    List list = jsonDecode(res.body) as List;

    // API 응답을 화면 모델로 변환
    for(int i=0; i<list.length; i++){
        dataList.add(new AnomalyData(
          list[i]["name"],
          DateTime.parse(list[i]["time"]),
          list[i]["threshold"],
          list[i]["score"]
        ));
    }
    setState(() {
      dataList = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 20)),
          const Text('이상 이력', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 20)),
                    ),
                    onPressed: () async{
                      final selectedDate = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2023), lastDate: curDate,
                          initialEntryMode: DatePickerEntryMode.calendarOnly);
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                          getDataList();
                        });
                      }
                    },
                    child: Text(DateFormat(REQUEST_DATE_FORMAT).format(_startDate)),
                  ),
                ),
              Text("~"),
              Container(
                child: ElevatedButton(
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 20)),
                  ),
                  onPressed: () async{
                    final selectedDate = await showDatePicker(context: context, initialDate: curDate, firstDate: DateTime(2023), lastDate: curDate,
                        initialEntryMode: DatePickerEntryMode.calendarOnly);
                    if (selectedDate != null) {
                      setState(() {
                        _endDate = selectedDate;
                        getDataList();
                      });
                    }
                  },
                  child: Text(DateFormat(REQUEST_DATE_FORMAT).format(_endDate)),
                ),
              )
          ]),
          _buildAlertLog(),
        ], //children
      );
  }

  Widget _buildAlertLog() {
    // 화면 크기에 따라 리스트 표현 방식 변경
    double curWidth = MediaQuery.of(context).size.width;if (dataList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Align(alignment: Alignment.center, child: Text('이상 이력이 없습니다.')),
            ],
          ),
        ),
      );
    } else if (curWidth > 768) {
      return (Expanded(
        child: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildAlertRow(context, dataList[index]);
          },
        ),
      ));
    } else {
      return (
        Container(
          child: Column(
            children: [
              for(int i=0; i<dataList.length; i++)
                _buildAlertRow(context, dataList[i])
            ],
          ),
        )
      );
    }
  }

  Widget _buildAlertRow(BuildContext context, AnomalyData data) {
    // 전체 조회 시에는 머신명도 함께 표시
    if(machineName == 'all') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child:Text(machineNameMapEngToKor[data.name]!)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('yyyy-MM-dd hh:mm').format(data.date)),
                  Text('이상치 발견 : ${data.score}/${data.threshold}'),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('yyyy-MM-dd hh:mm').format(data.date)),
              Text('이상치 발견 : ${data.score}/${data.threshold}'),
            ],
          ),
        ),
      );
    }
  }
}
