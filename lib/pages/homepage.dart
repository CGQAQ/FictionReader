import 'package:fiction_reader/pages/bookshelf.dart';
import 'package:fiction_reader/pages/fictionrecommand.dart';
import 'package:fiction_reader/pages/searchpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../views/drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _mainScaffoldState = GlobalKey();
  PageIndex _pageIndex;
  @override
  void initState() {
    super.initState();
    _pageIndex = PageIndex.Bookshelf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainScaffoldState,
      appBar: AppBar(
        title: Text("小说阅读"),
      ),
      drawer: mainDrawer(_mainScaffoldState,
          (pageIndex) => setState(() => _pageIndex = pageIndex)),
      body: Container(
        child: Builder(
          builder: (_) {
            if (_pageIndex == PageIndex.Bookshelf) {
              return BookShelf();
            } else if (_pageIndex == PageIndex.Search) {
              return SearchPage();
            } else if (_pageIndex == PageIndex.Recommendation) {
              return FictionRecommendation();
            }
            return BookShelf();
          },
        ),
      ),
    );
  }
}
