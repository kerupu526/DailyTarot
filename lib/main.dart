import 'package:daily_tarot/screens/info_input/age_input_screen.dart';
import 'package:daily_tarot/screens/info_input/birth_date_input_screen.dart';
import 'package:daily_tarot/screens/info_input/gender_input_screen.dart';
import 'package:daily_tarot/screens/info_input/info_confirm_screen.dart';
import 'package:daily_tarot/screens/info_input/time_input_screen_dart.dart';
import 'package:flutter/material.dart';
import 'screens/info_input/name_input_screen.dart';
import 'screens/onboarding_screen.dart'; // 방금 만든 파일 import

void main() {
  runApp(const DailyTarotApp());
}

class DailyTarotApp extends StatelessWidget {
  const DailyTarotApp({super.key});

  // 화면 이동 시 fade 애니메이션 적용하는 함수
  void navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tarot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '나눔명조', // 폰트가 있다면 적용
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/info_input': (context) => const NameInputScreen(), // 시작하기 버튼 누르면 여기로
        // 나중에 만들 화면들 미리 선언 (안 만들어뒀으면 주석 처리)
        '/info_input_age': (context) => const AgeInputScreen(),
        '/info_input_gender': (context) => const GenderInputScreen(),
        '/info_input_birth_date': (context) => const BirthDateInputScreen(),
        '/info_input_time': (context) => const TimeInputScreen(),
        '/info_confirm': (context) => const InfoConfirmScreen(), // 이거 추가!
        '/home': (context) => const Scaffold(backgroundColor: Colors.white), // 홈 (빈 화면 요구사항 충족)
      },
    );
  }
}