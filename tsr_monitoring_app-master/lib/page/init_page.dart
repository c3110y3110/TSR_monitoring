import 'package:flutter/material.dart';
import 'package:tsr_monitoring_app/widget/equ_card_one_socket_one_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../util/constants.dart';
import '../util/route_observer.dart';
import '../util/unique_shared_preference.dart';
import '../widget/anomaly_list_view.dart';
import '../widget/equ_card_one_socket_two_chart.dart';
import '../widget/equ_card_two_socket_two_chart.dart';


class InitPage extends StatefulWidget {
  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지 복귀 시 설정 변경 반영을 위해 라우트 관찰
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // 설정 화면에서 돌아오면 목록 갱신
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // 라우트 옵저버 해제
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 및 표시 대상 머신 목록 계산
    double curWidth = MediaQuery.of(context).size.width;
    double curHeight = MediaQuery.of(context).size.height;
    final visibleMachines = _getVisibleMachineList();
    return _body(curWidth, curHeight, visibleMachines);
  }
}

List<Widget> _buildMachineCards(double curWidth, double curHeight, List<String> machineList) {
  // 선택된 머신 목록을 카드 위젯으로 변환
  final List<Widget> cards = [];
  for (final machineName in machineList) {
    final Widget? card = _buildMachineCard(machineName, curWidth, curHeight);
    if (card != null) {
      cards.add(card);
    }
  }
  return cards;
}

Widget? _buildMachineCard(String machineName, double curWidth, double curHeight) {
  // 머신 타입에 따라 카드 구성(채널/소켓 구조 반영)
  switch (machineName) {
    case SHOT_BLAST:
      return EquCardOSTC(machineName, SHOT_BLAST1_CHANNEL_NAME, SHOT_BLAST2_CHANNEL_NAME, curWidth, curHeight);
    case ARO_PUMP:
      return EquCardOSTC(machineName, ARO_PUMP1_CHANNEL_NAME, ARO_PUMP2_CHANNEL_NAME, curWidth, curHeight);
    case DISPENSING_MACHINE:
      return EquCardOSOC(machineName, DISPENSING_MACHINE_CHANNEL_NAME, curWidth, curHeight);
    case VACUUM_PUMP:
      return EquCardTSTC(machineName, VACUUM_PUMP1_CHANNEL_NAME, VACUUM_PUMP2_CHANNEL_NAME, curWidth, curHeight);
    default:
      return null;
  }
}


List<String> _getVisibleMachineList() {
  // 사용자 설정에 따라 홈 화면 노출 머신 결정
  final List<String> allMachines = List<String>.from(machineList);
  final saved = UniqueSharedPreference.getStringList('selectedMachines', allMachines);
  if (saved.isEmpty) {
    return allMachines;
  }
  final selectedSet = saved.toSet();
  final List<String> ordered = [];
  for (final machineName in allMachines) {
    if (selectedSet.contains(machineName)) {
      ordered.add(machineName);
    }
  }
  return ordered;
}


Widget _body(double curWidth, double curHeight, List<String> machineList) {
  if(curWidth >= 768) {
    // 데스크탑: 좌측 요약 + 중앙 카드 + 우측 이상 리스트
    final machineCards = _buildMachineCards(curWidth, curHeight, machineList);
    final machineContent = machineCards.isEmpty
        ? [Center(child: Text("표시할 장비가 없습니다."))]
        : machineCards;
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: curWidth * 0.14,
            child: Column(
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/TSR_image.jpg'),
                    Container(
                      color: Color(0xFF3E3E3E),
                      child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                          },
                          border: TableBorder.all(color: Colors.black),
                          children: const [
                            TableRow(
                                children: [
                                  Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Center(child: Text('회사명'))),
                                  Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Center(child: Text('티에스알'))),
                                ]
                            ),
                            TableRow(
                                children: [
                                  Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Center(child: Text('업종'))),
                                  Center(child: Text('산업용 그 외 비경화\n 고무제품 제조업',))
                                ]
                            ),
                          ]
                      )
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
              ],
            ),
          ),
          Container(
            width: curWidth * 0.6,
            child: Column(
              children: machineContent
            )
          ),
          Container(
            width: curWidth * 0.2,
            height: curHeight * 0.9,
            child: AnomalyListView("all")
          ),
        ],
      )
    );
    /*return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: itemW / itemH,
      children: <Widget> [
        EquCardOSTC(machineList[0], createSocket(BASE_URL+SHOT_BLAST_URL), SHOT_BLAST1_CHANNEL_NAME, SHOT_BLAST2_CHANNEL_NAME, curWidth, curHeight),
        EquCardOSTC(machineList[1], createSocket(BASE_URL+ARO_PUMP_URL), ARO_PUMP1_CHANNEL_NAME, ARO_PUMP2_CHANNEL_NAME, curWidth, curHeight),
        EquCardOSOC(machineList[2], createSocket(BASE_URL+DISPENSING_MACHINE_URL), DISPENSING_MACHINE_CHANNEL_NAME, curWidth),
        EquCardTSTC(machineList[3], createSocket(BASE_URL+VACUUM_PUMP1_URL), createSocket(BASE_URL+VACUUM_PUMP2_URL), VACUUM_PUMP1_CHANNEL_NAME, VACUUM_PUMP2_CHANNEL_NAME, curWidth, curHeight),
      ]
    );*/
  } else {
    // 모바일: 머신 카드만 세로 그리드로 표시
    final machineCards = _buildMachineCards(curWidth, curHeight, machineList);
    if (machineCards.isEmpty) {
      return Center(child: Text("표시할 장비가 없습니다."));
    }
    return GridView.count(
        crossAxisCount: 1,
        childAspectRatio: (curWidth/2) / (curHeight/4),
        children: machineCards
    );
  }
}

IO.Socket createSocket(String url) {
  IO.Socket socket = IO.io(url,
  IO.OptionBuilder().setTransports(['websocket']).build());
  return socket;
}
