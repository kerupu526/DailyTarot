import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TarotActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isFlipped;
  final String iconPath;

  const TarotActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isFlipped = false,
    this.iconPath = 'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg'
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(60),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // isFlipped가 false면 아이콘이 왼쪽에 (이전 버튼)
            if (!isFlipped) ...[
              SvgPicture.asset(iconPath, width: 20, height: 20),
              const SizedBox(width: 6),
            ],

            Text(
              text,
              style: AppTextStyles.bodyMedium
            ),

            // isFlipped가 true면 아이콘이 오른쪽에 (잘 모르겠어요 버튼)
            if (isFlipped) ...[
              const SizedBox(width: 6),
              Transform.flip(
                  flipX: true,
                  child: SvgPicture.asset(iconPath, width: 20, height: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
