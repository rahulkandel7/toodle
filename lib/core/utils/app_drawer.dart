import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/auth/presentation/controllers/auth_controller.dart';
import 'package:toddle/featurers/auth/presentation/screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final Size screenSize;

  const AppDrawer({required this.screenSize, super.key});

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
              size: Theme.of(context).textTheme.headlineSmall!.fontSize,
            ),
            SizedBox(
              width: screenSize.width * 0.03,
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
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textButton(
                context: context,
                text: 'Edit Profile',
                icon: Icons.person_2_outlined,
              ),
              textButton(
                context: context,
                text: 'View Result',
                icon: Icons.newspaper_outlined,
              ),
              SizedBox(
                height: screenSize.height * 0.03,
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
                            Navigator.of(context)
                                .pushReplacementNamed(LoginScreen.routeName);
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
        ),
      ),
    );
  }
}
