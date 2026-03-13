import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/tarot_background.dart'; // 공통 배경 위젯 import (경로 확인 필수!)

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _moonCloudAnimation;
  late Animation<double> _logoTextAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 총 2초
    );

    // 0.0 ~ 0.25 (0초 ~ 0.5초)
    _moonCloudAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)),
    );
    // 0.25 ~ 0.6 (0.5초 ~ 1.2초)
    _logoTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );
    // 0.6 ~ 0.9 (1.2초 ~ 1.8초)
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return TarotBackground(
      backgroundAnimation: _moonCloudAnimation,
      logoAnimation: _logoTextAnimation, // 로고 애니메이션 전달
      child: Stack(
        children:[
          // 텍스트 (로고 바로 아래쯤 위치해야 하므로 상단에서 38% 지점에 배치)
          Positioned(
            top: size.height * 0.32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _logoTextAnimation, // 텍스트도 같이 나타남
              child: const Center(
                child: Text(
                  "운명을 엿볼 시간이에요.",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),

          // 시작하기 버튼
          Positioned(
            bottom: size.height * 0.34,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _buttonAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/info_input'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        begin: Alignment(-1, -0.8),
                        end: Alignment(0, 1),
                        colors:[Color(0xFF806381), Color(0xFF745074), Color(0xFF432267)],
                      ),
                      boxShadow: const[BoxShadow(color: Color(0x90846881), blurRadius: 3, offset: Offset(0, 6))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 가로 차지
                      children:[
                        const Text(
                          '시작하기', // ">" 기호 제거
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // 제공된 arrow_back 아이콘을 180도 회전시켜서 사용
                        Transform.rotate(
                          angle: 3.14159, // 180도 (pi)
                          child: SvgPicture.asset(
                            'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}