import 'package:flutter/material.dart';

import 'digit_input.dart';

class InputGrid extends StatelessWidget {
  final int size;
  final List<DigitInput> listOfDigitInput;
  bool active;
  InputGrid({
    Key? key,
    required this.size,
    required this.listOfDigitInput,
    required this.active,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: size,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: listOfDigitInput[index],
          );
        },
      ),
    );
  }
}
