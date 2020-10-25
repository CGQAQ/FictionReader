import "package:flutter/material.dart";

enum PageIndex {
  Bookshelf,
  Search,
}

Drawer mainDrawer(
    GlobalKey<ScaffoldState> state, ValueChanged<PageIndex> onchange) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Text(
            "Fiction reader",
            style: TextStyle(fontSize: 40, fontFamily: "Courgette"),
          ),
          decoration: BoxDecoration(color: Colors.blue),
        ),
        ...["Bookshelf", "Search"].map((it) => _myListTile(
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
          if (text == "Bookshelf")
            onchange(PageIndex.Bookshelf);
          else if (text == "Search")
            onchange(PageIndex.Search);
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
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
