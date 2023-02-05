import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/utils/biometric_auth.dart';
import 'package:toddle/featurers/auth/presentation/screens/forget_password_screen.dart';
import 'package:toddle/featurers/auth/presentation/screens/register_screen.dart';
import 'package:toddle/featurers/home/presentation/screens/home_screen.dart';

import '../../../../core/utils/toaster.dart';
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

    if (prefs.getBool('isBio')! == true) {
      setState(() {
        isLogged = true;
      });
    } else {
      setState(() {
        isLogged = false;
      });
    }
  }

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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Center Text For App Name
              Center(
                child: Text(
                  'Toddle App',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              //Text For Login Screen
              Text(
                'Proceed to Login,',
                style: Theme.of(context).textTheme.headlineSmall,
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
                          FocusScope.of(context).requestFocus(passwordNode);
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
                          Navigator.of(context)
                              .pushNamed(ForgetPasswordScreen.routeName);
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
                          padding:
                              EdgeInsets.only(top: screenSize.height * 0.00),
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () async {
                                    formKey.currentState!.save();
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .login(email, password)
                                        .then((value) {
                                      if (value[0] == 'false') {
                                        toast(
                                          context: context,
                                          label: value[1],
                                          color: Colors.red,
                                        );
                                      } else {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                HomeScreen.routeName);
                                        toast(
                                          context: context,
                                          label: value[1],
                                          color: Colors.green,
                                        );
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.login),
                                  label: const Text(
                                    'Login',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              .login(email, password)
              .then((value) {
            if (value[0] == 'false') {
              toast(
                context: context,
                label: value[1],
                color: Colors.red,
              );
            } else {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              toast(
                context: context,
                label: value[1],
                color: Colors.green,
              );
            }
          });
        }
      },
      style: FilledButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade200,
      ),
      child: const Icon(
        Icons.fingerprint_outlined,
      ),
    );
  }
}
