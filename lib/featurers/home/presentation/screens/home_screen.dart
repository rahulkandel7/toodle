import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person_2_outlined,
            ),
          ),
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
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        for (var exam in data)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10.0, left: 10.0),
                            child: ExamCard(
                              examType: exam,
                            ),
                          ),
                      ],
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
    );
  }
}
