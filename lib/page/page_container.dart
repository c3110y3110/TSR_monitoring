import 'package:flutter/material.dart';

import '../util/unique_shared_preference.dart';

class PageContainer extends StatefulWidget {
  late Widget body;

  PageContainer(this.body);

  @override
  State<PageContainer> createState() => _PageContainerState(body);
}

class _PageContainerState extends State<PageContainer> {
  late Widget body;
  _PageContainerState(this.body);

  @override
  Widget build(BuildContext context) {
    double curWidth = MediaQuery.of(context).size.width;
    int count = 0;
    if (curWidth >= 768) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('홈'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('설정'),
                ),
              ],
              selectedIndex: int.parse(UniqueSharedPreference.getString('selectedIndex')),
              onDestinationSelected: (int index) {
                if (index == 0) {
                  if (_getCurrentRoute(context) != '/') {
                    Navigator.pushNamed(context, '/');
                    UniqueSharedPreference.setString(
                        'selectedIndex', index.toString());
                  }
                } else if (index == 1) {
                  if (_getCurrentRoute(context) != '/setting') {
                    Navigator.pushNamed(context, '/setting');
                    UniqueSharedPreference.setString(
                        'selectedIndex', index.toString());
                  }
                }
              }
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child:Center(child: body))
            )
          ]
        )
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('TSR 모니터링 시스템', style: TextStyle(fontWeight: FontWeight.w900),),
          centerTitle: true,
          elevation: 5.0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                if (_getCurrentRoute(context) != '/setting') {
                  Navigator.pushNamed(context, '/setting');
                }
              },
            )
          ],
        ),
        body: body
    );
  }

  String _getCurrentRoute(BuildContext context) {
    Route<dynamic>? route = ModalRoute.of(context);
    return route?.settings.name.toString() ?? '/';
  }
}