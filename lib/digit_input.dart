import 'package:flutter/material.dart';

import '/state_widget.dart';

class DigitInput extends StatelessWidget {
  int? correct;
  final TextEditingController controller;
  DigitInput({
    Key? key,
    required this.controller,
    required this.correct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataCenter.of(context);
    return Material(
      elevation: 20,
      shadowColor: Colors.grey,
      child: Container(
        alignment: AlignmentDirectional.center,
        width: MediaQuery.of(context).size.width / 6,
        height: MediaQuery.of(context).size.height / 7,
        decoration: BoxDecoration(
          border: Border.all(
            color: correct == null
                ? Colors.grey
                : correct == 1
                    ? Colors.green
                    : correct == 0
                        ? Colors.blue
                        : Colors.red,
          ),
          color: Colors.black,
        ),
        child: TextField(
          textAlign: TextAlign.center,
          controller: controller,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            enabled: false,
          ),
        ),
      ),
    );
  }
}
