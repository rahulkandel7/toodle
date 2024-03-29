import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toddle/constants/app_constants.dart';

class CountDownTimer extends StatefulWidget {
  final Duration time;
  final Function onSubmit;
  final bool isStart;
  const CountDownTimer(
      {required this.time,
      required this.onSubmit,
      required this.isStart,
      super.key});

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

      if (seconds % 180 == 0 && widget.isStart) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Do not move your head. टाउको नघुमाउनुहोस ।',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.of(context).size.width * 0.4,
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
          ),
        );
      }
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
    stopTimer();
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppConstants.quizScreen),
              )
            : Text(
                '$hours:$minutes:$seconds',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppConstants.quizScreen,
                    ),
              ),
      ],
    );
  }
}
