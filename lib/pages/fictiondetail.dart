import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:fiction_reader/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/detail.dart' as DetailAPI;
import '../database.dart';

class FictionDetail extends StatelessWidget {
  final String _id;
  final _semicircleController = ScrollController();

  FictionDetail(this._id);

  @override
  Widget build(BuildContext context) {
    final detail = DetailAPI.NovelDetail.from(_id);
    return Container(
        child: FutureBuilder<DetailAPI.NovelDetail>(
            future: detail,
            builder: (_, snapshot) {
              return Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        Expanded(child: Text(snapshot.data?.title ?? "加载中...")),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                      ],
                    ),
                  ),
                  body: Container(
                    child: (snapshot.connectionState == ConnectionState.done)
                        ? _generateView(snapshot.data)
                        : null,
                  ));
            }));
  }

  Widget _generateView(DetailAPI.NovelDetail data) {
    return Column(
      children: [
        _generateDetailView(data),
        _generateChapterListView(data),
      ],
    );
  }

  Container _generateDetailView(DetailAPI.NovelDetail data) {
    return Container(
      height: 210,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        border: Border.all(color: Colors.blue, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[200],
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 5,
                ),
                child: Image.network(
                  data.coverUrl,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 165,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer2<Database, JumpToReaderType>(
                      builder: (_, database, jumpToDetail, __) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.blueGrey[700]),
                              ),
                              Text(
                                data.author,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.blueGrey[500]),
                              ),
                            ],
                          ),
                          if (database != null)
                            FutureBuilder(
                              future: database.historyExists(_id),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                if (snapshot.data) {
                                  return FlatButton(
                                    child: Text(
                                      "上次阅读",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      database.tellMe(_id).then((value) =>
                                          jumpToDetail(
                                              _id,
                                              data.chapters
                                                  .where((element) =>
                                                      element.id == value)
                                                  .first));
                                    },
                                  );
                                }
                                return Container();
                              },
                            )
                        ],
                      ),
                    ),
                    Text(
                      data.status,
                      style: TextStyle(
                          color: Colors.green[199],
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        data.description.length > 80
                            ? data.description.substring(0, 80) + "..."
                            : data.description,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _generateChapterListView(DetailAPI.NovelDetail data) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue[200],
              Colors.lightGreen[500],
            ],
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Consumer<JumpToReaderType>(
            builder: (_, jumpToReader, __) => DraggableScrollbar.semicircle(
              alwaysVisibleScrollThumb: true,
              labelTextBuilder: (offset) {
                final int currentItem = _semicircleController.hasClients
                    ? (_semicircleController.offset /
                            _semicircleController.position.maxScrollExtent *
                            data.chapters.length)
                        .floor()
                    : 0;
                return Text("$currentItem");
              },
              labelConstraints:
                  BoxConstraints.tightFor(width: 80.0, height: 30.0),
              controller: _semicircleController,
              child: ListView.builder(
                key: ObjectKey(data.chapters),
                itemExtent: 45,
                controller: _semicircleController,
                itemCount: data.chapters.length,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () {
                      jumpToReader(_id, data.chapters[index]);
                      print(data.chapters[index].title);
                    },
                    splashColor: Colors.black,
                    child: Container(
                      constraints: BoxConstraints(minHeight: 45),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.blue[100],
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        data.chapters[index].title,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
