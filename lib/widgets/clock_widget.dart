import 'dart:math';

import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/widgets/clock_painter.dart';
import 'package:flutter/material.dart';

class ClockWidget extends StatelessWidget {
  final int selectedValue; // 현재 선택된 값(시 혹은 분)
  final Function(int) onValueSelected; // 선택 시 호출
  final bool isHourMode;

  const ClockWidget({
    super.key,
    required this.selectedValue,
    required this.onValueSelected,
    required this.isHourMode,
  });
  
  // 각도 계산 공통 함수
  double getAngle(int index, bool isHour) {
    // 12개 아이템을 30도씩 배치 (-90도는 12시 방향 보정)
    return (index * 30 - 90) * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 80;

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: .circle,
        border: .all(color: Colors.white.withValues(alpha: 0.3), width: 1)
      ),
      child: Stack(
        alignment: .center,
        children: [
          ...List.generate(12, (index) {
            
          int value = isHourMode ? (index == 0 ? 12 : index) : (index * 5) % 60;
          
          double angle = getAngle(index, isHourMode);
          double x = radius * cos(angle);
          double y = radius * sin(angle);

          bool isSelected = selectedValue == value;

          return Transform.translate(
            offset: Offset(x, y),
            child: GestureDetector(
              onTap: () => onValueSelected(value),
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: .all(
                      color: isSelected ? Colors.white : Colors.transparent
                  ),
                ),
                alignment: .center,
                child: Text(
                  isHourMode ? '$value' : '${value.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodyDefault.copyWith(
                      fontFamily: '나눔명조'
                  )
                ),
              ),
            ),
          );
        }),
          IgnorePointer(
            child: CustomPaint(
              size: const Size(200, 200),
              painter: ClockHandPainter(value: selectedValue, isHour: isHourMode)
            ),
          )
        ],
      ),
    );
  }
}
