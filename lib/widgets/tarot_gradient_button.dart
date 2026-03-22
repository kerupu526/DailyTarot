import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TarotGradientButton extends StatelessWidget {
  final String text;             // 버튼 글자 ('시작하기', '결과 확인' 등)
  final VoidCallback onTap;      // 눌렀을 때 실행할 함수
  final bool showRightArrow;     // 우측 화살표 아이콘(>)을 보여줄지 여부
  final Widget? prefixIcon;      // 좌측 아이콘 (예: 달 아이콘)

  const TarotGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.showRightArrow = false, // 기본값은 화살표 없음
    this.prefixIcon,             // 기본값은 좌측 아이콘 없음
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .symmetric(horizontal: 55, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: .circular(50),
          gradient: LinearGradient(
            begin: Alignment(-1, -0.8),
            end: Alignment(0, 1),
            colors: [AppColors.buttonStart, AppColors.buttonMiddle, AppColors.buttonEnd],
          ),
          boxShadow: const[BoxShadow(color: AppColors.buttonShadow, blurRadius: 3, offset: Offset(0, 6))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 가로 차지
          children:[
            if (prefixIcon != null) ...[
              prefixIcon!,
            ],
            Text(
                text,
                style: AppTextStyles.boldText
            ),
            if (showRightArrow) ...[
              Transform.rotate(
                angle: 3.14159, // 180도 (pi)
                child: SvgPicture.asset(
                  'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                  width: 20,
                  height: 20,
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }
}
