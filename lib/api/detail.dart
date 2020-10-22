import 'dart:convert';

import 'package:http/http.dart' as Http;
import 'package:html/parser.dart' show parse;
import './search.dart' show Language;

class Chapter {
  String title;
  String id;

  Chapter(this.title, this.id);
}

class NovelDetail {
  String title;
  String author;
  String status;
  String description;
  String coverUrl;
  List<Chapter> chapters;

  static Future<NovelDetail> from(String novelID,
      {Language language = Language.ChineseSimplified}) async {
    final baseUrl = "https://cn.ttkan.co/novel/chapters/";
    final res = await Http.get(baseUrl + novelID);
    final dom = parse(res.body);
    final novelDetail = NovelDetail();
    novelDetail.coverUrl = dom
        .querySelector(
            "#__layout > div > div:nth-child(2) > div > div.pure-g.novel_info > div.pure-u-xl-1-6.pure-u-lg-1-6.pure-u-md-1-3.pure-u-1-2 > a > amp-img")
        .attributes["src"];
    novelDetail.title = dom
        .querySelector(
            "#__layout > div > div:nth-child(2) > div > div.pure-g.novel_info > div.pure-u-xl-5-6.pure-u-lg-5-6.pure-u-md-2-3.pure-u-1-2 > ul > li")
        .querySelector("h1")
        .text;
    novelDetail.author = dom
        .querySelectorAll(
            "#__layout > div > div:nth-child(2) > div > div.pure-g.novel_info > div.pure-u-xl-5-6.pure-u-lg-5-6.pure-u-md-2-3.pure-u-1-2 > ul > li")[1]
        .querySelector("a")
        .text;
    novelDetail.status = dom
        .querySelectorAll(
            "#__layout > div > div:nth-child(2) > div > div.pure-g.novel_info > div.pure-u-xl-5-6.pure-u-lg-5-6.pure-u-md-2-3.pure-u-1-2 > ul > li")[3]
        .innerHtml
        .split("</span>")[1];
    novelDetail.description = dom
        .querySelector(
            "#__layout > div > div:nth-child(2) > div > div.description > p")
        .text;

    final res2 = await Http.get(
        "https://cn.ttkan.co/api/nq/amp_novel_chapters?${language == Language.ChineseSimplified ? "language=cn" : ""}&novel_id=$novelID");

    final result = JsonDecoder().convert(res2.body)["items"].map((it) {
      return Chapter(it["chapter_name"], it["chapter_id"].toString());
    }).toList();
    novelDetail.chapters = result.cast<Chapter>().toList();

    return novelDetail;
  }
}

main(List<String> args) async {
  final a = await NovelDetail.from("xianggongyangchenggonglve-linglingqi");
  print(a);
}
