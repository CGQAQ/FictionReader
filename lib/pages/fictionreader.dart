import 'dart:async';

import 'package:fiction_reader/api/content.dart';
import 'package:fiction_reader/api/detail.dart';
import 'package:fiction_reader/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FictionReaderPage extends StatefulWidget {
  final String _novelID;
  final Chapter _chapter;

  FictionReaderPage(this._novelID, this._chapter);

  @override
  _FictionReaderPageState createState() => _FictionReaderPageState();
}

class _FictionReaderPageState extends State<FictionReaderPage> {
  final StreamController<Future<FictionContent>> _fictionStreamController =
      StreamController();
  PageController _pageViewController;
  Database _database;

  @override
  void initState() {
    super.initState();
    final pageIndex = int.parse(widget._chapter.id);
    _pageViewController = PageController(initialPage: pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Database>(
      builder: (_, database, __) {
        if (_database == null) {
          final fictionId = widget._novelID;
          final chapterId = widget._chapter.id;
          if (database != null) {
            _database = database;
            database.cacheExists(fictionId, chapterId).then((value) {
              if (value) {
                _fictionStreamController
                    .add(database.readFromCache(fictionId, chapterId));
              } else {
                _fictionStreamController.add(
                    FictionContent.create(widget._novelID, widget._chapter.id));
              }
              _database.remember(fictionId, chapterId);
            });
          }
        }
        return StreamBuilder<Future<FictionContent>>(
          stream: _fictionStreamController.stream,
          builder: (_, fictionStreamSnapshot) {
            if (!fictionStreamSnapshot.hasData)
              return Scaffold(
                appBar: AppBar(
                  title: Text("Loading..."),
                ),
              );
            return FutureBuilder<FictionContent>(
              future: fictionStreamSnapshot.data,
              builder: (context, snapshot) {
                if (database != null && snapshot.hasData) {
                  database.cacheIfNotCached(snapshot.data);
                }
                return Scaffold(
                  appBar: AppBar(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.hasData
                                  ? snapshot.data.fictionTitle
                                  : "Loading..."),
                              if (snapshot.hasData)
                                Text(
                                  snapshot.data.chapterTitle,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey[100]),
                                ),
                            ],
                          ),
                        ),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                      ],
                    ),
                  ),
                  body: SafeArea(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.green[100]),
                      child: PageView.builder(
                        controller: _pageViewController,
                        onPageChanged: (page) {
                          _changePage(page);
                        },
                        itemBuilder: (_, index) => SingleChildScrollView(
                          child: (snapshot.connectionState ==
                                  ConnectionState.done)
                              ? SafeArea(
                                  maintainBottomViewPadding: true,
                                  minimum: EdgeInsets.only(bottom: 70),
                                  child: Text(
                                    snapshot.data.lines
                                        .where((String element) =>
                                            element.trim().length > 0)
                                        .map((String e) =>
                                            "\t\t\t\t\t\t${e.trim()}")
                                        .join("\n"),
                                    style:
                                        GoogleFonts.maShanZheng(fontSize: 35),
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _changePage(int page) {
    final fictionId = widget._novelID;
    final chapterId = page.toString();
    _database.cacheExists(fictionId, chapterId).then((value) {
      if (value) {
        _fictionStreamController
            .add(_database.readFromCache(fictionId, chapterId));
        print("$fictionId:$chapterId loaded from cache.");
      } else {
        _fictionStreamController
            .add(FictionContent.create(fictionId, chapterId));
        print("$fictionId:$chapterId loaded from the internet.");
      }
    });
    _database.remember(fictionId, chapterId);
  }
}
