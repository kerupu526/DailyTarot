import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/screens/tarot/tarot_result_screen.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:daily_tarot/widgets/home_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/pref_keys.dart';

class LovesCardScreen extends StatefulWidget {
  const LovesCardScreen({super.key});

  @override
  State<LovesCardScreen> createState() => _LovesCardScreenState();
}

class _LovesCardScreenState extends State<LovesCardScreen> {
  static const int cardCount = 9;
  static const double angleStep = 0.1;       // 카드 간 각도
  static const double dragSensitivity = 30.0; // 드래그 민감도
  static const double cardWidth = 140.0;
  static const double cardHeight = 230.0;

  // 현재 중앙에 있는 카드 인덱스 (소수점 = 드래그 중간 상태)
  double _centerIndex = 3.4;

  // 중앙에서 멀수록 뒤에 그려지도록 정렬
  List<int> get _paintOrder {
    return List.generate(cardCount, (i) => i); // 그냥 0,1,2,...,8 순서
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Image.asset('assets/images/graphic.png', height: 40),
          const SizedBox(height: 16),
          const Text(
            "인연 타로를 선택하셨네요.\n신중하게 카드 1장을 선택해주세요.",
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitleBold
          ),
          const SizedBox(height: 8),
          const Text(
            "생각하고 있는 그 사람과 인연이 될 수 있을까요?",
            style: AppTextStyles.miniText,
          ),
          const Spacer(),
          Text(
            "좌우로 스크롤하여\n카드 한 장을 골라보세요!",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),

          // ── 핵심: 드래그로 회전하는 부채꼴 카드 ──
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                // 왼쪽으로 드래그 → 오른쪽 카드가 중앙으로
                _centerIndex -= details.delta.dx / dragSensitivity;
                _centerIndex = _centerIndex.clamp(0.0, cardCount - 1.0);
              });
            },
            child: SizedBox(
              height: 320,
              width: double.infinity,
              child: Transform.translate(
                offset: Offset(0, 30),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: _paintOrder.map((index) {
                    final double diff = index - _centerIndex;

                    // 회전각: 중앙=0, 양옆으로 기울어짐
                    final double angle = diff * angleStep;

                    final double scale = (1.0 - diff.abs() * 0.02).clamp(0.86, 1.0);

                    final double pivotDistance = 650.0; // 카드 하단에서 중심점까지 거리 (클수록 부채꼴이 완만)

                    return Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                      // 1. 중심점(pivot)으로 이동
                        ..translateByDouble(0.0, pivotDistance, 0.0, 0.0)
                      // 2. 그 점 기준으로 회전
                        ..rotateZ(angle)
                      // 3. 다시 원위치
                        ..translateByDouble(0.0, -pivotDistance, 0.0, 0.0)
                        ..scaleByDouble(scale, scale, 1.0, 1.0),
                      child: GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          // 🔥 [수정 1] 키 이름을 'selected_love_card_id'로 바꿉니다!
                          // 🔥 [수정 2] JSON 번호(1~9)와 맞추기 위해 index + 1 을 저장합니다!
                          await prefs.setInt(PrefKeys.selectedLoveId, index + 1);

                          if (!context.mounted) return;
                          pushAndRemoveAllPage(context, const TarotResultScreen(tarotType: 'love'));
                        },
                        child: Container(
                          width: cardWidth,
                          height: cardHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: -3,
                                offset: const Offset(-5, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/tarot_card_back.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}