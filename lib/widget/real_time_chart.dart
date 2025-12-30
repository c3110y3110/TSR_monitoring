import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tsr_monitoring_app/util/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:tsr_monitoring_app/util/unique_shared_preference.dart';

import '../util/stream_socket.dart';

class LiveChart extends StatefulWidget {
  late String channelName;
  late double curWidth;
  late bool isDetail;
  LiveChart(this.channelName, this.curWidth, this.isDetail);
  @override
  _LiveChart createState() => _LiveChart(channelName, curWidth, isDetail);
}

class _LiveChart extends State<LiveChart> {
  late IO.Socket socket;
  late String channelName;
  late int maxLen;
  late bool isDetail;
  List<_ChartData> chartData = <_ChartData>[];
  double threshold = 0;
  double score = 0;
  ChartSeriesController? _chartSeriesController;
  bool isAnomaly = false;
  late double curWidth;
  _LiveChart(this.channelName, this.curWidth, this.isDetail);
  @override
  void initState() {
    super.initState();
    socket = createSocket(BASE_URL + sioUrlMap[channelName]!);
    socket.connect();
    if (curWidth <= 768) {
      maxLen = 80;
    } else {
      maxLen = 200;
    }
    socket.onAny((eventName, data) {
      try {
        if(data != null) {
          if (eventName == ANOMALY_EVENT) {
            setState(() {
              isAnomaly = score > threshold;
              threshold = data[THRESHOLD] as double;
              score = data[SCORE] as double;
            });
          } else if (eventName == INITIALIZE_EVENT) {
            setState(() {
              if (data[0]["sensor_name"] == channelName) {
                data.forEach((value) {
                  chartData.add(_ChartData(DateTime.parse(value["time"]), value["data"]));
                  if (chartData.length == maxLen) {
                    chartData.removeAt(0);
                    _chartSeriesController?.updateDataSource(
                        addedDataIndexes: <int>[chartData.length - 1],
                        removedDataIndexes: <int>[0]);
                  } else {
                    _chartSeriesController?.updateDataSource(
                        addedDataIndexes: <int>[chartData.length - 1]);
                  }
                });
              }
            });
          } else if (eventName == UPDATE_EVENT) {
            setState(() {
              if (data["sensor_name"] == channelName) {
                chartData.add(_ChartData(DateTime.parse(data["time"]), data["data"]));
                if (chartData.length == maxLen) {
                  chartData.removeAt(0);
                  _chartSeriesController?.updateDataSource(
                      addedDataIndexes: <int>[chartData.length - 1],
                      removedDataIndexes: <int>[0]);
                } else {
                  _chartSeriesController?.updateDataSource(
                      addedDataIndexes: <int>[chartData.length - 1]);
                }
              }
            });
          }
        }
      } catch (e) {
        print(e);
      }
    });
    socket.emit('initialize', channelName);
  }

  @override
  Widget build(BuildContext context) {
    double curHeight = MediaQuery.of(context).size.height;
    double itemHeight;
    if (curWidth >= 768 && !isDetail) {
      itemHeight = curHeight * 0.2;
    } else {
      itemHeight = curHeight * 0.35;
    }
    double maxvalue = double.parse(UniqueSharedPreference.getString('maxvalue'));
    double minvalue = double.parse(UniqueSharedPreference.getString('minvalue'));
    return (
        Column(children: [
          Container(
              padding: EdgeInsets.all(5),
              height: itemHeight,
              child: SfCartesianChart(
                  title: ChartTitle(text: channelNameMap[channelName]!),
                  primaryXAxis: DateTimeAxis(dateFormat: DateFormat('HH:mm')),
                  primaryYAxis: NumericAxis(
                    minimum: minvalue,
                    maximum: maxvalue,
                    decimalPlaces: 6,
                    rangePadding: ChartRangePadding.round,
                  ),
                  series: <LineSeries<_ChartData, DateTime>>[
                    LineSeries(
                      onRendererCreated: (ChartSeriesController controller) {
                        _chartSeriesController = controller;
                      },
                      trendlines: <Trendline>[
                        Trendline(
                          type: TrendlineType.linear,
                          color: Colors.deepOrange,
                        )
                      ],
                      dataSource: chartData,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                    )
                  ]
              )
          ),
          _getBottomWrap(),
        ],
        )
    );

  }

  @override
  void dispose() {
    socket.offAny();
    socket.disconnected;
    super.dispose();
  }

  Padding _getBottomWrap() {
    double size = 20;
    if(curWidth <= 768) {
      size = 15;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Wrap(
        spacing: 100,
        children: [
          Text("상태", style: TextStyle(fontSize: size)),
          _getStateText(size),
        ],
      )
    );
  }

  Text _getStateText(double size) {
    if (isAnomaly) {
      return Text("고장 $score / $threshold", style: TextStyle(fontSize: size-3, color: Colors.red));
    }
    return Text("정상", style: TextStyle(fontSize: size, color: Colors.green));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  DateTime x;
  double y;
}