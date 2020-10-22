import 'dart:async';

import 'package:flutter/material.dart';
import '../api/search.dart' as SearchAPI;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.jumpToDetail}) : super(key: key);
  final String title;
  final Function(String) jumpToDetail;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            child: Column(children: [
          Expanded(
            flex: 1,
            child: Row(children: [
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
              )
            ]),
          ),
          Expanded(
            flex: 9,
            child: StreamBuilder<List<SearchAPI.Novel>>(
                stream: novelListStream.stream,
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int offset) {
                        final novel = snapshot.data[offset];
                        return InkWell(
                            splashColor: Colors.blueGrey[100],
                            onTap: () {
                              print("tap ${novel.title}");
                              widget.jumpToDetail(novel.novelID);
                            },
                            key: ObjectKey(novel),
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 10),
                                child: Column(
                                  key: ObjectKey(novel),
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                )));
                      });
                }),
          )
        ])));
  }
}
