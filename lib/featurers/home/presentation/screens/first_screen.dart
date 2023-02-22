import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/utils/app_drawer.dart';
import 'package:toddle/featurers/auth/presentation/screens/edit_profile.dart';
import 'package:toddle/featurers/my_paper/presentation/screens/view_paper_history.dart';
import 'package:toddle/featurers/notices/presentation/screens/notice_screen.dart';

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
  String userImage = '';

  Timer? time;
  Duration duration = const Duration(seconds: 1);

  //For Checking bio enable or not
  bool isBiometric = false;
  //For getting is login info
  _isBio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      username = jsonDecode(prefs.getString('user')!)['name'];
      userImage = jsonDecode(prefs.getString('user')!)['profile_photo'];
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
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.menu,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              foregroundImage:
                  NetworkImage('${ApiConstants.userImage}$userImage'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Welcome to EPS Topik Practice',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infocard(
                  screenSize: screenSize,
                  info: 'My Papers',
                  function: () => Navigator.of(context)
                      .pushNamed(ViewPaperHistory.routeName),
                  image: 'assets/images/mypaper.png',
                ),
                infocard(
                  screenSize: screenSize,
                  info: 'Take Exam',
                  function: () =>
                      Navigator.of(context).pushNamed(HomeScreen.routeName),
                  image: 'assets/images/take-exam.png',
                ),
              ],
            ),
            SizedBox(
              height: screenSize.height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infocard(
                  screenSize: screenSize,
                  info: 'Notices',
                  function: () =>
                      Navigator.of(context).pushNamed(NoticeScreen.routeName),
                  image: 'assets/images/notice.png',
                ),
                infocard(
                  screenSize: screenSize,
                  info: 'Edit Profile',
                  function: () =>
                      Navigator.of(context).pushNamed(EditProfile.routename),
                  image: 'assets/images/edit-profile.png',
                ),
              ],
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
    required String image,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: InkWell(
        onTap: function,
        child: Container(
          width: screenSize.width * 0.44,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 4,
                offset: const Offset(1, 2),
                // blurStyle: BlurStyle.outer,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(
              10,
            ),
            color: AppConstants.primaryColor,
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
                  CircleAvatar(
                    backgroundColor: AppConstants.cardColor,
                    radius: screenSize.height * 0.05,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(image),
                    ),
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
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
