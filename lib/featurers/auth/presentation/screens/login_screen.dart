// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/utils/biometric_auth.dart';
import 'package:toddle/featurers/auth/presentation/screens/forget_password_screen.dart';
import 'package:toddle/featurers/auth/presentation/screens/register_screen.dart';
import 'package:toddle/featurers/home/presentation/screens/first_screen.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_answers.dart';
import 'package:toddle/featurers/offline_storage/presentation/screens/downloaded_exam_screen.dart';

import '../../../../constants/api_constants.dart';
import '../../../../core/utils/toaster.dart';
import '../../../offline_storage/data/sources/offline_data_source.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailNode = FocusNode();
  final passwordNode = FocusNode();

  late String email;
  late String password;

  bool isLogged = false;
  //For getting is login info
  _isBio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isBio') == true) {
      setState(() {
        isLogged = true;
      });
    } else {
      setState(() {
        isLogged = false;
      });
    }
  }

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isBio();
  }

  @override
  void dispose() {
    emailNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<Box<OfflineAnswers>>(
      valueListenable: OfflineDataSource.getOfflineAnswers().listenable(),
      builder: ((context, box, _) {
        final offlinePlayedQuiz = box.values.toList().cast<OfflineAnswers>();

        return Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Positioned(
                  top: -screenSize.height * 0.1,
                  left: -screenSize.width * 0.33,
                  child: CircleAvatar(
                    maxRadius: screenSize.width * 0.3,
                  ),
                ),
                Positioned(
                  bottom: -screenSize.height * 0.1,
                  right: -screenSize.width * 0.33,
                  child: CircleAvatar(
                    maxRadius: screenSize.width * 0.3,
                  ),
                ),
                //App Logo,form and buttons

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02,
                    horizontal: screenSize.width * 0.04,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenSize.height * 0.1,
                      ),
                      //Center Text For App Name
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: screenSize.width * 0.58,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //Text For Login Screen
                      Center(
                        child: Text(
                          'Welcome to Toodle',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Dreams Come True',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),

                      //Form For Login
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            //Field For Email
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: TextFormField(
                                focusNode: emailNode,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                  ),
                                ),
                                onSaved: (newValue) {
                                  email = newValue!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Provide Email Address';
                                  } else if (!value.contains('@')) {
                                    return 'Please Provide valid Email Address';
                                  } else {
                                    return null;
                                  }
                                },
                                keyboardType: TextInputType.emailAddress,
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(passwordNode);
                                },
                              ),
                            ),

                            //Field For Password
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: TextFormField(
                                focusNode: passwordNode,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.password_outlined,
                                  ),
                                ),
                                obscureText: true,
                                onSaved: (newValue) {
                                  password = newValue!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Provide Password';
                                  } else {
                                    return null;
                                  }
                                },
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ),

                            //Forget Password Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      ForgetPasswordScreen.routeName);
                                },
                                child: const Text(
                                  'Forget Password?',
                                ),
                              ),
                            ),

                            //Login Button
                            Consumer(
                              builder: (context, ref, child) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: screenSize.height * 0.00),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: isProcessing
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    isProcessing = true;
                                                  });
                                                  formKey.currentState!.save();
                                                  if (!formKey.currentState!
                                                      .validate()) {
                                                    return;
                                                  }

                                                  loginFunction(ref, context,
                                                      offlinePlayedQuiz);
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.login),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('Login'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      isLogged
                                          ? Row(
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                biometricLogin(ref, context),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                );
                              },
                            ),

                            //Signup Button
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(RegisterScreen.routeName);
                                },
                                child: const Text(
                                  "Don't Have an Account? Create Now",
                                ),
                              ),
                            ),

                            // Offline Button
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                              ),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(DownloadedExamScreens.routeName),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.offline_bolt_outlined),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Go Offline'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  void loginFunction(WidgetRef ref, BuildContext context,
      List<OfflineAnswers> offAnswers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password)
        .then((value) async {
      if (value[0] == 'false') {
        toast(
          context: context,
          label: value[1],
          color: Colors.red,
        );
      } else {
        if (offAnswers.isNotEmpty) {
          for (var offlinePlayed in offAnswers) {
            var data = {
              'questions': offlinePlayed.questions.toString(),
              'answers': offlinePlayed.answers
            };
            final Dio dio = Dio(
              BaseOptions(
                baseUrl: ApiConstants.url,
                headers: {
                  'accept': 'application/json',
                  'Authorization': 'Bearer ${prefs.getString('token')}',
                },
              ),
            );

            await dio.post('submitexam', data: data);
          }
        }
        Navigator.of(context).pushReplacementNamed(FirstScreen.routeName);
        toast(
          context: context,
          label: value[1],
          color: Colors.green,
        );
      }
    });
  }

  FilledButton biometricLogin(WidgetRef ref, BuildContext context) {
    return FilledButton(
      onPressed: () async {
        bool isBiometric = await BiometricAuth.authenticateWithBiometrics();
        if (isBiometric) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String email = prefs.getString('email') ?? '';
          String password = prefs.getString('password') ?? '';
          ref
              .read(authControllerProvider.notifier)
              .login(
                email: email,
                password: password,
              )
              .then((value) {
            if (value[0] == 'false') {
              toast(
                context: context,
                label: value[1],
                color: Colors.red,
              );
            } else {
              Navigator.of(context).pushReplacementNamed(FirstScreen.routeName);
              toast(
                context: context,
                label: value[1],
                color: Colors.green,
              );
            }
          });
        }
      },
      child: const Icon(
        Icons.fingerprint_outlined,
      ),
    );
  }
}
