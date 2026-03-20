import 'package:daily_tarot/screens/home/home_screen.dart';
import 'package:daily_tarot/services/json_service.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:daily_tarot/widgets/home_background.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FruitTarotResultScreen extends StatefulWidget {
  const FruitTarotResultScreen({super.key});

  @override
  State<FruitTarotResultScreen> createState() => _FruitTarotResultScreenState();
}

class _FruitTarotResultScreenState extends State<FruitTarotResultScreen> {
  Map<String, dynamic>? _cardData;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _loadFruitCardData();
  }

  Future<void> _loadFruitCardData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? targetId = prefs.getInt('selected_fruit_card_id');

    if (targetId == null) {
      if (mounted) setState(() => _cardData = {});
      return;
    }

    final List<dynamic> dataList =
    await loadJsonData('assets/json/fruit_tarot_cards_data.json');

    final matchedCard = dataList.firstWhere(
          (card) => int.tryParse(card['number'].toString()) == targetId,
      orElse: () => null,
    );

    if (matchedCard != null && mounted) {
      setState(() {
        _cardData = matchedCard;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cardData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;

    return HomeBackground(
      child: Stack(
        children: [
          // ── 메인 레이아웃 Column ──
          Column(
            children: [
              SizedBox(height: size.height * 0.04),

              // 상단 그래픽
              ClipRect(
                child: Align(
                  heightFactor: 0.7,
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/graphic.png', height: 60),
                ),
              ),

              // 제목 텍스트 (크기 애니메이션)
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isRevealed ? 16 : 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: '나눔명조',
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _isRevealed
                        ? '카드풀이'
                        : '아래의 타로카드를 선택하셨군요\n결과를 확인해보세요',
                    key: ValueKey<bool>(_isRevealed),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 카드 위 여백 (줄어들면서 카드가 위로 올라가는 효과)
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                height: _isRevealed ? size.height * 0.04 : size.height * 0.125,
              ),

              // 카드 이미지 (높이 줄어듦)
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                height:
                _isRevealed ? size.height * 0.18 : size.height * 0.25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/tarot_cards/${_cardData!['image']}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 카드 이름
              Text(
                '${_cardData!['number']}. ${_cardData!['name']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

              // 본문 스크롤뷰
              Expanded(
                child: AnimatedOpacity(
                  opacity: _isRevealed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    child: Column(
                      children: [
                        SizedBox(
                          width: size.width - 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (_cardData!['storytelling'] as String)
                                .split('. ')
                                .where((s) => s.trim().isNotEmpty)
                                .map<Widget>(
                                  (sentence) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  sentence.endsWith('.')
                                      ? sentence
                                      : '$sentence.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'NotoSansKR',
                                    fontWeight: FontWeight.w500,
                                    height: 2,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () =>
                              pushReplacementPage(context, HomeScreen()),
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: .circular(60),
                              color: Colors.white.withValues(alpha: 0.08), // 터치 영역 확보
                            ),
                            child: Center(
                              child: Text('돌아가기', style: TextStyle(color: Colors.white, fontWeight: .w500, fontFamily: 'NotoSansKR'),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 결과 확인 버튼 (Stack 자식으로 위치 고정) ──
          Positioned(
            bottom: size.height * 0.225,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _isRevealed,
              child: AnimatedOpacity(
                opacity: _isRevealed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRevealed = true),
                    child: Container(
                      width: 140,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          begin: Alignment(-1, -0.8),
                          end: Alignment(0, 1),
                          colors: [
                            Color(0xFF806381),
                            Color(0xFF745074),
                            Color(0xFF432267),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x90846881),
                            blurRadius: 3,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '결과 확인',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}