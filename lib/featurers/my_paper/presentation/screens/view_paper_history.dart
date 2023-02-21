import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/my_paper/data/models/exam.dart';
import 'package:toddle/featurers/my_paper/presentation/controllers/my_paper_controller.dart';
import 'package:toddle/featurers/my_paper/presentation/screens/widgets/view_history_card.dart';

class ViewPaperHistory extends ConsumerStatefulWidget {
  static const routeName = '/view-paper-history';
  const ViewPaperHistory({super.key});

  @override
  ViewPaperHistoryState createState() => ViewPaperHistoryState();
}

class ViewPaperHistoryState extends ConsumerState<ViewPaperHistory> {
  @override
  void dispose() {
    super.dispose();
    ref.invalidate(myPaperControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Papers'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.04,
        ),
        child: ref.watch(myPaperControllerProvider).when(
              data: (data) {
                List<Exam> exams =
                    data.where((element) => element.examType != '').toList();
                return data.isEmpty
                    ? const Center(
                        child: Text('You have not taken any exam.'),
                      )
                    : ListView.builder(
                        itemBuilder: (ctx, i) => ViewHistoryCard(
                          date: exams[i].examDate,
                          examType: exams[i].examType,
                          id: exams[i].id,
                        ),
                        itemCount: exams.length,
                      );
              },
              error: (e, s) => Text(e.toString()),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
      ),
    );
  }
}
