import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/utils/app_drawer.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/home/presentation/controllers/exam_type_controller.dart';
import 'package:toddle/featurers/home/presentation/screens/first_screen.dart';

import 'widgets/exam_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
//For Getting User Name
  String username = '';

  //For getting is login info
  _getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      username = jsonDecode(prefs.getString('user')!)['name'];
    });
  }

  @override
  void initState() {
    super.initState();
    _getName();
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(FirstScreen.routeName),
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: ref.watch(examTypeControllerProvider).when(
            data: (data) {
              List<ExamType> examTypes =
                  data.where((exams) => exams.valid == true).toList();
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.height * 0.02,
                  horizontal: screenSize.width * 0.04,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Exam Type',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const Divider(),
                    SizedBox(
                      height: screenSize.height * 0.76,
                      child: ListView.builder(
                        itemBuilder: (ctx, i) => ExamCard(
                          examType: examTypes[i],
                        ),
                        itemCount: examTypes.length,
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (e, s) => Text(e.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      drawer: AppDrawer(
        screenSize: screenSize,
      ),
    );
  }
}
