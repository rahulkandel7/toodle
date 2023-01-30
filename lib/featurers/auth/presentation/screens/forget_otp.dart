import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/auth/presentation/controllers/auth_controller.dart';
import 'package:toddle/featurers/auth/presentation/screens/forget_change_password.dart';

class ForgetOtp extends StatefulWidget {
  static const String routeName = '/forget-otp';
  const ForgetOtp({super.key});

  @override
  State<ForgetOtp> createState() => _ForgetOtpState();
}

class _ForgetOtpState extends State<ForgetOtp> {
  final otpkey = GlobalKey<FormState>();
  late String code1;

  late String code2;

  late String code3;

  late String code4;

  late String code5;

  late String code6;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                "Enter 6-Digits Code:",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: otpkey,
                child: Row(
                  children: [
                    //Code 1
                    Padding(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: SizedBox(
                        width: screenSize.width * 0.13,
                        height: screenSize.height * 0.13,
                        child: TextFormField(
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onSaved: (newValue) {
                            code1 = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    //Code 2
                    Padding(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: SizedBox(
                        width: screenSize.width * 0.13,
                        height: screenSize.height * 0.13,
                        child: TextFormField(
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onSaved: (newValue) {
                            code2 = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    //Code 3
                    Padding(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: SizedBox(
                        width: screenSize.width * 0.13,
                        height: screenSize.height * 0.13,
                        child: TextFormField(
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onSaved: (newValue) {
                            code3 = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    //Code 4
                    Padding(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: SizedBox(
                        width: screenSize.width * 0.13,
                        height: screenSize.height * 0.13,
                        child: TextFormField(
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onSaved: (newValue) {
                            code4 = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    //Code 5
                    Padding(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: SizedBox(
                        width: screenSize.width * 0.13,
                        height: screenSize.height * 0.13,
                        child: TextFormField(
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onSaved: (newValue) {
                            code5 = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    //Code 6
                    Padding(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: SizedBox(
                        width: screenSize.width * 0.13,
                        height: screenSize.height * 0.13,
                        child: TextFormField(
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onSaved: (newValue) {
                            code6 = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return Center(
                    child: SizedBox(
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          otpkey.currentState!.save();
                          if (!otpkey.currentState!.validate()) {
                            return;
                          }
                          String codes = '$code1$code2$code3$code4$code5$code6';
                          ref
                              .read(authControllerProvider.notifier)
                              .codeCheck(codes)
                              .then((value) {
                            if (value[0] == 'false') {
                              toast(
                                  context: context,
                                  label: value[1],
                                  color: Colors.red);
                            } else {
                              Navigator.of(context).pushNamed(
                                  ForgetChangePassword.routeName,
                                  arguments: codes);
                              toast(
                                  context: context,
                                  label: value[1],
                                  color: Colors.green);
                            }
                          });
                        },
                        icon: const Icon(Icons.next_plan_outlined),
                        label: const Text(
                          'Continue',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
