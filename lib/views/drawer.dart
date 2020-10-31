import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

enum PageIndex {
  Bookshelf,
  Search,
  Recommendation,
}

final _navItems = ["书架", "搜索", "推荐"];

Drawer mainDrawer(
    GlobalKey<ScaffoldState> state, ValueChanged<PageIndex> onchange) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Text(
            "小说阅读",
            style: GoogleFonts.courgette(fontSize: 40),
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
      color: Colors.lightBlue,
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
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.sanchez(fontSize: 30),
            ),
          ),
        ),
      ),
    ),
  );
}
