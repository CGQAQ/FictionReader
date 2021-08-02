import 'dart:async';
import 'dart:ui';

import 'package:fiction_reader/api/recommendation.dart';
import 'package:fiction_reader/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FictionRecommendation extends StatefulWidget {
  @override
  _FictionRecommendationState createState() => _FictionRecommendationState();
}

class _FictionRecommendationState extends State<FictionRecommendation> {
  var _recommendationController = StreamController<Recommendation>();

  JumpToDetailType _jumpToDetail;

  @override
  void initState() {
    super.initState();
    Recommendation.create()
        .then((value) => _recommendationController.add(value));

    _jumpToDetail = context.read<JumpToDetailType>();
  }

  void openDetailPage(String id) {
    _jumpToDetail(id);
  }

  List<Widget> _listItem(Recommendation recommend) {
    return recommend.categoryRecommends
        .asMap()
        .map(
          (i, e) => MapEntry(
            i,
            ListView.builder(
              itemCount: recommend.categoryRecommends[i].items.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  final data = recommend.categoryRecommends[i].header;
                  return SizedBox(
                    height: 100,
                    child: InkWell(
                      onTap: () {
                        _jumpToDetail(data.fictionId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(data.imageUrl),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.ideographic,
                                      children: [
                                        Text(
                                          data.title,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(data.author),
                                      ]),
                                  Text(
                                    data.description,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return InkWell(
                    onTap: () {
                      _jumpToDetail(recommend
                          .categoryRecommends[i].items[index - 1].fictionId);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        recommend.categoryRecommends[i].items[index - 1].title,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        )
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<Recommendation>(
        stream: _recommendationController.stream,
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();
          final recommend = snapshot.data;
          return Column(
            children: [
              LimitedBox(
                maxHeight: 265,
                child: GridView.builder(
                  key: ObjectKey(recommend),
                  itemCount: recommend.recommends.length,
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4),
                  itemBuilder: (_, index) {
                    final data = recommend.recommends[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          data.novelIMG,
                          fit: BoxFit.fill,
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.blueAccent,
                              onTap: () {
                                _jumpToDetail(data.novelID);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: DefaultTabController(
                  length: recommend.categoryRecommends.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabs: [
                          ...recommend.categoryRecommends.map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                e.category,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [...this._listItem(recommend)],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
