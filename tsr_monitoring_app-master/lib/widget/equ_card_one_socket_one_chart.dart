import 'package:flutter/material.dart';
import 'package:tsr_monitoring_app/util/detail_screen_argument.dart';
import 'package:tsr_monitoring_app/widget/real_time_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class EquCardOSOC extends StatefulWidget {
  late String machineName;
  late String channelName;
  late double curWidth;
  late double curHeight;

  EquCardOSOC(this.machineName, this.channelName, this.curWidth, this.curHeight);

  @override
  State<StatefulWidget> createState() => _EquCardOSOC(machineName, channelName, curWidth, curHeight);
}

class _EquCardOSOC extends State<EquCardOSOC> {
  late String machineName;
  late double curWidth;
  late double curHeight;
  late String channelName;
  _EquCardOSOC(this.machineName, this.channelName, this.curWidth, this.curHeight);
  late LiveChart liveChart;

  @override
  void initState() {
    // 단일 채널용 실시간 차트 생성
    liveChart = LiveChart(channelName, curWidth, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(curWidth >= 768) {
      return GestureDetector(
        onTap: () {
          // 데스크탑: 카드 클릭 시 상세 화면으로 이동
          Navigator.of(context).pushNamed('/$machineName', arguments: DetailScreenArgument(machineName, LiveChart(channelName, curWidth, true)));
        },
        child: Container(
            child: Center(
                child: liveChart
            )
        )
      );
    }
    // 모바일: AppBar + 상세 이동 버튼 제공
    return Scaffold(
      appBar: AppBar(
        shape: Border.all(color: Colors.black),
        centerTitle: true,
        title: Text(machineName, style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/$machineName', arguments: DetailScreenArgument(machineName, LiveChart(channelName, curWidth, true)));
            },
            child: Icon(Icons.more_horiz),
          )
        ],
      ),
      body: Container(
          child: Center(
            child: liveChart
          )
      )
    );
  }
}
