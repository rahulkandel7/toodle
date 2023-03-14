import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/home/presentation/screens/first_screen.dart';
import 'package:toddle/featurers/quiz/presnetation/controllers/view_paper_controller.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/widgets/view_paper_widget.dart';

class QuizViewPaper extends ConsumerWidget {
  static const routeName = '/view-quiz-paper';
  const QuizViewPaper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //MeidaQuery Screen Size
    Size screenSize = MediaQuery.of(context).size;

    //Taking Arguments
    Map<String, dynamic> navData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    //Getting exam id
    String examId = navData['id'].toString();

    //getting isHistory
    bool isHistory = navData['isHistory'];

    return WillPopScope(
      onWillPop: () async {
        isHistory
            ? Navigator.of(context).pop()
            : Navigator.of(context).pushReplacementNamed(FirstScreen.routeName);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Toddle',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          centerTitle: true,
        ),
        body: ref.watch(viewPaperControllerProvider(examId)).when(
              data: (data) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (ctx, i) {
                            return ViewPaperWidget(
                              questions: data[i],
                              i: i,
                            );
                          },
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
      ),
    );
  }
}
