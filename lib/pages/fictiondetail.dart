import 'package:flutter/material.dart';
import '../api/detail.dart' as DetailAPI;

class FictionDetail extends StatelessWidget {
  final String _id;

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
                  body: Column(
                    children: [
                      if (snapshot.connectionState == ConnectionState.done)
                        _generateView(snapshot.data),
                    ],
                  ));
            }));
  }

  Widget _generateView(DetailAPI.NovelDetail data) {
    return Column(
      children: [
        _generateDetailView(data),
      ],
    );
  }

  Container _generateDetailView(DetailAPI.NovelDetail data) {
    return Container(
      height: 200,
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
              Image.network(
                data.coverUrl,
                fit: BoxFit.cover,
                width: 120,
                height: 160,
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style:
                          TextStyle(fontSize: 20, color: Colors.blueGrey[700]),
                    ),
                    Text(
                      data.author,
                      style:
                          TextStyle(fontSize: 15, color: Colors.blueGrey[500]),
                    ),
                    Text(
                      data.status,
                      style: TextStyle(
                          color: Colors.green[199],
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Expanded(
                        child: Text(
                          data.description.length > 75
                              ? data.description.substring(0, 75) + "..."
                              : data.description,
                          softWrap: true,
                          overflow: TextOverflow.clip,
                        ),
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
}
