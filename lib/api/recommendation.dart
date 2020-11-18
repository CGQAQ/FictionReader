import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as Http;

class RecommendationNovel {
  final String novelID;
  final String novelTitle;
  final String novelIMG;

  RecommendationNovel(this.novelID, this.novelTitle, this.novelIMG);
}

class CategoryRecommendHeader {
  final String fictionId;
  final String title;
  final String author;
  final String description;
  final String imageUrl;

  CategoryRecommendHeader(
      this.title, this.author, this.description, this.imageUrl, this.fictionId);
}

class CategoryRecommendItem {
  final String title;
  final String fictionId;

  CategoryRecommendItem(this.title, this.fictionId);
}

class CategoryRecommend {
  final String category;
  final CategoryRecommendHeader header;
  final List<CategoryRecommendItem> items;

  CategoryRecommend(this.category, this.header, this.items);
}

class Recommendation {
  final List<RecommendationNovel> recommends;
  final List<CategoryRecommend> categoryRecommends;

  Recommendation(this.recommends, this.categoryRecommends);

  static Future<Recommendation> create() async {
    final url = "https://cn.ttkan.co/";
    final res = await Http.get(url);
    final dom = parse(res.body);
    final recommends = dom
        .querySelectorAll(".rank_frame > div:not(.rank_title) > a")
        .map(
          (e) => RecommendationNovel(
            e.attributes["href"].split("/").last,
            e.attributes["aria-label"],
            e.querySelector("amp-img").attributes["src"],
          ),
        )
        .toList();

    final categoryRecommends =
        dom.querySelectorAll(".frame_body > .pure-g > div").map((e) {
      final category = e.querySelector("h2").text.trim();
      final headerDom = e.querySelector("li").querySelector("a");
      final headerDetail =
          e.querySelectorAll("li div p").map((e) => e.text).toList();
      final fictionId = headerDom.attributes["href"];
      final fictionTitle = headerDom.attributes["aria-label"];
      final fictionImg = headerDom.querySelector("amp-img").attributes["src"];
      final author = headerDetail[0];
      final description = headerDetail[1];
      final header = CategoryRecommendHeader(
          fictionTitle, author, description, fictionImg, fictionId);
      final items = e
          .querySelectorAll("li:not(:first-child)")
          .map((e) => e.querySelector("a"))
          .toList()
          .map((e) => CategoryRecommendItem(
              e.attributes["aria-label"], e.attributes["href"]))
          .toList();
      return CategoryRecommend(category, header, items);
    }).toList();

    return Recommendation(
      recommends,
      categoryRecommends,
    );
  }
}

main() async {
  await Recommendation.create();
  print("hello");
}
