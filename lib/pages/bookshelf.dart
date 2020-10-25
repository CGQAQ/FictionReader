import 'package:fiction_reader/api/search.dart';
import 'package:fiction_reader/database.dart';
import 'package:fiction_reader/views/fictioninfoshower.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookShelf extends StatefulWidget {
  @override
  _BookShelfState createState() => _BookShelfState();
}

class _BookShelfState extends State<BookShelf> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Database>(
      builder: (_, database, __) {
        if (database == null) {
          return Container();
        }
        return FutureBuilder<List<Map>>(
          future: database.listBookmarks(),
          builder: (_, bookmarkSnapshot) {
            final list = bookmarkSnapshot.data;
            if (!bookmarkSnapshot.hasData || bookmarkSnapshot.data.length == 0)
              return Container(
                child: Center(child: Text("Empty")),
              );
            else {
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, index) {
                  final data = list[index];
                  return fictionInfoShower(Novel(data["title"], data["author"],
                      data["description"], data["book_id"]));
                },
              );
            }
          },
        );
      },
    );
  }
}
