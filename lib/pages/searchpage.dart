import 'dart:async';

import 'package:fiction_reader/database.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
                  return Consumer<Database>(
                    builder: (_, database, __) =>
                        FutureBuilder<List<Map<String, dynamic>>>(
                      future: database.listBookmarks(),
                      builder: (_, bookmarkListSnapshot) {
                        return ListView.builder(
                          itemCount: novelListSnapshot.data.length,
                          itemBuilder: (BuildContext context, int offset) {
                            final novel = novelListSnapshot.data[offset];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.blueGrey[100],
                                      onTap: () {
                                        print("tap ${novel.title}");
                                        widget.jumpToDetail(novel.novelID);
                                      },
                                      key: ObjectKey(novel),
                                      child: Column(
                                        key: ObjectKey(novel),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            novel.title,
                                            style: TextStyle(fontSize: 21),
                                          ),
                                          Text(
                                            novel.author,
                                            style: TextStyle(
                                                color: Colors.blueGrey[400],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            novel.desc,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blueGrey[300]),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (_alreadyInBookmarks(
                                          bookmarkListSnapshot,
                                          novelListSnapshot,
                                          offset)) {
                                        return IconButton(
                                          icon: Icon(Icons.bookmark_outlined),
                                          onPressed: () async {
                                            try {
                                              await database
                                                  .removeBookmark(novel);
                                              setState(() {});
                                            } catch (_) {
                                              Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "The book you want remove doesn't exist in bookmarks!"),
                                                  duration:
                                                      Duration(seconds: 1),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      } else {
                                        return IconButton(
                                          icon: Icon(Icons.bookmark_outline),
                                          onPressed: () async {
                                            try {
                                              await database.addBookmark(
                                                  novelListSnapshot
                                                      .data[offset]);
                                              setState(() {});
                                            } catch (e) {
                                              Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text("Already added!"),
                                                  duration:
                                                      Duration(seconds: 1),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
