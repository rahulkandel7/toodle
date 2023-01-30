import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    final formKey = GlobalKey<FormState>();

    late String email;
    late String password;

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
                    //Field For Login
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.height * 0.03,
                      ),
                      child: TextFormField(
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
                      ),
                    ),

                    //Field For Password
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.height * 0.03,
                      ),
                      child: TextFormField(
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
                                  onPressed: () {
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
}
