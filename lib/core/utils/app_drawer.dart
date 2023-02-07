import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/auth/presentation/controllers/auth_controller.dart';
import 'package:toddle/featurers/auth/presentation/screens/edit_profile.dart';
import 'package:toddle/featurers/auth/presentation/screens/login_screen.dart';
import 'package:toddle/featurers/my_paper/presentation/screens/view_paper_history.dart';

class AppDrawer extends StatefulWidget {
  final Size screenSize;

  const AppDrawer({required this.screenSize, super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? versionNumber;
  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionNumber = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  Widget textButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    Function()? function,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w500),
        ),
        onPressed: function,
        child: Row(
          children: [
            Icon(
              icon,
            ),
            SizedBox(
              width: widget.screenSize.width * 0.03,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.screenSize.height * 0.02,
            horizontal: widget.screenSize.width * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  textButton(
                    context: context,
                    text: 'Edit Profile',
                    icon: Icons.person_2_outlined,
                    function: () {
                      Navigator.of(context).pushNamed(EditProfile.routename);
                    },
                  ),
                  textButton(
                    context: context,
                    text: 'View Papers',
                    icon: Icons.newspaper_outlined,
                    function: () => Navigator.of(context)
                        .pushNamed(ViewPaperHistory.routeName),
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
                  SizedBox(
                    height: widget.screenSize.height * 0.03,
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
    );
  }
}
