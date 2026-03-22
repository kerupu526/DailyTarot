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
    // 카드들을 중앙으로 집합
    setState(() {
      for (int i = 0; i < 9; i++) {
        _isCardCentered[i] = true;
      }
    });

    // 카드가 중앙으로 모이는 시간(예: 600ms)동안 대기
    await Future.delayed(Duration(milliseconds: 600));

    // 눈에 안 보이는 상태에서 뒤에 있는 데이터를 무작위로 섞음
    setState(() {
      _cardIndices.shuffle();
    });

    // 아주 찰나의 시간 뜸을 들임 (영상처럼)
    for (int i = 0; i < 9; i++) {
      if (i == 4) {
        // 정중앙 카드는 이미 자기 자리에 있으므로, 상태만 바꿔주고 딜레이 없이 패스!
        if (mounted) setState(() => _isCardCentered[i] = false);
        continue;
      }

      // 나머지 8장의 카드만 0.1초 간격으로 날려보냄
      await Future.delayed(const Duration(milliseconds: 300)); // (속도는 선수님 취향껏)

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
