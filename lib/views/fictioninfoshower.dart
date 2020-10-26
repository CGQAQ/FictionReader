import 'package:fiction_reader/api/search.dart';
import 'package:fiction_reader/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget fictionInfoShower(
    Novel novel, bool bookmarked, Future<void> Function() onTap) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<JumpToDetailType>(
            builder: (_, jumpToDetail, __) => InkWell(
              splashColor: Colors.blueGrey[100],
              onTap: () {
                jumpToDetail(novel.novelID);
              },
              key: ObjectKey(novel),
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
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            await onTap();
          },
          icon: Icon(
              bookmarked ? Icons.bookmark_outlined : Icons.bookmark_outline),
        ),
      ],
    ),
  );
}
