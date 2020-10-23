import 'package:fiction_reader/api/content.dart';
import 'package:fiction_reader/api/detail.dart';
import 'package:flutter/material.dart';

class FictionReaderPage extends StatefulWidget {
  final String _novelID;
  final Chapter _chapter;
  FictionReaderPage(this._novelID, this._chapter);
  @override
  _FictionReaderPageState createState() => _FictionReaderPageState();
}

class _FictionReaderPageState extends State<FictionReaderPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FictionContent>(
      future: FictionContent.create(widget._novelID, widget._chapter.id),
      builder: (_, snapshot) => Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget._chapter.title),
              if (snapshot.connectionState == ConnectionState.waiting)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            child: ListView(
              children: [
                if (snapshot.connectionState == ConnectionState.done)
                  ...snapshot.data.lines.map((it) => Text(it))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
