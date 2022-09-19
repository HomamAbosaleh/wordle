import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

import 'digit_input.dart';
import 'input_grid.dart';

class Sqlite {
  static late sql.Database _instance;

  Future<void> createTables() async {
    await _instance.execute('''
        CREATE TABLE IF NOT EXISTS keys (
          symbol TEXT PRIMARY KEY,
          correct INTEGER,
          row INTEGER NOT NULL
        );
      ''');
    await _instance.execute('''
        CREATE TABLE IF NOT EXISTS grids (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          active INTEGER NOT NULL
        );
      ''');
    await _instance.execute('''
        CREATE TABLE IF NOT EXISTS inputs (
          id TEXT PRIMARY KEY,
          symbol TEXT DEFAULT "" NOT NULL,
          correct INTEGER
        );
      ''');
  }

  Future<void> initDatabase() async {
    final sqlPath = await sql.getDatabasesPath();
    _instance = await sql.openDatabase(path.join(sqlPath, 'localDatabase.db'),
        version: 1);
    await createTables();
  }

  Future<void> dropTables() async {
    await _instance.execute('DROP TABLE IF EXISTS keys');
    await _instance.execute('DROP TABLE IF EXISTS inputs');
    await _instance.execute("DROP TABLE IF EXISTS grids");
    await createTables();
  }

  Future<List<List<Map<String, dynamic>>>> fetchKeyboard() async {
    List<List<Map<String, dynamic>>> keyboard = [[], [], []];

    var list = await _instance.query("keys");
    for (var item in list) {
      keyboard[item["row"] as int].add(
        {
          "symbol": item["symbol"] as String,
          "correct": item["correct"] as int?,
        },
      );
    }

    return keyboard;
  }

  Future<void> insertKeyboard(List keyboard) async {
    for (var row in keyboard) {
      for (var key in row) {
        await _instance.insert(
          "keys",
          {
            "symbol": key["symbol"],
            "correct": key["correct"],
            "row": keyboard.indexOf(row),
          },
        );
      }
    }
  }

  Future<void> updateKeyboard(List keyboard) async {
    for (var row in keyboard) {
      for (var key in row) {
        if (key["correct"] == null) {
          continue;
        }
        await _instance.update(
          "keys",
          {
            "correct": key["correct"],
          },
          where: "symbol = ?",
          whereArgs: [
            key["symbol"],
          ],
        );
      }
    }
  }

  Future<List<InputGrid>> fetchInputGrid(String word) async {
    List<InputGrid> inputGrid = List.generate(
      word.length + 1,
      (index) => InputGrid(
        size: word.length,
        listOfDigitInput: List.generate(
          word.length,
          (index) => DigitInput(
            controller: TextEditingController(),
            correct: null,
          ),
        ),
        active: true,
      ),
    );

    var listGrid = await _instance.query("grids");
    var listInputs = await _instance.query("inputs");
    for (int i = 0; i < listGrid.length; i++) {
      bool active = listGrid[i]["active"] == 0 ? false : true;

      if (active) {
        continue;
      }

      var targetedList = listInputs
          .where((input) =>
              int.parse(input["id"].toString().characters.first) == i)
          .toList();

      for (Map<String, dynamic> row in targetedList) {
        inputGrid[i]
            .listOfDigitInput[int.parse(row["id"].toString().characters.last)]
            .correct = row["correct"] as int?;
        inputGrid[i]
            .listOfDigitInput[int.parse(row["id"].toString().characters.last)]
            .controller
            .text = row["symbol"] as String;
      }
      inputGrid[i].active = active;
    }

    return inputGrid;
  }

  Future<void> insertGrid(List<InputGrid> listOfInputGrid) async {
    for (int i = 0; i < listOfInputGrid.length; i++) {
      await _instance.insert(
        "grids",
        {
          "active": listOfInputGrid[i].active ? 1 : 0,
        },
      );
      for (var digitInput in listOfInputGrid[i].listOfDigitInput) {
        await _instance.insert(
          "inputs",
          {
            "id": i.toString() +
                listOfInputGrid[i]
                    .listOfDigitInput
                    .indexOf(digitInput)
                    .toString(),
            "symbol": digitInput.controller.text,
            "correct": digitInput.correct,
          },
        );
      }
    }
  }

  Future<void> updateGrid(List<InputGrid> listOfInputGrid) async {
    for (int i = 0; i < listOfInputGrid.length; i++) {
      if (listOfInputGrid[i].active) {
        continue;
      }
      await _instance.update(
        "grids",
        {
          "active": listOfInputGrid[i].active ? 1 : 0,
        },
        where: "id = ?",
        whereArgs: [i + 1],
      );
      for (var digitInput in listOfInputGrid[i].listOfDigitInput) {
        await _instance.update(
          "inputs",
          {
            "symbol": digitInput.controller.text,
            "correct": digitInput.correct,
          },
          where: "id = ?",
          whereArgs: [
            i.toString() +
                listOfInputGrid[i]
                    .listOfDigitInput
                    .indexOf(digitInput)
                    .toString()
          ],
        );
      }
    }
  }
}
