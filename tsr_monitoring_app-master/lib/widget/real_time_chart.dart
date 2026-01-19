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
    // 센서별 Socket.IO 네임스페이스 연결
    socket = createSocket(BASE_URL + sioUrlMap[channelName]!);
    socket.connect();
    if (curWidth <= 768) {
      maxLen = 80;
    } else {
      maxLen = 200;
    }
    // 서버 이벤트(update/initialize/anomaly) 수신 처리
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
    // 최초 진입 시 캐시 데이터 요청
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
    // 설정값은 기본 범위로 사용하고, 실제 스케일은 수신 데이터로 자동 계산
    double maxvalue = double.parse(UniqueSharedPreference.getString('maxvalue'));
    double minvalue = double.parse(UniqueSharedPreference.getString('minvalue'));
    if (minvalue > maxvalue) {
      final double temp = minvalue;
      minvalue = maxvalue;
      maxvalue = temp;
    }
    final _AxisRange axisRange = _getAxisRange(minvalue, maxvalue);
    return (
        Column(children: [
          Container(
              padding: EdgeInsets.all(5),
              height: itemHeight,
              child: SfCartesianChart(
                  title: ChartTitle(text: channelNameMap[channelName]!),
                  primaryXAxis: DateTimeAxis(dateFormat: DateFormat('HH:mm')),
                  primaryYAxis: NumericAxis(
                    minimum: axisRange.min,
                    maximum: axisRange.max,
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


  _AxisRange _getAxisRange(double fallbackMin, double fallbackMax) {
    // 데이터가 있으면 자동 스케일, 없으면 설정값(fallback) 사용
    if (chartData.isEmpty) {
      return _AxisRange(fallbackMin, fallbackMax);
    }
    double dataMin = chartData.first.y;
    double dataMax = chartData.first.y;
    for (final _ChartData point in chartData) {
      if (point.y < dataMin) {
        dataMin = point.y;
      }
      if (point.y > dataMax) {
        dataMax = point.y;
      }
    }
    double range = dataMax - dataMin;
    double padding;
    if (range == 0) {
      padding = dataMax.abs() * 0.1;
      if (padding == 0) {
        padding = (fallbackMax - fallbackMin).abs() * 0.1;
      }
      if (padding == 0) {
        padding = 0.01;
      }
    } else {
      padding = range.abs() * 0.1;
    }
    return _AxisRange(dataMin - padding, dataMax + padding);
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

class _AxisRange {
  _AxisRange(this.min, this.max);
  double min;
  double max;
}
