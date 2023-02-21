import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/auth/presentation/controllers/auth_controller.dart';
import 'package:toddle/featurers/home/presentation/screens/first_screen.dart';

class EditProfile extends ConsumerStatefulWidget {
  static const routename = "/edit-profile";
  const EditProfile({super.key});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends ConsumerState<EditProfile> {
  final editProfileKey = GlobalKey<FormState>();
  final chnagePasswordKey = GlobalKey<FormState>();

  //Fir Image Selecting
  final ImagePicker imagePicker = ImagePicker();
  File _image = File('');

  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  late String password;
  late String confirmPassword;
  late String oldPassword;

  final nameNode = FocusNode();
  final emailNode = FocusNode();
  final phoneNode = FocusNode();
  final addressNode = FocusNode();
  final passwordNode = FocusNode();
  final confirmPasswordNode = FocusNode();
  final oldPasswordNode = FocusNode();

  @override
  void dispose() {
    nameNode.dispose();
    emailNode.dispose();
    phoneNode.dispose();
    addressNode.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
    oldPasswordNode.dispose();
    ref.invalidate(authControllerProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ref.watch(authControllerProvider).when(
            data: (data) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02,
                    horizontal: screenSize.width * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Info',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(),
                      Form(
                        key: editProfileKey,
                        child: Column(
                          children: [
                            //Field For Name
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.01,
                              ),
                              child: TextFormField(
                                focusNode: nameNode,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(
                                    Icons.person_2_outlined,
                                  ),
                                ),
                                initialValue: data.name,
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
                                  FocusScope.of(context)
                                      .requestFocus(emailNode);
                                },
                              ),
                            ),

                            //Field For Email Address
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: TextFormField(
                                initialValue: data.email,
                                focusNode: emailNode,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                  ),
                                ),
                                readOnly: true,
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
                                  FocusScope.of(context)
                                      .requestFocus(passwordNode);
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),

                            //Field For Phone Number
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: TextFormField(
                                focusNode: phoneNode,
                                initialValue: data.phoneNumber,
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
                                  FocusScope.of(context)
                                      .requestFocus(addressNode);
                                },
                              ),
                            ),

                            //Field For Address Password
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: TextFormField(
                                initialValue: data.address,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                        : Image.network(
                                            '${ApiConstants.userImage}${data.profilePhoto}'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final picked =
                                          await imagePicker.pickImage(
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

                            //Save Button
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.02,
                              ),
                              child: Align(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  )),
                                  onPressed: () async {
                                    editProfileKey.currentState!.save();
                                    if (!editProfileKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    FormData formData;

                                    if (_image.path.isNotEmpty) {
                                      formData = FormData.fromMap({
                                        'name': name,
                                        'email': email,
                                        'phone': phone,
                                        'address': address,
                                        'profile_photo':
                                            await MultipartFile.fromFile(
                                                _image.path)
                                      });
                                    } else {
                                      formData = FormData.fromMap({
                                        'name': name,
                                        'email': email,
                                        'phone': phone,
                                        'address': address,
                                      });
                                    }
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .updateInfo(user: formData)
                                        .then((value) {
                                      if (value[0] == 'false') {
                                        toast(
                                            context: context,
                                            label: value[1],
                                            color: Colors.red);
                                      } else {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                FirstScreen.routeName);
                                        toast(
                                            context: context,
                                            label: value[1],
                                            color: Colors.green);
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Update Info',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenSize.height * 0.02),
                        child: Text(
                          'Update Password',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const Divider(),
                      Form(
                        key: chnagePasswordKey,
                        child: Column(
                          children: [
                            //Field For Old Password
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.03,
                              ),
                              child: TextFormField(
                                focusNode: oldPasswordNode,
                                decoration: const InputDecoration(
                                  labelText: 'Old Password',
                                  prefixIcon: Icon(
                                    Icons.password_outlined,
                                  ),
                                ),
                                obscureText: true,
                                onSaved: (newValue) {
                                  oldPassword = newValue!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Provide Old Password';
                                  } else {
                                    return null;
                                  }
                                },
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(passwordNode);
                                },
                                keyboardType: TextInputType.visiblePassword,
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
                                  FocusScope.of(context)
                                      .requestFocus(phoneNode);
                                },
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ),

                            //Update Password Button
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.02,
                              ),
                              child: Align(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  )),
                                  onPressed: () {
                                    chnagePasswordKey.currentState!.save();
                                    if (!chnagePasswordKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .changePassword(
                                            oldPassword: oldPassword,
                                            newPassword: password)
                                        .then((value) {
                                      if (value[0] == 'false') {
                                        toast(
                                            context: context,
                                            label: value[1],
                                            color: Colors.red);
                                      } else {
                                        Navigator.of(context).pop();
                                        toast(
                                            context: context,
                                            label: value[1],
                                            color: Colors.green);
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Update Password',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (e, s) => Text(e.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}
