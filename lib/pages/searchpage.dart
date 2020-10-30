import 'dart:async';

import 'package:fiction_reader/database.dart';
import 'package:fiction_reader/views/fictioninfoshower.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/search.dart' as SearchAPI;

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title, this.jumpToDetail}) : super(key: key);
  final String title;
  final Function(String) jumpToDetail;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  StreamController<List<SearchAPI.Novel>> novelListStream;
  String keyword = "";
  String language = "简体";

  @override
  void initState() {
    super.initState();
    novelListStream = StreamController<List<SearchAPI.Novel>>.broadcast();
  }

  void search() async {
    novelListStream.add(null);
    final newList = await SearchAPI.search(this.keyword,
        language: SearchAPI.getLanguageFromString(this.language));
    novelListStream.add(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                DropdownButton<String>(
                    value: language,
                    items: ["简体", "繁體"]
                        .map((it) => DropdownMenuItem<String>(
                              child: Text(it),
                              value: it,
                              key: Key(it),
                            ))
                        .toList(),
                    onChanged: (String s) => setState(() => {language = s})),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              gapPadding: 10.0)),
                      onChanged: (value) => this.keyword = value,
                    ),
                  ),
                ),
                StreamBuilder(
                  initialData: [],
                  stream: novelListStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      return IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            search();
                          });
                    else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: StreamBuilder<List<SearchAPI.Novel>>(
              stream: novelListStream.stream,
              builder: (_, novelListSnapshot) {
                if (!novelListSnapshot.hasData) return Container();
                return Consumer<Database>(builder: (_, database, __) {
                  if (database == null) return Container();
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: database.listBookmarks(),
                    builder: (_, bookmarkListSnapshot) {
                      return ListView.builder(
                        itemCount: novelListSnapshot.data.length,
                        itemBuilder: (BuildContext context, int offset) {
                          final novel = novelListSnapshot.data[offset];
                          final bookmarked = _alreadyInBookmarks(
                              bookmarkListSnapshot, novelListSnapshot, offset);
                          return fictionInfoShower(novel, bookmarked, () async {
                            if (bookmarked) {
                              try {
                                await database.removeBookmark(novel);
                                setState(() {});
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "The book you want remove doesn't exist in bookmarks!"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            } else {
                              try {
                                await database.addBookmark(
                                    novelListSnapshot.data[offset]);
                                setState(() {});
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Already added!"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            }
                          });
                        },
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _alreadyInBookmarks(
      AsyncSnapshot<List<Map<String, dynamic>>> bookmarkListSnapshot,
      AsyncSnapshot<List<SearchAPI.Novel>> novelListSnapshot,
      int offset) {
    if (!bookmarkListSnapshot.hasData) {
      return false;
    }
    return bookmarkListSnapshot.data
        .any((it) => it["book_id"] == novelListSnapshot.data[offset].novelID);
  }
}
