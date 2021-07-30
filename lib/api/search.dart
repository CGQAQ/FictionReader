import 'package:html/parser.dart' show parse;
import "package:http/http.dart" as Http;

const api = "https://www.ttkan.co/novel/search?q=";
const api_cn = "https://cn.ttkan.co/novel/search?q=";

class Novel {
  String title;
  String author;
  String desc;
  String novelID;
  Novel(this.title, this.author, this.desc, this.novelID);
  @override
  String toString() {
    return """Title: ${this.title}
Author: ${this.author}
Desc: ${this.desc}
BookID: ${this.novelID}""";
  }
}

enum Language {
  ChineseSimplified,
  ChineseTraditional,
}

Language getLanguageFromString(String s) {
  if (s == "简体") {
    return Language.ChineseSimplified;
  } else {
    return Language.ChineseTraditional;
  }
}

Future<List<Novel>> search(String keyword,
    {Language language = Language.ChineseTraditional}) async {
  final url = (language == Language.ChineseSimplified ? api_cn : api) + keyword;
  final res = await Http.get(Uri.parse(url));

  final selector = "#__layout > div > div.frame_body > div.pure-g > div";

  final doc = parse(res.body);

  return doc.querySelectorAll(selector).map((it) {
    final ul = it.querySelectorAll("ul > li");
    assert(ul.length == 3);
    String title = "";
    String author = "";
    String desc = "";
    String novelID = "";
    final titleAndUrl = ul[0].querySelector("a");
    novelID = titleAndUrl.attributes["href"].split("/").last;
    title = titleAndUrl.querySelector("h3").text;
    author = ul[1].text;
    desc = ul[2].text;
    return Novel(title, author, desc, novelID);
  }).toList();
}
