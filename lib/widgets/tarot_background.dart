import 'package:daily_tarot/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TarotBackground extends StatelessWidget {
  final Widget child;
  final Animation<double>? backgroundAnimation; // 온보딩용 애니메이션 (선택)
  final Animation<double>? logoAnimation;       // 로고, 그래픽 애니메이션

  const TarotBackground({
    super.key,
    required this.child,
    this.backgroundAnimation,
    this.logoAnimation
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 달과 구름을 그리는 공통 위젯
    Widget backgroundElements = Stack(
      children:[
        // 달
        Positioned(
          top: size.height * 0.04,
          left: -8,
          child: Image.asset('assets/images/moon.png', width: 150, fit: BoxFit.contain),
        ),
        // 구름 1
        Positioned(
          bottom: size.height * 0.05, left: -40, width: size.width * 0.7,
          child: Image.asset('assets/images/cloud.png', fit: BoxFit.fitWidth),
        ),
        // 구름 2
        Positioned(
          bottom: size.height * 0.06, right: -50, width: size.width * 0.8,
          child: Image.asset('assets/images/cloud.png', fit: BoxFit.fitWidth),
        ),
        // 구름 4
        Positioned(
          bottom: size.height * 0.01, right: -140, width: size.width * 0.8,
          child: Image.asset('assets/images/cloud.png', fit: BoxFit.fitWidth),
        ),
        // 구름 3
        Positioned(
          bottom: size.height * -0.02, left: -20, width: size.width * 0.6,
          child: Image.asset('assets/images/cloud.png', fit: BoxFit.fitWidth),
        ),
        // 구름 5
        Positioned(
          bottom: -50, left: 140, right: 0,
          child: Image.asset('assets/images/cloud.png', height: 140, fit: BoxFit.fitHeight),
        ),
      ],
    );

    // 애니메이션이 전달되었다면 FadeTransition 적용, 아니면 그대로 출력
    if (backgroundAnimation != null) {
      backgroundElements = FadeTransition(opacity: backgroundAnimation!, child: backgroundElements);
    }

    // --- 2. 로고 및 그래픽 (공통 요소로 고정) ---
    Widget logoElements = Column(
      mainAxisSize: MainAxisSize.min,
      children:[
        Image.asset(
          'assets/images/Daily Tarot.png',
          width: size.width * 0.65,
          fit: BoxFit.contain,
        ),
        Transform.translate(
          offset: const Offset(0, -25),
          child: Image.asset(
            'assets/images/graphic.png',
            width: 80,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );

    if (logoAnimation != null) {
      logoElements = FadeTransition(opacity: logoAnimation!, child: logoElements);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      // 키보드 올라올 때 구름/로고가 찌그러지지 않도록 배경을 고정시킴
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:[AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: Stack(
          children:[
            backgroundElements, // 달, 구름

            // 🔥[여기를 0.13 -> 0.26으로 확 내렸습니다!!!] 🔥
            Positioned(
              top: size.height * 0.24, // 상단에서 26% 지점까지 로고를 쭉 내림
              left: 0,
              right: 0,
              child: logoElements,
            ),

            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}