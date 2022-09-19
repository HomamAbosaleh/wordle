import 'package:flutter/material.dart';
import 'package:game/count_down.dart';

import 'state_widget.dart';
import 'custom_dialog.dart';

class TextKey extends StatelessWidget {
  final String value;
  final int? correct;
  const TextKey({
    Key? key,
    required this.value,
    required this.correct,
  }) : super(key: key);

  bool isEqualOrDelete() {
    if (value == "⌦" || value == "➤") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateWidget = DataCenter.of(context);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          if (stateWidget.lockKeyboard) {
            return customDialog(
              context,
              true,
              widget: CountDown(stateWidget: stateWidget),
            );
          } else {
            try {
              if (stateWidget.searching) {
                return;
              }
              if (value == "⌦") {
                stateWidget.delete();
              } else if (value == "➤") {
                bool? value = await stateWidget.submit();
                if (value == false) {
                  return customDialog(context, false,
                      message: "Kelime listesinde yok");
                } else if (value == null) {
                  return customDialog(context, false,
                      message: "Lütfen boşluğu doldurun");
                }
              } else {
                stateWidget.write(value);
              }
            } catch (error) {
              error;
            }
          }
        },
        child: value == "➤" && stateWidget.searching
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Material(
                shape: isEqualOrDelete() ? const CircleBorder() : null,
                elevation: 20,
                shadowColor: Colors.white24,
                color: correct == null
                    ? Colors.grey
                    : correct == 1
                        ? Colors.green
                        : correct == 0
                            ? Colors.blue
                            : Colors.red,
                child: Container(
                  width: MediaQuery.of(context).size.width /
                      (isEqualOrDelete() ? 10 : 14.5),
                  alignment: AlignmentDirectional.center,
                  child: Padding(
                    padding: isEqualOrDelete()
                        ? EdgeInsets.fromLTRB(4, 0, 0, (value == "⌦") ? 1 : 0)
                        : const EdgeInsets.all(0),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
