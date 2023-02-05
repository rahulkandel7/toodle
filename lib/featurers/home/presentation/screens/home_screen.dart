import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/utils/app_drawer.dart';
import 'package:toddle/featurers/home/presentation/controllers/exam_type_controller.dart';

import 'widgets/exam_card.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toddle',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.person_2_outlined,
              ),
            );
          }),
        ],
      ),
      body: ref.watch(examTypeControllerProvider).when(
            data: (data) {
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
                      'Exam Resources',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemBuilder: (ctx, i) => ExamCard(
                          examType: data[i],
                        ),
                        itemCount: data.length,
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
