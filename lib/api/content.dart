import 'package:http/http.dart' as Http;
import 'package:html/parser.dart' show parse;

class FictionContent {
  final List<String> lines;
  FictionContent(this.lines);
  static Future<FictionContent> create(String novelID, String chapterID) async {
    try {
      // https://cn.ttkan.co/novel/user/page_direct?novel_id=jiansong-danshuiluyu&page=760
      final url =
          "https://cn.ttkan.co/novel/user/page_direct?novel_id=$novelID&page=$chapterID";
      final content = await Http.get(url);
      final dom = parse(content.body);
      final lines = dom
          .querySelector(".content")
          .querySelectorAll("p")
          .map((e) => e.text)
          .toList();
      return FictionContent(lines);
    } catch (_) {
      rethrow;
    }
  }
}
