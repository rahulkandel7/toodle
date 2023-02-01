import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toddle/featurers/home/presentation/screens/home_screen.dart';
import 'package:toddle/featurers/quiz/presnetation/controllers/view_paper_controller.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/widgets/view_paper_widget.dart';

class QuizViewPaper extends ConsumerStatefulWidget {
  static const routeName = '/view-quiz-paper';
  const QuizViewPaper({super.key});

  @override
  QuizViewPaperState createState() => QuizViewPaperState();
}

class QuizViewPaperState extends ConsumerState<QuizViewPaper> {
  int i = 0;

  String? answer;
  String? selectedOptions;

  final player = AudioPlayer();

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    //MeidaQuery Screen Size
    Size screenSize = MediaQuery.of(context).size;

    //Taking Arguments
    String examId = ModalRoute.of(context)!.settings.arguments as String;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Toddle',
            style: Theme.of(context).textTheme.displaySmall,
          ),
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
        body: ref.watch(viewPaperControllerProvider(examId)).when(
              data: (data) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Showing for Title
                        // Text(
                        //   'View Paper',
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .headlineMedium!
                        //       .copyWith(
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        // ),

                        SizedBox(
                          height: screenSize.height * 0.8,
                          child: ListView.builder(
                            itemBuilder: (ctx, i) {
                              return ViewPaperWidget(questions: data[i]);
                            },
                            itemCount: data.length,
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
      ),
    );
  }
}
