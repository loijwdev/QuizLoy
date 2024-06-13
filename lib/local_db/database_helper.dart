import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _instance = DatabaseHelper._init();
  DatabaseHelper._init();

  factory DatabaseHelper() => _instance;

  Database? _db;
  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      String name = 'quiz_loy.db';
      String dbPath = join(await getDatabasesPath(), name);
      _db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
        db.execute('''
            CREATE TABLE VocabularyTopics(
            topicId TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT,
            description TEXT,
            isPublic INTEGER,
            createdAt TEXT,
            participantCount INTEGER
          )
        ''');
        db.execute('''
            CREATE TABLE Words(
              wordId TEXT PRIMARY KEY,
              topicId TEXT,
              english TEXT,
              vietnamese TEXT,
              status TEXT,
              starred INTEGER,
              FOREIGN KEY(topicId) REFERENCES VocabularyTopics(topicId)
            )
          ''');
      });
      return _db!;
    }
  }

  Future<void> insertTopic(VocabularyTopic topic, List<Word> words) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert the topic into the VocabularyTopics table
      await txn.insert(
        'VocabularyTopics',
        topic.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert each word into the Words table
      for (Word word in words) {
        await txn.insert(
          'Words',
          word.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    print('Successfully added topic and words to the database');
  }

  Future<VocabularyTopic?> getTopicById(String topicId) {
    final db = database;
    return db.then((value) async {
      final List<Map<String, dynamic>> topic = await value.query(
        'VocabularyTopics',
        where: 'topicId = ?',
        whereArgs: [topicId],
      );
      if (topic.isEmpty) {
        // No topic found with the given topicId
        return null;
      }
      return VocabularyTopic.fromSqliteMap(topic.first);
    });
  }
}
