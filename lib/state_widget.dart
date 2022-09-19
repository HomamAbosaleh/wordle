import 'package:game/sql_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'firestore.dart';
import 'http.dart';
import 'input_grid.dart';
import 'digit_input.dart';

class StateWidget extends StatefulWidget {
  final Widget child;
  const StateWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _StateWidgetState createState() => _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> with WidgetsBindingObserver {
  late SharedPreferences _prefs;
  late String winningWord;
  bool lockKeyboard = false;
  bool searching = true;
  List<InputGrid> listOfInputGrid = List.empty();
  List<List<Map<String, dynamic>>> wholeKeyBoard = [
    [
      {"symbol": "Q", "correct": null},
      {"symbol": "W", "correct": null},
      {"symbol": "E", "correct": null},
      {"symbol": "R", "correct": null},
      {"symbol": "T", "correct": null},
      {"symbol": "Y", "correct": null},
      {"symbol": "U", "correct": null},
      {"symbol": "I", "correct": null},
      {"symbol": "O", "correct": null},
      {"symbol": "P", "correct": null},
      {"symbol": "Ğ", "correct": null},
      {"symbol": "Ü", "correct": null},
    ],
    [
      {"symbol": "A", "correct": null},
      {"symbol": "S", "correct": null},
      {"symbol": "D", "correct": null},
      {"symbol": "F", "correct": null},
      {"symbol": "G", "correct": null},
      {"symbol": "H", "correct": null},
      {"symbol": "J", "correct": null},
      {"symbol": "K", "correct": null},
      {"symbol": "L", "correct": null},
      {"symbol": "Ş", "correct": null},
      {"symbol": "İ", "correct": null},
    ],
    [
      {"symbol": "⌦", "correct": null},
      {"symbol": "Z", "correct": null},
      {"symbol": "X", "correct": null},
      {"symbol": "C", "correct": null},
      {"symbol": "V", "correct": null},
      {"symbol": "B", "correct": null},
      {"symbol": "N", "correct": null},
      {"symbol": "M", "correct": null},
      {"symbol": "Ö", "correct": null},
      {"symbol": "Ç", "correct": null},
      {"symbol": "➤", "correct": null}
    ],
  ];

  void write(String value) {
    InputGrid inputGrid =
        listOfInputGrid.firstWhere((inputGrid) => inputGrid.active);
    inputGrid.listOfDigitInput
        .firstWhere((digitInput) => (digitInput.controller.text.isEmpty ||
            digitInput.controller.text == ""))
        .controller
        .text = value;
  }

  void delete() {
    InputGrid inputGrid =
        listOfInputGrid.firstWhere((inputGrid) => inputGrid.active);
    inputGrid.listOfDigitInput.reversed
        .firstWhere((digitInput) => digitInput.controller.text.isNotEmpty)
        .controller
        .text = "";
  }

  void colorizeLetter(int number, String letter) {
    for (var row in wholeKeyBoard) {
      for (var element in row) {
        if (element["symbol"] == letter) {
          element["correct"] = number;
        }
      }
    }
  }

  Future<bool?> submit() async {
    setState(() {
      searching = true;
    });

    InputGrid inputGrid =
        listOfInputGrid.firstWhere((inputGrid) => inputGrid.active);
    String enteredWord = "";

    for (var digitInput in inputGrid.listOfDigitInput) {
      enteredWord += digitInput.controller.text;
    }

    if (enteredWord.length < winningWord.length) {
      setState(() {
        searching = false;
      });
      return null;
    }

    if (enteredWord == "") {
      setState(() {
        searching = false;
      });
      return false;
    }

    var doesExist = await Http.checkIfWordExists(enteredWord);

    if (!doesExist) {
      setState(() {
        searching = false;
      });
      return false;
    }
    for (var i = 0; i < winningWord.length; i++) {
      var letter = winningWord.characters.elementAt(i);
      var digitInput = inputGrid.listOfDigitInput[i];

      if (digitInput.controller.text == letter) {
        digitInput.correct = 1;
        colorizeLetter(1, letter);
      }
    }
    for (var letter in winningWord.characters) {
      for (var digitInput in inputGrid.listOfDigitInput) {
        if (digitInput.correct != 1) {
          if (digitInput.controller.text == letter) {
            digitInput.correct = 0;
            colorizeLetter(0, letter);
          }
        }
      }
    }
    for (var digitInput in inputGrid.listOfDigitInput) {
      if (digitInput.correct != 1 && digitInput.correct != 0) {
        digitInput.correct = -1;
        colorizeLetter(-1, digitInput.controller.text);
      }
    }

    setState(() {
      searching = false;
      inputGrid.active = false;
      checkIfWon();
      listOfInputGrid = [...listOfInputGrid];
    });
    return true;
  }

  void checkIfWon() {
    InputGrid inputGrid =
        listOfInputGrid.lastWhere((inputGrid) => !inputGrid.active);
    try {
      inputGrid.listOfDigitInput.firstWhere(
          (digitInput) => digitInput.correct == -1 || digitInput.correct == 0);
    } catch (error) {
      lockKeyboard = true;
    }
  }

  void commonInitializeFunction() {
    listOfInputGrid = List.generate(
      winningWord.length + 1,
      (index) => InputGrid(
        size: winningWord.length,
        listOfDigitInput: List.generate(
          winningWord.length,
          (index) => DigitInput(
            controller: TextEditingController(),
            correct: null,
          ),
        ),
        active: true,
      ),
    );
    Sqlite().insertKeyboard(wholeKeyBoard);
    Sqlite().insertGrid(listOfInputGrid);
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((instance) async {
      _prefs = instance;
      winningWord = await FireStore().getWordOfTheDay();
      String? dateString = _prefs.getString("DATE");
      late DateTime date;
      late DateTime now;
      await Sqlite().initDatabase();
      if (dateString == null) {
        commonInitializeFunction();
      } else {
        date = DateTime.parse(dateString);
        now = DateTime.now();
        if (now.difference(date).inDays != 0) {
          await Sqlite().dropTables();
          commonInitializeFunction();
        } else {
          lockKeyboard = _prefs.getBool("LOCKKEYBOARD")!;
          listOfInputGrid = await Sqlite().fetchInputGrid(winningWord);
          wholeKeyBoard = await Sqlite().fetchKeyboard();
        }
      }
      setState(() {
        searching = false;
      });
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    for (var inputGrid in listOfInputGrid) {
      inputGrid.listOfDigitInput.map(
        (digitInput) => digitInput.controller.dispose(),
      );
    }
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.name.toString() == "paused" ||
        state.name.toString() == "inactive") {
      Sqlite().updateKeyboard(wholeKeyBoard).then((_) {
        Sqlite().updateGrid(listOfInputGrid).then((_) {
          _prefs.setBool("LOCKKEYBOARD", lockKeyboard).then((_) {
            _prefs.setString("DATE", DateTime.now().toString());
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataCenter(
      child: widget.child,
      stateWidget: this,
      searching: searching,
    );
  }
}

class DataCenter extends InheritedWidget {
  final _StateWidgetState stateWidget;
  final bool searching;
  const DataCenter({
    Key? key,
    required Widget child,
    required this.stateWidget,
    required this.searching,
  }) : super(key: key, child: child);

  static _StateWidgetState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DataCenter>()!.stateWidget;

  @override
  bool updateShouldNotify(DataCenter oldWidget) {
    return (oldWidget.searching != searching);
  }
}
