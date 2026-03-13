import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final int currentStep; // 현재 단계 (예: 1, 2, 3...)
  final int totalSteps;  // 전체 단계 (기본값 5)

  const CustomProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    // 진행률 계산 (예: 1 / 5 = 0.2)
    final double progressValue = currentStep / totalSteps;

    return Row(
      children:[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10, // 깔끔하고 얇은 두께
            ),
          ),
        ),
      ],
    );
  }
}