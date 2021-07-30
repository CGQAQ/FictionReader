import 'package:fiction_reader/api/content.dart';
import 'package:fiction_reader/api/search.dart';
import 'package:sqflite/sqflite.dart' as Sqflite;

class Database {
  final _bookmarksTable = "fiction_bookmark";
  final _fictionCacheTable = "fiction_cache";
  final _historyTable = "fiction_history";
  final Sqflite.Database _database;

  Database(this._database);

  static Future<Database> init() async {
    final database = await Sqflite.openDatabase("data.db");
    final result = Database(database);
    result._createBookmarkTable();
    result._createFictionCacheTable();
    result._createFictionHistoryTable();
    return result;
  }

  void _createBookmarkTable() {
    if (_database.isOpen) {
      _database.execute('''
CREATE TABLE IF NOT EXISTS $_bookmarksTable(
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  description TEXT NOT NULL ,
  book_id TEXT NOT NULL PRIMARY KEY
)''');
    }
  }

  void _createFictionCacheTable() {
    if (_database.isOpen) _database.execute("""
CREATE TABLE IF NOT EXISTS $_fictionCacheTable(
    fiction_id TEXT NOT NULL,
    chapter_id TEXT NOT NULL,
    fiction_title TEXT NOT NULL,
    chapter_title TEXT NOT NULL,
    content TEXT,
    PRIMARY KEY(fiction_id, chapter_id)
)
""");
  }

  void _createFictionHistoryTable() {
    if (_database.isOpen) _database.execute("""
CREATE TABLE IF NOT EXISTS $_historyTable (
    fiction_id TEXT NOT NULL PRIMARY KEY,
    last_read TEXT
)""");
  }

  Future<int> addBookmark(Novel novel) {
    return _database.insert(
      _bookmarksTable,
      {
        "title": novel.title,
        "author": novel.author,
        "description": novel.desc,
        "book_id": novel.novelID,
      },
    );
  }

  Future<void> removeBookmark(Novel novel) {
    return _database.execute(
        "delete from $_bookmarksTable where book_id=?", [novel.novelID]);
  }

  Future<List<Map<String, dynamic>>> listBookmarks() async {
    return _database.query(_bookmarksTable);
  }

  Future<bool> cacheExists(String fictionId, String chapterId) async {
    return (await _database.query(
          _fictionCacheTable,
          where: "fiction_id=? and chapter_id=?",
          whereArgs: [fictionId, chapterId],
        ))
            .length >
        0;
  }

  Future<FictionContent> readFromCache(
      String fictionId, String chapterId) async {
    final result = (await _database.query(_fictionCacheTable,
            where: "fiction_id=? and chapter_id=?",
            whereArgs: [fictionId, chapterId]))
        .first;
    return FictionContent(
        result["fiction_title"],
        result["chapter_title"],
        result["fiction_id"],
        result["chapter_id"],
        (result["content"] as String).split("\n"));
  }

  Future<int> cacheIfNotCached(FictionContent fictionContent) async {
    //    fiction_id TEXT NOT NULL PRIMARY KEY,
    //     chapter_id TEXT NOT NULL,
    //     fiction_title TEXT NOT NULL,
    //     chapter_title TEXT NOT NULL,
    //     content TEXT
    if (!await cacheExists(
        fictionContent.fictionID, fictionContent.chapterID)) {
      return _database.insert(_fictionCacheTable, {
        "fiction_id": fictionContent.fictionID,
        "chapter_id": fictionContent.chapterID,
        "fiction_title": fictionContent.fictionTitle,
        "chapter_title": fictionContent.chapterTitle,
        "content": fictionContent.lines.join("\n"),
      });
    }
    return Future.value(0);
  }

  Future<bool> historyExists(String fictionId) async {
    return (await _database.query(
          _historyTable,
          where: "fiction_id=?",
          whereArgs: [fictionId],
        ))
            .length >
        0;
  }

  remember(String fictionId, String lastRead) async {
    if (!(await historyExists(fictionId))) {
      _database.insert(_historyTable, {
        "fiction_id": fictionId,
        "last_read": lastRead,
      });
    } else {
      _database.update(
        _historyTable,
        {
          "last_read": lastRead,
        },
        where: "fiction_id=?",
        whereArgs: [fictionId],
      );
    }
  }

  Future<String> tellMe(String fictionId) async {
    final result = await _database.query(
      _historyTable,
      where: "fiction_id=?",
      whereArgs: [fictionId],
    );
    if (result.length > 0) {
      return result.first["last_read"] as String;
    } else {
      return null;
    }
  }
}
