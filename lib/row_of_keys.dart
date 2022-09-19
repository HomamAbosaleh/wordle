import 'package:flutter/material.dart';

import 'text_key.dart';

class RowOfKeys extends StatelessWidget {
  final List letters;
  const RowOfKeys({
    Key? key,
    required this.letters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: letters.length,
        itemBuilder: (context, index) {
          return TextKey(
            value: letters[index]["symbol"],
            correct: letters[index]["correct"],
          );
        },
      ),
    );
  }
}
