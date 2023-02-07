import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/auth/presentation/screens/edit_profile.dart';
import 'package:toddle/featurers/auth/presentation/screens/forget_change_password.dart';
import 'package:toddle/featurers/auth/presentation/screens/forget_otp.dart';
import 'package:toddle/featurers/auth/presentation/screens/forget_password_screen.dart';
import 'package:toddle/featurers/auth/presentation/screens/login_screen.dart';
import 'package:toddle/featurers/auth/presentation/screens/register_screen.dart';
import 'package:toddle/featurers/home/presentation/screens/home_screen.dart';
import 'package:toddle/featurers/home/presentation/screens/set_screen.dart';
import 'package:toddle/featurers/my_paper/presentation/screens/view_paper_history.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_result_screen.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_screen.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_view_paper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        RegisterScreen.routeName: (ctx) => const RegisterScreen(),
        ForgetPasswordScreen.routeName: (ctx) => const ForgetPasswordScreen(),
        ForgetOtp.routeName: (ctx) => const ForgetOtp(),
        ForgetChangePassword.routeName: (ctx) => const ForgetChangePassword(),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        SetScreen.routeName: (ctx) => const SetScreen(),
        QuizScreen.routeName: (ctx) => const QuizScreen(),
        QuizResultScreen.routeName: (ctx) => const QuizResultScreen(),
        QuizViewPaper.routeName: (ctx) => const QuizViewPaper(),
        EditProfile.routename: (ctx) => const EditProfile(),
        ViewPaperHistory.routeName: (ctx) => const ViewPaperHistory(),
      },
    );
  }
}
