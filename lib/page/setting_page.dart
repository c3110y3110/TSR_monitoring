import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsr_monitoring_app/util/unique_shared_preference.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  final _maxvalueController = TextEditingController();
  final _minvalueController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double curWidth = MediaQuery.of(context).size.width;
    if(curWidth >= 768) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Icon(Icons.arrow_back)),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("설정", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),)
                    ],
                  )
              )
            ],
          ),
          Expanded(child: _buildSetting(context)),
        ]
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(5),
          child: ListView(
              children: [
                Align(alignment: Alignment.center, child: Text("설정", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),),),
                _buildSetting(context),
              ]
          )
      );
    }
  }

  Widget _buildSetting(BuildContext context) {
    return Column(
      children: [
        Text("실시간 차트 최댓값"),
        Padding(padding: EdgeInsets.only(top: 20)),
        TextField(
          keyboardType: TextInputType.number,
          controller: _maxvalueController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '최댓값 ',
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Text("실시간 차트 최솟값"),
        Padding(padding: EdgeInsets.only(top: 20)),
        TextField(
          keyboardType: TextInputType.number,
          controller: _minvalueController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '최솟값',
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        ElevatedButton(
          onPressed: () => {
            _saveValue()
          },
          child: Text("저장", style: TextStyle(fontSize: 24),))
      ],
    );
  }

  void _saveValue() {
    try {
      double.parse(_maxvalueController.text);
      double.parse(_minvalueController.text);
      UniqueSharedPreference.setString("maxvalue", _maxvalueController.text);
      UniqueSharedPreference.setString("minvalue", _minvalueController.text);
      Navigator.of(context).pop();
    } catch(e) {
      _maxvalueController.clear();
      _minvalueController.clear();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("숫자만 입력해주세요."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("확인")
                )
              ],
            );
          }
      );
    }
  }

  @override
  void dispose() {
    _maxvalueController.dispose();
    _minvalueController.dispose();
    super.dispose();
  }
}