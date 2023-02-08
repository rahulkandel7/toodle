import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/utils/app_drawer.dart';
import 'package:toddle/featurers/home/presentation/controllers/exam_type_controller.dart';

import 'widgets/exam_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  //Show Prompt for enable biometric login
  showPrompt() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Do you want to use biometric login ?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs
                  .setBool('isBio', true)
                  .then((_) => Navigator.of(context).pop());
            },
            child: const Text(
              'Yes',
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs
                  .setBool('isBio', false)
                  .then((_) => Navigator.of(context).pop());
            },
            child: const Text(
              'No',
            ),
          ),
        ],
      ),
    );
  }

  Timer? time;
  Duration duration = const Duration(seconds: 1);

  //For Checking bio enable or not
  bool isBiometric = false;
  //For getting is login info
  _isBio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isBio')! == true) {
      setState(() {
        isBiometric = true;
      });
    } else {
      setState(() {
        isBiometric = false;
      });
    }
  }

  void startTimer() {
    time = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        if (!isBiometric) {
          showPrompt();
        }
        time!.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isBio();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    time!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toddle',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.person_2_outlined,
              ),
            );
          }),
        ],
      ),
      body: ref.watch(examTypeControllerProvider).when(
            data: (data) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.height * 0.02,
                  horizontal: screenSize.width * 0.04,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam Resources',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemBuilder: (ctx, i) => ExamCard(
                          examType: data[i],
                        ),
                        itemCount: data.length,
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (e, s) => Text(e.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      drawer: AppDrawer(
        screenSize: screenSize,
      ),
    );
  }
}
