import 'package:daily_tarot/constants/app_colors.dart';
import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/screens/home/home_screen.dart';
import 'package:daily_tarot/services/json_service.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:daily_tarot/widgets/home_background.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TarotResultScreen extends StatefulWidget {
  final String tarotType; // 'fruit' 또는 'love'

  const TarotResultScreen({super.key, required this.tarotType});

  @override
  State<TarotResultScreen> createState() => _TarotResultScreenState();
}

class _TarotResultScreenState extends State<TarotResultScreen> {
  Map<String, dynamic>? _cardData;
  bool _isRevealed = false;
  bool _hasError = false; // 에러 방지용 안전 장치

  @override
  void initState() {
    super.initState();
    _loadTarotData();
  }

  Future<void> _loadTarotData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 타로 타입별로 다른 키값을 사용 (인연 타로면 selected_love_card_id, 열매면 selected_fruit_card_id)
      String prefKey = widget.tarotType == 'fruit' ? 'selected_fruit_card_id' : 'selected_love_card_id';
      final int? targetId = prefs.getInt(prefKey);

      if (targetId == null) {
        if (mounted) setState(() => _hasError = true);
        return;
      }

      // 타로 타입별로 다른 JSON 경로 로드
      String jsonPath = widget.tarotType == 'fruit'
          ? 'assets/json/fruit_tarot_cards_data.json'
          : 'assets/json/loves_tarot_cards_data.json';

      final List<dynamic> dataList = await loadJsonData(jsonPath);

      final matchedCard = dataList.firstWhere(
            (card) => int.tryParse(card['number'].toString()) == targetId,
        orElse: () => null,
      );

      if (matchedCard != null && mounted) {
        setState(() {
          _cardData = matchedCard;
        });
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 에러가 났을 때 (ID가 없거나 파일이 없을 때) 앱이 터지지 않도록 방어!
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              const Text("데이터를 불러올 수 없습니다.", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => pushReplacementPage(context, const HomeScreen()),
                child: const Text("홈으로 돌아가기"),
              )
            ],
          ),
        ),
      );
    }

    // 2. 로딩 중일 때
    if (_cardData == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;

    return HomeBackground(
      child: Stack(
        children:[
          // ── 메인 레이아웃 Column ──
          Column(
            children:[
              SizedBox(height: size.height * 0.04),
              ClipRect(
                child: Align(
                  heightFactor: 0.7,
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/graphic.png', height: 60),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _isRevealed ? '카드풀이' : '아래의 타로카드를 선택하셨군요\n결과를 확인해보세요',
                  key: ValueKey<bool>(_isRevealed),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.largeBold,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                height: _isRevealed ? size.height * 0.04 : size.height * 0.10,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                height: _isRevealed ? size.height * 0.18 : size.height * 0.25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset('assets/images/tarot_cards/${_cardData!['image']}', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 15),
              Text('${_cardData!['number']}. ${_cardData!['name']}', style: AppTextStyles.boldText),

              Expanded(
                child: AnimatedOpacity(
                  opacity: _isRevealed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    child: Column(
                      children:[
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
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => pushReplacementPage(context, const HomeScreen()),
                          child: Container(
                            width: 100, height: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(60), color: Colors.white.withValues(alpha: 0.08)),
                            child: Center(child: Text('돌아가기', style: AppTextStyles.etcText.copyWith(fontFamily: 'NotoSansKR'))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 결과 확인 버튼 ──
          Positioned(
            bottom: size.height * 0.225,
            left: 0, right: 0,
            child: IgnorePointer(
              ignoring: _isRevealed,
              child: AnimatedOpacity(
                opacity: _isRevealed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRevealed = true),
                    child: Container(
                      width: 140, height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          begin: Alignment(-1, -0.8), end: Alignment(0, 1),
                          colors:[AppColors.buttonStart, AppColors.buttonMiddle, AppColors.buttonEnd],
                        ),
                      ),
                      child: const Center(child: Text('결과 확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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