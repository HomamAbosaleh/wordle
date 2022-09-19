import 'dart:async';

import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  final stateWidget;
  const CountDown({Key? key, required this.stateWidget}) : super(key: key);

  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late String winningWord;
  Duration? duration;
  Timer? timer;

  void startCountdown() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => subtractTime(),
    );
  }

  void subtractTime() {
    const int addSeconds = -1;

    setState(() {
      final seconds = duration!.inSeconds + addSeconds;
      if (seconds > -1) {
        duration = Duration(seconds: seconds);
      } else {
        timer!.cancel();
      }
    });
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration!.inHours);
    final minutes = twoDigits(duration!.inMinutes.remainder(60));
    final seconds = twoDigits(duration!.inSeconds.remainder(60));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeCard(time: hours, header: "SAAT"),
        const SizedBox(width: 8),
        buildTimeCard(time: minutes, header: "DAKİKA"),
        const SizedBox(width: 8),
        buildTimeCard(time: seconds, header: 'SANİYE'),
      ],
    );
  }

  Widget buildTimeCard({required String time, required String header}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 72,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          header,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String capitalize(word) {
    return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
  }

  @override
  void initState() {
    winningWord = capitalize(widget.stateWidget.winningWord);
    DateTime now = DateTime.now();
    duration = Duration(
        seconds: DateTime(now.year, now.month, now.day + 1)
            .difference(now)
            .inSeconds);
    startCountdown();
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          height: MediaQuery.of(context).size.height / 3,
          color: Colors.black54,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.spaceEvenly,
            children: [
              widget.stateWidget.lockKeyboard
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Wordle: " + winningWord,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "GELECEK WORDLE",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                child: buildTime(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
