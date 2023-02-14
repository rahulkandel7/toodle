import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/utils/app_drawer.dart';

import '../../../auth/presentation/screens/edit_profile.dart';
import 'home_screen.dart';

class FirstScreen extends ConsumerStatefulWidget {
  static const routeName = '/first-page';
  const FirstScreen({super.key});

  @override
  FirstScreenState createState() => FirstScreenState();
}

class FirstScreenState extends ConsumerState<FirstScreen> {
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

//For Getting User Name
  String username = '';

  Timer? time;
  Duration duration = const Duration(seconds: 1);

  //For Checking bio enable or not
  bool isBiometric = false;
  //For getting is login info
  _isBio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('name')!;
    });

    if (prefs.getBool('isBio')!) {
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
          username,
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            infocard(
              screenSize: screenSize,
              info: 'My Profile',
              function: () =>
                  Navigator.of(context).pushNamed(EditProfile.routename),
              icon: Icons.person,
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            infocard(
              screenSize: screenSize,
              info: 'Take Exam',
              function: () =>
                  Navigator.of(context).pushNamed(HomeScreen.routeName),
              icon: Icons.book,
            ),
          ],
        ),
      ),
      drawer: AppDrawer(
        screenSize: screenSize,
      ),
    );
  }

  infocard({
    required Size screenSize,
    required String info,
    required Function()? function,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: InkWell(
        onTap: function,
        child: Card(
          color: AppConstants.primaryColor,
          elevation: 5,
          shadowColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.02,
              horizontal: screenSize.width * 0.05,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: Theme.of(context).textTheme.displayLarge!.fontSize,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        info,
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
