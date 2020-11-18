import 'dart:async';

import 'package:fiction_reader/api/recommendation.dart';
import 'package:flutter/material.dart';

class FictionRecommendation extends StatefulWidget {
  @override
  _FictionRecommendationState createState() => _FictionRecommendationState();
}

class _FictionRecommendationState extends State<FictionRecommendation> {
  var _recommendationController = StreamController<Recommendation>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Recommendation.create()
        .then((value) => _recommendationController.add(value));
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
                itemBuilder: (_, index) {
                  final data = recommend.recommends[index];
                  return Stack(
                    children: [
                      Image.network(data.novelIMG),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.blueAccent,
                            onTap: () {
                              print("hello");
                              print(recommend.categoryRecommends
                                  .map((e) => e.category)
                                  .join("+"));
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 0.75),
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
                        children: [
                          ...recommend.categoryRecommends
                              .asMap()
                              .map(
                                (i, e) => MapEntry(
                                  i,
                                  ListView.builder(
                                    itemCount: recommend.categoryRecommends[i]
                                            .items.length +
                                        1,
                                    itemBuilder: (_, index) {
                                      if (index == 0) {
                                        final data = recommend
                                            .categoryRecommends[i].header;
                                        print(i);
                                        return IntrinsicHeight(
                                          child: InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Image.network(data.imageUrl),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .baseline,
                                                            textBaseline:
                                                                TextBaseline
                                                                    .ideographic,
                                                            children: [
                                                              Text(
                                                                data.title,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                              Text(data.author),
                                                            ]),
                                                        Text(
                                                          data.description,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                          onTap: () {},
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              recommend.categoryRecommends[i]
                                                  .items[index - 1].title,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                              .values,
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    ));
  }
}
