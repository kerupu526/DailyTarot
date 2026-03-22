import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:daily_tarot/widgets/home_background.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/pref_keys.dart';
import 'tarot_result_screen.dart';

class FruitCardScreen extends StatefulWidget {
  const FruitCardScreen({super.key});

  @override
  State<FruitCardScreen> createState() => _FruitCardScreenState();
}

class _FruitCardScreenState extends State<FruitCardScreen> {
  final List<bool> _isCardCentered = List.generate(9, (index) => false);
  final List<int> _cardIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  int _shuffleVersion = 0;

  Offset _calculateCardPosition(int index, double gridWidth, double gridHeight, double cardWidth, double cardHeight) {
    // 만약 셔플 중이면? 무조건 정중앙 좌표 반환
    if (_isCardCentered[index]) {
      return Offset(
        (gridWidth - cardWidth) / 2,
        (gridHeight - cardHeight) / 2,
      );
    }

    // 셔플 중이 아니면 3x3 자기 자리 계산
    int row = index ~/ 3;
    int col = index % 3;

    // 카드 사이 간격 자유롭게 고정
    double gapX = 8.0; // 픽셀 단위 고정 간격
    double gapY = 8.0;

    // 3x3 카드 뭉치 '전체'가 차지하는 가로, 세로 너비 계산
    double totalGridWidth = (cardWidth * 3) + (gapX * 2);
    double totalGridHeight = (cardHeight * 3) + (gapY * 2);

    // 정중앙에 놓기 위한 시작점(왼쪽 위 모서리) 계산
    double startX = (gridWidth - totalGridWidth) / 2;
    double startY = ((gridHeight - totalGridHeight) / 2);

    // 최종 좌표: 시작점 + (내 열/행 위치 * (카드크기 + 간격))
    double x = startX + col * (cardWidth + gapX);
    double y = startY + row * (cardHeight + gapY);

    return Offset(x, y);
  }

  Future<void> _startShuffleAnimation() async {
    // 1. 새로운 셔플 시작을 알리기 위해 버전 업!
    _shuffleVersion++;
    // 2. 현재 실행되는 이 함수의 고유 ID를 복사해둡니다.
    final int currentId = _shuffleVersion;

    // 3. 일단 모든 카드를 중앙으로 모읍니다. (기존 로직)
    setState(() {
      for (int i = 0; i < 9; i++) _isCardCentered[i] = true;
    });

    // 4. 모이는 시간 동안 대기
    await Future.delayed(const Duration(milliseconds: 600));

    // [체크포인트] 대기 중에 버튼이 또 눌렸나? (currentId가 최신이 아니면 중단)
    if (currentId != _shuffleVersion) return;

    // 5. 카드 데이터 섞기
    setState(() {
      _cardIndices.shuffle();
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (currentId != _shuffleVersion) return;

    // 6. 순서대로 펼치기
    for (int i = 0; i < 9; i++) {
      if (i == 4) {
        if (mounted) setState(() => _isCardCentered[i] = false);
        continue;
      }

      await Future.delayed(const Duration(milliseconds: 400)); // 펼치는 간격을 100ms로 줄여서 쾌적하게!

      // [체크포인트] 펼치는 도중에 또 눌렸나? 그럼 즉시 멈춤!
      if (currentId != _shuffleVersion) return;

      if (mounted) {
        setState(() {
          _isCardCentered[i] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: Column(
        children: [
          Align(
            alignment: .center,
            child: Transform.translate(
              offset: Offset(0, 32),
              child: Column(
                children: [
                  ClipRect(
                    child: Align(
                      heightFactor: 0.7,
                      alignment: .center,
                      child: Image.asset('assets/images/graphic.png', height: 60,),
                    ),
                  ),
                  Text('열매 타로를 선택하셨네요.\n신중하게 카드 1장을 선택해주세요.', style: AppTextStyles.largeBold, textAlign: .center,),
                  SizedBox(height: 8,),
                  Text('지금 생각하고 있는 일은 어떤 결과로 이어질까요?', style: AppTextStyles.etcText.copyWith(color: Colors.white70,fontFamily: 'NotoSansKR'),)
                ],
              ),
            ),
          ),

          Expanded(
              child: LayoutBuilder(
                  builder: (context, constraints) {
                    double gridWidth = constraints.maxWidth;
                    double gridHeight = constraints.maxHeight;
                    double cardWidth = gridWidth * 0.2;
                    double cardHeight = cardWidth * 1.6;

                    return Stack(
                      // List.generate를 사용해 AnimatedPositioned 9개를 겹쳐놓음
                      children: List.generate(9, (index) {
                        Offset pos = _calculateCardPosition(index, gridWidth, gridHeight, cardWidth, cardHeight);

                        return AnimatedPositioned(
                            duration: Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          left: pos.dx,
                          top: pos.dy,
                          width: cardWidth,
                          height: cardHeight,
                          child: GestureDetector(
                            onTap: () async {
                              int selectedCardId = _cardIndices[index];

                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setInt(PrefKeys.selectedFruitId, selectedCardId);

                              if (!context.mounted) return;

                              pushAndRemoveAllPage(context, const TarotResultScreen(tarotType: 'fruit'));
                            },
                            child: Image.asset('assets/images/tarot_card_back.png'),
                          ),
                        );
                      }),
                    );
                  }
              )
          ),
          GestureDetector(
            onTap: _startShuffleAnimation,
            child: Container(
              width: 90,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: .circular(60),
                color: Colors.white.withValues(alpha: 0.05), // 터치 영역 확보
                ),
              child: Center(
                child: Text(
                  '셔플',
                  style: AppTextStyles.bodyDefault
                ),
              ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
        ],
      ),
    );
  }
}
