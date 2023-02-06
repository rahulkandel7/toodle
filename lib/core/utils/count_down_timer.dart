import 'dart:async';

import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final Duration time;
  final Function onSubmit;
  const CountDownTimer({required this.time, required this.onSubmit, super.key});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  //Timer For Question
  Timer? countDownTimer;
  Duration duration = const Duration();

  void startTimer() {
    countDownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countDownTimer!.cancel());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        widget.onSubmit();
        countDownTimer!.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    duration = widget.time;
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    countDownTimer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(duration.inHours.remainder(24));
    final minutes = strDigits(duration.inMinutes.remainder(60));
    final seconds = strDigits(duration.inSeconds.remainder(60));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        hours == '00'
            ? Text(
                '$minutes:$seconds',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            : Text(
                '$hours:$minutes:$seconds',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
      ],
    );
  }
}
