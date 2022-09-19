import 'package:flutter/material.dart';

import 'row_of_keys.dart';
import 'state_widget.dart';

class KeyBoard extends StatelessWidget {
  const KeyBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateWidget = DataCenter.of(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: stateWidget.wholeKeyBoard.length,
        itemBuilder: (context, index) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RowOfKeys(
                letters: stateWidget.wholeKeyBoard[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
