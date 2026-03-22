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
    return SizedBox(
      height: 8, // 전체 바의 두께
      child: Stack(
        children:[
          // 1. [베이스 레이어] 쭈욱 이어져 있는 반투명 배경 바
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10), // 양끝 둥글게
            ),
          ),

          // 2.[오버레이 레이어] 끊어져서 채워지는 흰색 바
          Row(
            children: List.generate(totalSteps, (index) {
              bool isActive = index < currentStep;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // 막대기 사이의 간격 (마지막 칸은 우측 여백 0)
                  margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 2),
                  decoration: BoxDecoration(
                    // 활성화된 단계만 흰색! 활성화 안 된 곳은 투명하게 둬서 이어진 뒷배경이 보이게 함
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}