import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tsr_monitoring_app/util/constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:tsr_monitoring_app/util/unique_shared_preference.dart';

class AvgDataChart extends StatefulWidget {
  late String machineName;

  AvgDataChart(this.machineName);

  @override
  State<AvgDataChart> createState() => _AvgDataChart(machineName);

}

class _AvgDataChart extends State<AvgDataChart> {
  late String machineName;
  List<_dateAvgData> data = [];
  DateTime curDate = DateTime.now();
  DateTime today = DateTime.now();
  late String curUnit;

  _AvgDataChart(this.machineName);

  late List channelList;

  @override
  void initState() {
    super.initState();
    // 마지막 선택 단위(시/일/월/년) 복원
    curUnit = UniqueSharedPreference.getString("selectedUnit");
    channelList = getChanelNameList(machineName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면 의존성 변경 시 통계 데이터를 갱신
    getDataList(getIsOneSocket(machineName));
  }

  void getDataList(bool isOneSocket) async {
    // 머신의 소켓 구조에 따라 조회 방식 분기
    String engCurUnit = unitMapKorToEng[curUnit]!;
    DateTime startDate = getStartDate(engCurUnit, curDate);
    if (isOneSocket) {
      getDataList1(engCurUnit, startDate);
    } else {
      getDataList2(engCurUnit, startDate);
    }
  }

  void getDataList1(String engCurUnit, DateTime startDate) async {
    // 단일 소켓(두 채널) 구조 처리
    data = [];
    final url = Uri.parse(BASE_URL + "/stat/" + engCurUnit + "?machine=" +
        machineNameMapKorToEng[machineName]! +
        "&start=" + DateFormat(REQUEST_DATE_FORMAT).format(startDate) +
        "&end=" + DateFormat(REQUEST_DATE_FORMAT).format(curDate));
    final res = await http.get(url);
    List temp = jsonDecode(res.body) as List;
    if (temp.length / 2 <= 1) {
      setState(() {
        data = [];
      });
      return;
    }
    List channel1 = [];
    List channel2 = [];
    for (int i = 0; i < temp.length; i++) {
      if (temp[i]['name'] == channelList[0] + "_" + engCurUnit + "_avg") {
        channel1.add(temp[i]);
      } else {
        channel2.add(temp[i]);
      }
    }
    for (int i = 0; i < channel1.length; i++) {
      if (channel2.length == 0) {
        data.add(_dateAvgData(
            DateTime.parse(channel1[i]['time']), [channel1[i]['data']]));
      } else {
        data.add(_dateAvgData(DateTime.parse(channel1[i]['time']),
            [channel1[i]['data'], channel2[i]['data']]));
      }
    }
    setState(() {
      data = data;
    });
  }

  void getDataList2(String engCurUnit, DateTime startDate) async {
    // 두 소켓(채널 분리) 구조 처리
    data = [];
    List timeList = [];
    List channel1 = [];
    List channel2 = [];
    for (int i = 0; i < channelList.length; i++) {
      final url = Uri.parse(BASE_URL + "/stat/" + engCurUnit + "?machine=" +
          machineNameMapKorToEng[machineName]! +
          "&start=" + DateFormat(REQUEST_DATE_FORMAT).format(startDate) +
          "&end=" + DateFormat(REQUEST_DATE_FORMAT).format(curDate));
      final res = await http.get(url);
      List temp = jsonDecode(res.body) as List;
      if (temp.length / 2 <= 1) {
        setState(() {
          data = [];
        });
        return;
      }
      if (i == 0) {
        for (int j = 0; j < temp.length; j++) {
          timeList.add(temp[j]['time']);
          channel1.add(temp[j]['data']);
        }
      } else {
        for (int j = 0; j < temp.length; j++) {
          channel2.add(temp[j]['data']);
        }
      }
    }
    for (int i = 0; i < timeList.length; i++) {
      data.add(_dateAvgData(DateTime.parse(timeList[i]),
          [channel1[i], channel2[i]]));
    }
    setState(() {
      data = data;
    });
  }

  DateTime getStartDate(String engCurUnit, DateTime curDate) {
    // 통계 단위에 따른 조회 시작일 계산
    if(engCurUnit == "hour") {
      return curDate.subtract(Duration(days: 2));
    } else if(engCurUnit == "day") {
      return curDate.subtract(Duration(days: 30));
    } else if(engCurUnit == "month") {
      return curDate.subtract(Duration(days: 365));
    } else {
      return curDate.subtract(Duration(days: 3650));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('평균 조회',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Expanded(child: _buildChart()),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for(int i = 0; i< avgList.length; i++)
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                              TextStyle(fontSize: 15)),
                          backgroundColor: _setButtonColor(curUnit, avgList[i]),
                        ),
                        onPressed: () async {
                          setState(() {
                            UniqueSharedPreference.setString("selectedUnit", avgList[i]);
                            curUnit = avgList[i];
                            didChangeDependencies();
                          });
                        },
                        child: Text(avgList[i])
                    ),
                  )
              ],
            ),
          )
        ]
      )
    );
  }

  Widget _buildChart() {
    // 데이터 유무에 따라 차트/빈 상태 분기
    if (data.isEmpty) {
      return const Text("데이터가 없습니다.");
    } else {
      return SfCartesianChart(
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: DateTimeCategoryAxis(dateFormat: (getDateFormat(curUnit))),
        primaryYAxis: NumericAxis(
            //interval: 0.1,
            decimalPlaces: 6
        ),
        series: <CartesianSeries<_dateAvgData, DateTime>>[
          for (int i = 0; i < channelList.length; i++)
            LineSeries<_dateAvgData, DateTime>(
              trendlines: <Trendline>[
                  Trendline(
                    type: TrendlineType.linear,
                    color: trendlineColor(i),
                    name: channelNameMap[channelList[i]]! + " 추세선",
              )],
              name: channelNameMap[channelList[i]]!,
              dataSource: data,
              xValueMapper: (_dateAvgData data, _) => data.date,
              yValueMapper: (_dateAvgData data, _) => data.data[i],
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
        ]
      );
    }
  }

  @override
  void dispose() {
    // 화면 종료 시 데이터 정리
    data = [];
    super.dispose();
  }
}

trendlineColor(int i) {
  // 채널별 추세선 색상
  if(i == 0) {
    return Colors.white;
  } else if(i == 1) {
    return Colors.purpleAccent;
  } else if(i == 2) {
    return Colors.green;
  } else {
    return Colors.yellow;
  }
}

getDateFormat(String curUnit) {
  // 단위별 X축 포맷
  if(curUnit == "시") {
    return DateFormat("yyyy-MM-dd HH:mm");
  } else if(curUnit == "일") {
    return DateFormat("yyyy-MM-dd");
  } else if(curUnit == "월") {
    return DateFormat("yyyy-MM");
  } else {
    return DateFormat("yyyy");
  }
}

_setButtonColor(String curUnit, String selectedUnit) {
  // 선택된 단위 버튼 강조
  if(curUnit == selectedUnit) {
    return MaterialStateProperty.all<Color>(Colors.blue);
  } else {
    return MaterialStateProperty.all<Color>(Color(0xFF3E3E3E));
  }
}

class _dateAvgData {
  final DateTime date;
  final List<double> data;

  _dateAvgData(this.date, this.data);

  void addAvg(double avg) {
    data.add(avg);
  }
}
