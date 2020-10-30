import 'dart:async';

import 'package:fiction_reader/api/content.dart';
import 'package:fiction_reader/api/detail.dart';
import 'package:fiction_reader/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  PageController _pageViewController;
  Database _database;
  bool _showMenu = false;
  double _fontSize = 25;
  String _fontFamily = "Noto Serif";
  Color _background = Colors.white;

  @override
  void initState() {
    super.initState();
    final pageIndex = int.parse(widget._chapter.id);
    _pageViewController = PageController(initialPage: pageIndex);
    readFromPref();
  }

  Future<void> readFromPref() async {
    final pref = await _prefs;
    final fontSize = pref.getDouble("font_size");
    final fontFamily = pref.getString("font_family");
    final background = pref.getString("background_color");
    if (fontSize != null && fontFamily != null && background != null) {
      _fontSize = pref.getDouble("font_size");
      _fontFamily = pref.getString("font_family");
      _background =
          Color(int.parse(pref.getString("background_color"), radix: 16));
      setState(() {});
    } else {
      _initPref();
    }
  }

  _initPref() async {
    _storeFontSize(25);
    _storeFontFamily("Noto Serif");
    _storeBackground(Colors.white);
  }

  _storeFontSize(double size) async {
    final pref = await _prefs;
    await pref.setDouble("font_size", size);
  }

  _storeFontFamily(String family) async {
    final pref = await _prefs;
    await pref.setString("font_family", family);
  }

  _storeBackground(Color background) async {
    final pref = await _prefs;
    await pref.setString("background_color",
        background.toString().split('(0x')[1].split(')')[0]);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
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
                  body: GestureDetector(
                    onTap: () {
                      // _showMenuTemporally();
                      _toggleMenu();
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: _background),
                          child: PageView.builder(
                            controller: _pageViewController,
                            onPageChanged: (page) {
                              _changePage(page);
                            },
                            itemBuilder: (_, index) => SingleChildScrollView(
                              child: (snapshot.connectionState ==
                                      ConnectionState.done)
                                  ? Text(
                                      snapshot.data.lines
                                          .where((String element) =>
                                              element.trim().length > 0)
                                          .map((String e) =>
                                              "\t\t\t\t\t\t${e.trim()}")
                                          .join("\n"),
                                      style: GoogleFonts.asMap()[_fontFamily](
                                          fontSize: _fontSize,
                                          color: _background == Colors.black
                                              ? Colors.grey[500]
                                              : Colors.black),
                                      // ( fontSize: _fontSize,
                                      //     color: _background == Colors.black
                                      //         ? Colors.grey[500]
                                      //         : Colors.black),),
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                        if (_showMenu)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Font size: "),
                                      Slider(
                                        onChanged: (newVal) {
                                          setState(() {
                                            _fontSize = newVal;
                                            _storeFontSize(newVal);
                                          });
                                        },
                                        value: _fontSize,
                                        max: 50,
                                        min: 20,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Font familly: "),
                                      DropdownButton(
                                        value: _fontFamily,
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: "Noto Serif",
                                            child: Text(
                                              "NotoSerif(示例字体)",
                                              style: GoogleFonts.notoSerif(
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: "ZCOOL KuaiLe",
                                            child: Text(
                                              "ZCOOL KuaiLe(示例字体)",
                                              style: GoogleFonts.zcoolKuaiLe(
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: "Ma Shan Zheng",
                                            child: Text(
                                              "MaShanZheng(示例字体)",
                                              style: GoogleFonts.maShanZheng(
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: "Liu Jian Mao Cao",
                                            child: Text(
                                              "LiuJianMaoCao(示例字体)",
                                              style: GoogleFonts.liuJianMaoCao(
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: "Long Cang",
                                            child: Text(
                                              "LongCang(示例字体)",
                                              style: GoogleFonts.liuJianMaoCao(
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (String value) {
                                          setState(
                                            () {
                                              _fontFamily = value;
                                              _storeFontFamily(value);
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Background: "),
                                      OutlineButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            _background = Colors.white;
                                            _storeBackground(Colors.white);
                                          });
                                        },
                                      ),
                                      FlatButton(
                                        splashColor: Colors.grey,
                                        color: Colors.black,
                                        onPressed: () {
                                          setState(() {
                                            _background = Colors.black;
                                            _storeBackground(Colors.black);
                                          });
                                        },
                                        child: null,
                                      ),
                                      FlatButton(
                                        color: Colors.lightGreen[100],
                                        onPressed: () {
                                          setState(() {
                                            _background =
                                                Colors.lightGreen[100];
                                            _storeBackground(
                                                Colors.lightGreen[100]);
                                          });
                                        },
                                        child: null,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
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

  // void _showMenuTemporally() {
  //   if (!_showMenu) {
  //     setState(() {
  //       _showMenu = true;
  //       Future.delayed(Duration(seconds: 2), () {
  //         setState(() {
  //           _showMenu = false;
  //         });
  //       });
  //     });
  //   }
  // }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  @override
  void deactivate() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}
