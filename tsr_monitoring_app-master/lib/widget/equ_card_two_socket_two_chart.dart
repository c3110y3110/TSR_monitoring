import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tsr_monitoring_app/widget/real_time_chart.dart';

import '../util/detail_screen_argument.dart';


class EquCardTSTC extends StatefulWidget {
  late String machineName;
  late String channelName1;
  late String channelName2;
  late double curWidth;
  late double curHeight;
  EquCardTSTC(this.machineName, this.channelName1, this.channelName2, this.curWidth, this.curHeight);

  @override
  State<StatefulWidget> createState() => _EquCardTSTC(machineName, channelName1, channelName2, curWidth, curHeight);
}

class _EquCardTSTC extends State<EquCardTSTC> {
  late String machineName;
  late String channelName1;
  late String channelName2;
  late double curWidth;
  late double curHeight;
  _EquCardTSTC(this.machineName, this.channelName1, this.channelName2, this.curWidth, this.curHeight);
  late Widget body;

  Widget _makeBody(bool isDetail) {
    // 상세 화면에서는 모바일 세로 배치, 기본은 가로 배치
    if((curWidth < 768) && isDetail) {
      return Container(
          height: curHeight * 0.8,
          child: Column(
            children: [
              Expanded(child: LiveChart(channelName1, curWidth, isDetail)),
              Expanded(child: LiveChart(channelName2, curWidth, isDetail)),
            ],
        )
      );
    }
    return Container(
      child: Row(
        children: [
          Expanded(child: LiveChart(channelName1, curWidth, isDetail)),
          Expanded(child: LiveChart(channelName2, curWidth, isDetail))
        ],
      ),
    );
  }

  @override
  void initState() {
    // 초기 렌더용 차트 묶음 생성
    body = _makeBody(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(curWidth >= 768) {
      return GestureDetector(
        onTap: () {
          // 데스크탑: 클릭 시 상세 화면으로 이동
          Navigator.of(context).pushNamed('/$machineName', arguments: DetailScreenArgument(machineName, _makeBody(true)));
        },
        child: Container(
            child: Center(
                child: body
            )
        )
      );
    }
    // 모바일: AppBar에서 상세 이동
    return Scaffold(
        appBar: AppBar(
          shape: Border.all(color: Colors.black),
          centerTitle: true,
          title: Text(machineName, style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/$machineName', arguments: DetailScreenArgument(machineName, _makeBody(true)));
              },
              child: Icon(Icons.more_horiz),
            )
          ],
        ),
        body: Container(
            child: Center(
              child: body
            )
        )
    );
  }
}
