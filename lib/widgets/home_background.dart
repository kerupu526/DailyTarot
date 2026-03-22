import 'package:daily_tarot/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2C1654),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -80,
              right: 140,
              child: Transform.flip(
                flipX: true,
                flipY: true,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    "assets/images/cloud.png",
                    width: 160,
                    height: 160,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              left: 160,
              right: -100,
              child: Transform.flip(
                flipX: true,
                flipY: true,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    "assets/images/cloud.png",
                    width: 150,
                    height: 180,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -60,
              left: 80,
              right: 0,
              child: Transform.flip(
                flipX: true,
                flipY: true,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    "assets/images/cloud.png",
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
            // 아래
            Positioned(
              bottom: 10,
              left: 140,
              right: -60,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  "assets/images/cloud.png",
                  width: 140,
                  height: 140,
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              left: 220,
              right: -120,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  "assets/images/cloud.png",
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -60,
              right: 140,
              child: Transform.flip(
                flipX: true,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    "assets/images/cloud.png",
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -40,
              right: 140,
              child: Transform.flip(
                flipX: true,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    "assets/images/cloud.png",
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: 120,
              right: 0,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  "assets/images/cloud.png",
                  width: 150,
                  height: 150,
                ),
              ),
            ),

            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
