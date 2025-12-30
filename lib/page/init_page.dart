import 'package:flutter/material.dart';
import 'package:tsr_monitoring_app/widget/equ_card_one_socket_one_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../util/constants.dart';
import '../widget/anomaly_list_view.dart';
import '../widget/equ_card_one_socket_two_chart.dart';
import '../widget/equ_card_two_socket_two_chart.dart';


class InitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double curWidth = MediaQuery.of(context).size.width;
    double curHeight = MediaQuery.of(context).size.height;
    return _body(curWidth, curHeight, machineList);
  }
}

List<Widget> _buildMachineCards(double curWidth, double curHeight, List machineList) {
  if (machineList.length == 1) {
    return [
      EquCardOSTC(machineList[0], SHOT_BLAST1_CHANNEL_NAME, SHOT_BLAST2_CHANNEL_NAME, curWidth, curHeight),
    ];
  }
  return [
    EquCardOSTC(machineList[0], SHOT_BLAST1_CHANNEL_NAME, SHOT_BLAST2_CHANNEL_NAME, curWidth, curHeight),
    EquCardOSTC(machineList[1], ARO_PUMP1_CHANNEL_NAME, ARO_PUMP2_CHANNEL_NAME, curWidth, curHeight),
    EquCardOSOC(machineList[2], DISPENSING_MACHINE_CHANNEL_NAME, curWidth, curHeight),
    EquCardTSTC(machineList[3], VACUUM_PUMP1_CHANNEL_NAME, VACUUM_PUMP2_CHANNEL_NAME, curWidth, curHeight),
  ];
}

Widget _body(double curWidth, double curHeight, List machineList) {
  if(curWidth >= 768) {
    final machineCards = _buildMachineCards(curWidth, curHeight, machineList);
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
              children: [
                ...machineCards,
              ]
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
    final machineCards = _buildMachineCards(curWidth, curHeight, machineList);
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
