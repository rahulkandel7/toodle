import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toddle/featurers/auth/presentation/screens/login_screen.dart';

import '../../../../core/utils/toaster.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  late String name;
  late String email;
  late String phone;
  late String address;
  late String password;
  late String confirmPassword;

  final nameNode = FocusNode();
  final emailNode = FocusNode();
  final phoneNode = FocusNode();
  final addressNode = FocusNode();
  final passwordNode = FocusNode();
  final confirmPasswordNode = FocusNode();

  //File Picker
  File _image = File('');

  final ImagePicker imagePicker = ImagePicker();

  @override
  void dispose() {
    nameNode.dispose();
    emailNode.dispose();
    phoneNode.dispose();
    addressNode.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
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
          child: SingleChildScrollView(
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
                  'Proceed to Register,',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                //Form For Login
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      //Field For Name
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height * 0.03,
                        ),
                        child: TextFormField(
                          focusNode: nameNode,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(
                              Icons.person_2_outlined,
                            ),
                          ),
                          onSaved: (newValue) {
                            name = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Provide Full Name';
                            } else {
                              return null;
                            }
                          },
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(emailNode);
                          },
                        ),
                      ),

                      //Field For Email Address
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
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(passwordNode);
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
                          onEditingComplete: () {
                            FocusScope.of(context)
                                .requestFocus(confirmPasswordNode);
                          },
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),

                      //Field For Confirm Password
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height * 0.03,
                        ),
                        child: TextFormField(
                          focusNode: confirmPasswordNode,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(
                              Icons.password_outlined,
                            ),
                          ),
                          obscureText: true,
                          onSaved: (newValue) {
                            confirmPassword = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Provide Confirm Password';
                            } else if (password != confirmPassword) {
                              return "Password and Confirm Password Doesn't Match";
                            } else {
                              return null;
                            }
                          },
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(phoneNode);
                          },
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),

                      //Field For Phone Number
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height * 0.03,
                        ),
                        child: TextFormField(
                          focusNode: phoneNode,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(
                              Icons.phone_android_outlined,
                            ),
                          ),
                          onSaved: (newValue) {
                            phone = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Provide Phone Number';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.phone,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(addressNode);
                          },
                        ),
                      ),

                      //Field For Address Password
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height * 0.03,
                        ),
                        child: TextFormField(
                          focusNode: addressNode,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                            ),
                          ),
                          onSaved: (newValue) {
                            address = newValue!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Provide Your Address';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height * 0.03,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: screenSize.width * 0.5,
                              height: screenSize.height * 0.2,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                ),
                                shape: BoxShape.rectangle,
                              ),
                              child: _image.path.isNotEmpty
                                  ? Image.file(
                                      _image,
                                    )
                                  : const Center(child: Text('No Image')),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await imagePicker.pickImage(
                                    source: ImageSource.gallery);
                                if (picked != null) {
                                  setState(() {
                                    _image = File(picked.path);
                                  });
                                }
                              },
                              child: const Text(
                                'Select Image',
                              ),
                            ),
                          ],
                        ),
                      ),

                      //REGISTER Button
                      Consumer(
                        builder: (context, ref, child) {
                          return Padding(
                            padding:
                                EdgeInsets.only(top: screenSize.height * 0.02),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () async {
                                      formKey.currentState!.save();
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      if (_image.path.isEmpty) {
                                        toast(
                                            context: context,
                                            label: 'Select Image',
                                            color: Colors.red);
                                      } else {
                                        await registerUser(ref, context);
                                      }
                                    },
                                    child: const Text(
                                      'Register',
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
                                .pushNamed(LoginScreen.routeName);
                          },
                          child: const Text(
                            "Already Have a Account? Sign In Now",
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
      ),
    );
  }

  Future<void> registerUser(WidgetRef ref, BuildContext context) async {
    FormData formData;
    formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'phone': phone,
      'address': address,
      'profile_photo': await MultipartFile.fromFile(_image.path)
    });
    ref.read(authControllerProvider.notifier).register(formData).then((value) {
      if (value[0] == 'false') {
        toast(
          context: context,
          label: value[1],
          color: Colors.red,
        );
      } else {
        toast(
          context: context,
          label: value[1],
          color: Colors.green,
        );
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    });
  }
}
