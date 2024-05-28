import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:todolist/uitilities/notification_helper.dart';

class DatabaseHelper {
  static Future<sql.Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'todo1.db'),
      onCreate: (db, version) {
        var batch = db.batch();
        batch.execute(
            'CREATE TABLE todolist(tid INTEGER PRIMARY KEY AUTOINCREMENT,catid INTEGER,catname TEXT,tododetails TEXT,date DATETIME DEFAULT NULL,time DATETIME DEFAULT NULL,alarm BOOL,status TEXT)');
        batch.execute(
            'CREATE TABLE category(catid INTEGER PRIMARY KEY AUTOINCREMENT, catname TEXT)');
        batch.execute(
            "INSERT INTO category (catid, catname) VALUES (1, 'Default')");
        batch.execute("INSERT INTO category (catname) VALUES ('Work')");
        batch.execute("INSERT INTO category (catname) VALUES ('Personal')");
        batch.execute("INSERT INTO category (catname) VALUES ('Shopping')");
        batch.execute("INSERT INTO category (catname) VALUES ('Other')");
        batch.commit();
      },
      version: 1,
    );
    print('Database created successfully');
    print(dbPath.toString());
    return db;
  }

  static Future<void> dropDatabase(String dbName) async {
    var databasesPath = await sql.getDatabasesPath();
    String pat = path.join(databasesPath, dbName);
    await sql.deleteDatabase(pat);
    print('Database deleted successfully');
  }

  static Future<void> updateToDoStatus(int id, bool isChecked) async {
    final sql.Database db = await getDatabase();

    // Get the current status from the database
    List<Map<String, dynamic>> results = await db.query(
      'todolist',
      columns: ['status'],
      where: 'tid = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      String currentStatus = results.first['status'] as String;

      // Determine the new status based on the current status and the checkbox state
      String newStatus = isChecked
          ? currentStatus == 'Completed'
              ? 'Not Completed'
              : 'Completed'
          : currentStatus;

      // Update the status in the database
      await db.update(
        'todolist',
        {'status': newStatus},
        where: 'tid = ?',
        whereArgs: [id],
      );

      // If the new status is 'Not Completed', schedule the notification
      if (newStatus == 'Not Completed') {
        // Retrieve the task details from the database
        List<Map<String, dynamic>> taskDetails = await db.query(
          'todolist',
          columns: ['tododetails', 'date'],
          where: 'tid = ?',
          whereArgs: [id],
        );

        if (taskDetails.isNotEmpty) {
          String todoDetails = taskDetails.first['tododetails'] as String;
          String? dateString = taskDetails.first['date'] as String?;

          if (dateString != null) {
            DateTime dueDate = DateTime.parse(dateString);

            // Schedule notification
            await NotificationHelper.scheduleNotification(
                id, todoDetails, dueDate);
          }
        }
      } else {
        // If the status is 'Completed', cancel the notification
        await NotificationHelper.cancelNotification(id);
      }
    }
  }
}
