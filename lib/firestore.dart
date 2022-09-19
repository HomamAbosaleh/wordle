import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FireStore {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  String _toUpperCase(String word) {
    String upperCased = "";

    for (var letter in word.characters) {
      if (letter == "i") {
        upperCased += "İ";
      } else {
        upperCased += letter.toUpperCase();
      }
    }

    return upperCased;
  }

  Future<String> getWordOfTheDay() async {
    DateTime now = DateTime.now();
    return _toUpperCase((await _firebaseFirestore
        .collection("words")
        .doc(now.day.toString())
        .get())["word"] as String);
  }
}
