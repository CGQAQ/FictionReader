import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as Http;

class FictionContent {
  final String fictionTitle;
  final String chapterTitle;
  final String fictionID;
  final String chapterID;
  final List<String> lines;
  FictionContent(this.fictionTitle, this.chapterTitle, this.fictionID,
      this.chapterID, this.lines);
  static Future<FictionContent> create(String novelID, String chapterID) async {
    try {
      // https://cn.ttkan.co/novel/user/page_direct?novel_id=jiansong-danshuiluyu&page=760
      final url =
          "https://cn.ttkan.co/novel/user/page_direct?novel_id=$novelID&page=$chapterID";
      final content = await Http.get(url);
      final dom = parse(content.body);
      final fictionTitle = dom
          .querySelectorAll(
              "#__layout > div > div > div.frame_body > div.breadcrumb_nav.target > div > a")[2]
          .text;
      final chapterTitle = dom
          .querySelector(
              "#__layout > div > div > div.frame_body > div.title > h1")
          .text;
      final lines = dom
          .querySelector(".content")
          .querySelectorAll("p")
          .map((e) => e.text)
          .toList();
      return FictionContent(
          fictionTitle, chapterTitle, novelID, chapterID, lines);
    } catch (_) {
      rethrow;
    }
  }
}
