import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/darkmode_notifier.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/auth/presentation/controllers/auth_controller.dart';
import 'package:toddle/featurers/home/presentation/screens/home_screen.dart';
import 'package:toddle/featurers/notices/presentation/screens/notice_screen.dart';

import '../../featurers/auth/presentation/screens/edit_profile.dart';
import '../../featurers/auth/presentation/screens/login_screen.dart';
import '../../featurers/my_paper/presentation/screens/view_paper_history.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final Size screenSize;

  const AppDrawer({required this.screenSize, super.key});

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends ConsumerState<AppDrawer> {
  String? versionNumber;

  String username = "";
  String userImage = "";

  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionNumber = packageInfo.version;
    });
  }

  bool isBio = false;
  bool supportBio = false;

  _isBio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    bool isBioMetric =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();

    setState(() {
      username = jsonDecode(prefs.getString('user')!)['name'];
      userImage = jsonDecode(prefs.getString('user')!)['profile_photo'];
      supportBio = isBioMetric;
    });

    if (prefs.getBool('isBio')! == true) {
      setState(() {
        isBio = true;
      });
    } else {
      setState(() {
        isBio = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAppVersion();
    _isBio();
  }

  Widget textButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    Function()? function,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        bool darkmode = ref.watch(darkmodeNotifierProvider);
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            onPressed: function,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: darkmode ? Colors.white : AppConstants.primaryColor,
                ),
                SizedBox(
                  width: widget.screenSize.width * 0.03,
                ),
                Text(
                  text,
                  style: TextStyle(
                      color:
                          darkmode ? Colors.white : AppConstants.primaryColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var darkmode = ref.watch(darkmodeNotifierProvider);
    Size screenSize = MediaQuery.of(context).size;
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.screenSize.height * 0.02,
            horizontal: widget.screenSize.width * 0.04,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userImage.isNotEmpty
                        ? Center(
                            child: CircleAvatar(
                              radius: screenSize.height * 0.05,
                              foregroundImage: NetworkImage(
                                  '${ApiConstants.userImage}$userImage'),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: Text(
                        'Learn',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    textButton(
                      context: context,
                      text: 'Practice Sets',
                      icon: Icons.pending_actions_outlined,
                      function: () {
                        Navigator.of(context).pushNamed(HomeScreen.routeName);
                      },
                    ),
                    textButton(
                      context: context,
                      text: 'My Papers',
                      icon: Icons.newspaper_outlined,
                      function: () => Navigator.of(context)
                          .pushNamed(ViewPaperHistory.routeName),
                    ),
                    textButton(
                      context: context,
                      text: 'Notices',
                      icon: Icons.notifications_none_sharp,
                      function: () => Navigator.of(context)
                          .pushNamed(NoticeScreen.routeName),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: Text(
                        'Settings',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    textButton(
                      context: context,
                      text: 'Edit Profile',
                      icon: Icons.person_2_outlined,
                      function: () {
                        Navigator.of(context).pushNamed(EditProfile.routename);
                      },
                    ),
                    supportBio
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biometric Login',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: darkmode
                                          ? Colors.white
                                          : AppConstants.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Switch(
                                value: isBio,
                                onChanged: (value) async {
                                  setState(() {
                                    isBio = value;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('isBio', value);
                                },
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: darkmode
                                    ? Colors.white
                                    : AppConstants.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Switch(
                          value: darkmode,
                          onChanged: (value) async {
                            ref
                                .read(darkmodeNotifierProvider.notifier)
                                .toggle();
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: Text(
                        'General',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    textButton(
                      context: context,
                      text: 'About',
                      icon: Icons.info_outline_rounded,
                      function: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              icon: const Icon(Icons.info_outline_rounded),
                              title: const Text('About Developer'),
                              content: SizedBox(
                                height: widget.screenSize.height * 0.2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Toddle'),
                                    Text('Version: $versionNumber'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Text(
                                        'Developed By Bitmap I.T. Solution'),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.location_city_rounded),
                                        Text(
                                          'Belchowk,Narayanghat',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.call),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '056-596250',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.phone_android_outlined),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '9855011559, 9865042465',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                FilledButton.tonal(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Close',
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    textButton(
                      context: context,
                      text: 'Rate Us',
                      icon: Icons.star,
                      function: () => Navigator.of(context)
                          .pushNamed(ViewPaperHistory.routeName),
                    ),
                    textButton(
                      context: context,
                      text: 'Share App',
                      icon: Icons.share,
                      function: () => Navigator.of(context)
                          .pushNamed(ViewPaperHistory.routeName),
                    ),
                    textButton(
                      context: context,
                      text: 'Follow Us',
                      icon: Icons.facebook,
                      function: () => Navigator.of(context)
                          .pushNamed(ViewPaperHistory.routeName),
                    ),
                    const Divider(),
                    SizedBox(
                      height: widget.screenSize.height * 0.01,
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return textButton(
                            context: context,
                            text: 'Log Out',
                            icon: Icons.logout_outlined,
                            function: () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .logout()
                                  .then((value) {
                                if (value[0] == 'false') {
                                  toast(
                                    context: context,
                                    label: value[1],
                                    color: Colors.red,
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pushReplacementNamed(
                                      LoginScreen.routeName);
                                  toast(
                                      context: context,
                                      label: value[1],
                                      color: Colors.green);
                                }
                              });
                            });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Center(
                      child: Text(
                        'Version: $versionNumber',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Powered BY: BITS',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
