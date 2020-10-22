import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/fictiondetail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  List<Page> pages = [];

  void jumpToDetail(String id) {
    setState(() {
      pages.add(MaterialPage(child: FictionDetail(id)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WillPopScope(
        onWillPop: () async => !await _navigatorKey.currentState.maybePop(),
        child: Navigator(
          key: _navigatorKey,
          pages: [
            MaterialPage(
                child: MyHomePage(
              title: 'Fiction reader',
              jumpToDetail: jumpToDetail,
            )),
            ...pages
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            setState(() {
              this.pages.removeLast();
            });
            return true;
          },
        ),
      ),
    );
  }
}
