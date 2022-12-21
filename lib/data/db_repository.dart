import 'dart:io';
import '../model/tarefa.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      // if _database is null we instantiate it
      _database = await initDB();
      return _database;
    }
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB2.db");

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE tarefas ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "title TEXT,"
            "ok BIT"
            ")");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        debugPrint("executando oupgrade");
        // await db.execute("CREATE TABLE tarefas ("
        //     "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        //     "title TEXT,"
        //     "ok BIT"
        //     ")");
      },
    );
  }

  newTask1(Tarefa newTask) async {
    final db = await database;
    var res = await db?.rawInsert("INSERT Into tarefas (title, ok)"
        " VALUES (${newTask.title},${newTask.ok})");
    return res;
  }

  newTask2(Tarefa newTask) async {
    final db = await database;
    var res = await db?.insert("tarefas", newTask.toJson());
    return res;
  }

  getOneTask(int id) async {
    final db = await database;
    var res = await db!.query("tarefas", where: "id = ?", whereArgs: [id]);

    var result = res.isNotEmpty ? Tarefa.fromJson(res.first) : null;
    debugPrint("one task -> $result");
    return result;
  }

  Future<List<Tarefa>> getAllTasks() async {
    final db = await database;
    var lista = <Tarefa>[];
    if (db != null) {
      var result = await db.query(
        "tarefas",
        orderBy: "ok,title ASC",
      );
      //debugPrint("dados no banco result $result");

      // ignore: avoid_function_literals_in_foreach_calls
      result.forEach((element) {
        lista.add(Tarefa(
            id: element["id"] as int,
            title: element["title"] as String,
            ok: element["ok"] as int));
      });
      return lista;
    } else {
      //debugPrint("sem dados ...");
      return [];
    }
  }

  getBlockedTask() async {
    final db = await database;

    var res = await db!.rawQuery("SELECT * FROM tarefas WHERE ok=1");

    List<Tarefa> list =
        res.isNotEmpty ? res.map((e) => Tarefa.fromJson(e)).toList() : [];

    return list;
  }

  updateTarefa(int id, String title, int ok) async {
    final db = await database;

    await db!.rawUpdate(
        "UPDATE tarefas set ok = ? where id = ? or title=?", [ok, id, title]);
  }

  updateTarefa2(Tarefa newTask) async {
    final db = await database;

    try {
      var res = db?.update('tarefas', newTask.toJson(),
          where: "id = ?", whereArgs: [newTask.id]);
      return res;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  blockUnblockedTask(Tarefa task) async {
    final db = await database;

    Tarefa taskBlocked = Tarefa(id: task.id, title: task.title, ok: task.ok);

    try {
      var res = db!.update("tarefas", taskBlocked.toJson(),
          where: "id = ?", whereArgs: [task.id]);

      return res;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  deleteTask(int id) async {
    try {
      final db = await database;
      db!.delete("tarefas", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  deleteAll() async {
    try {
      final db = await database;
      db!.rawDelete("Delete * from tarefas");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
