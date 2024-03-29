import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

enum PageIndex {
  Bookshelf,
  Search,
  Recommendation,
}

final _navItems = ["书架", "搜索", "推荐"];
var _page = _navItems[0];

Drawer mainDrawer(
    GlobalKey<ScaffoldState> state, ValueChanged<PageIndex> onchange) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Center(
            child: Text(
              "小说阅读",
              style: TextStyle(fontSize: 40, fontFamily: "Ma_Shan_Zheng"),
            ),
          ),
          decoration: BoxDecoration(color: Colors.blue),
        ),
        ..._navItems.map((it) => _myListTile(
              state,
              onchange,
              it,
            )),
      ],
    ),
  );
}

Widget _myListTile(
  GlobalKey<ScaffoldState> state,
  ValueChanged<PageIndex> onchange,
  String text,
) {
  return Container(
    height: 75,
    decoration: BoxDecoration(
      color: _page == text ? Colors.blue[500] : Colors.blue[400],
      border: Border(
        bottom: BorderSide(
          color: Colors.lightBlueAccent,
          width: 2,
        ),
      ),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          if (text == _navItems[0])
            onchange(PageIndex.Bookshelf);
          else if (text == _navItems[1])
            onchange(PageIndex.Search);
          else if (text == _navItems[2])
            onchange(PageIndex.Recommendation);
          else
            onchange(PageIndex.Bookshelf);
          if (state.currentState.hasDrawer && state.currentState.isDrawerOpen) {
            Navigator.of(state.currentContext).pop();
          }
          _page = text;
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.maShanZheng(fontSize: 30),
            ),
          ),
        ),
      ),
    ),
  );
}
