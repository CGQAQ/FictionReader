import 'package:fiction_reader/api/search.dart';
import 'package:flutter/material.dart';

Widget fictionInfoShower(Novel novel) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    child: Expanded(
      child: InkWell(
        splashColor: Colors.blueGrey[100],
        onTap: () {},
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
  );
}
