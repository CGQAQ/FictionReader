import 'package:fiction_reader/api/search.dart';
import 'package:sqflite/sqflite.dart' as Sqflite;

class Database {
  final Sqflite.Database _database;

  Database(this._database);

  static Future<Database> init() async {
    final database = await Sqflite.openDatabase("data.db");
    final result = Database(database);
    result._createBookmarkTable();
    return result;
  }

  void _createBookmarkTable() {
    if (_database.isOpen) {
      _database.execute("""
CREATE TABLE IF NOT EXISTS bookmarks(
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  description TEXT NOT NULL ,
  book_id TEXT NOT NULL PRIMARY KEY
)""");
    }
  }

  Future<int> addBookmark(Novel novel) {
    return _database.insert(
      "bookmarks",
      {
        "title": novel.title,
        "author": novel.author,
        "description": novel.desc,
        "book_id": novel.novelID,
      },
    );
  }

  Future<void> removeBookmark(Novel novel) {
    return _database
        .execute("delete from bookmarks where book_id=?", [novel.novelID]);
  }

  Future<List<Map<String, dynamic>>> listBookmarks() async {
    return _database.query("bookmarks");
  }
}
