import 'package:fiction_reader/api/detail.dart';
import 'package:fiction_reader/pages/fictionreader.dart';
import 'package:fiction_reader/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database.dart' as DB;
import 'pages/fictiondetail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

typedef JumpToReaderType = void Function(String, Chapter);
typedef JumpToDetailType = void Function(String);

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _database = DB.Database.init();
  List<Page> pages = [];

  void jumpToDetail(String id) {
    setState(() {
      pages.add(
        MaterialPage(
          child: Provider.value(
            value: jumpToReader,
            child: _databaseProvider(
              child: FictionDetail(id),
            ),
          ),
        ),
      );
    });
  }

  void jumpToReader(String id, Chapter chapter) {
    setState(() {
      pages.add(MaterialPage(
          child: _databaseProvider(child: FictionReaderPage(id, chapter))));
    });
  }

  Widget _databaseProvider({Widget child}) {
    return FutureBuilder(
      future: _database,
      builder: (_, snapshot) => Provider<DB.Database>.value(
        value: snapshot.data,
        child: child,
      ),
    );
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
              child: Provider.value(
                value: jumpToDetail,
                child: _databaseProvider(
                  child: HomePage(),
                ),
              ),
            ),
            ...pages,
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
