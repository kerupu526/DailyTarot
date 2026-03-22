import 'dart:math';

import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/constants/pref_keys.dart';
import 'package:daily_tarot/screens/home/home_screen.dart';
import 'package:daily_tarot/services/json_service.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySoulCardScreen extends StatefulWidget {
  const MySoulCardScreen({super.key});

  @override
  State<MySoulCardScreen> createState() => _MySoulCardScreenState();
}

class _MySoulCardScreenState extends State<MySoulCardScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  Map<String, dynamic>? _cardData;
  String _displayBirthDate = "";
  int _soulNumber = 0;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // 생년월일 표시를 위해
  String _year = '';
  String _month = '';
  String _day = '';

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi * 2).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutExpo),
    );

    _loadSoulCardData();
  }

  Future<void> _loadSoulCardData() async {
    final prefs = await SharedPreferences.getInstance();
    String? birthDateStr = prefs.getString(PrefKeys.soulDate);

    if (birthDateStr == null) {
      setState(() => _cardData = {});
      return;
    }

    List<String> parts = birthDateStr.split('-');

    _year = parts[0];
    _month = parts[1];
    _day = parts[2];

    _displayBirthDate = birthDateStr.replaceAll('-', '.');
    _soulNumber = _calculateSoulNumber(birthDateStr);

    final List<dynamic> dataList = await loadJsonData(
      'assets/json/soul_cards_data.json',
    );

    final matchedCard = dataList.firstWhere(
      (card) => int.tryParse(card['number'].toString()) == _soulNumber,
      orElse: () => null,
    );

    if (matchedCard != null) {
      setState(() {
        _cardData = matchedCard;
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isAnimated = true;
            _flipController.forward();
          });
        }
      });
    }
  }

  int _calculateSoulNumber(String dateString) {
    // 날짜를 쪼개고 더해서 1자리 수가 될 때까지 while문 돌림
    List<String> parts = dateString.split('-');
    int sum = int.parse(parts[0]) + int.parse(parts[1]) + int.parse(parts[2]);

    // 1자리가 될 때까지 반복
    while (sum > 9) {
      int temp = 0;
      // 숫자를 문자열로 쪼개서 각 자리 더함
      for (String char in sum.toString().split('')) {
        temp += int.parse(char);
      }
      sum = temp;
    }
    return sum;
  }

  @override
  void dispose() {
    // [중요] 사용한 컨트롤러는 반드시 메모리 해제!
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cardData == null) {
      // null인 경우만 로딩
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    String formatStoryTelling(String text) {
      List<String> sentences = text.split('. ');

      List<String> result = [];
      for (String sentence in sentences) {
        if (sentence.length > 20) {
          String broken = '';
          int count = 0;
          for (int i = 0; i < sentence.length; i++) {
            broken += sentence[i];
            count++;
            // 쉼표 만나면 줄바꿈 시도
            if (sentence[i] == ',' && count >= 20) {
              broken += '\n';
              count = 0;
            }
          }
          result.add(broken);
        } else {
          result.add(sentence);
        }
      }

      return result.join('.\n');
    }

    // 이 아래는 _cardData가 확실히 존재하는 상태
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutExpo,
            top: _isAnimated ? 70 : size.height * 0.325,
            left: _isAnimated ? 30 : size.width * 0.2,
            width: _isAnimated ? size.width * 0.3 : size.width * 0.6,
            child: AnimatedBuilder(
              animation: _flipController,
              builder: (context, child) {
                // [핵심] 컨트롤러의 상태로 투명도를 직접 제어!
                final opacity = _flipController.isAnimating ? 0.7 : 1.0;

                return Opacity(
                  opacity: opacity,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value),
                    child: child,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/tarot_cards/${_cardData!['image']}',
                ),
              ),
            ),
          ),

          Positioned(
            top: size.height * 0.1,
            left: 0,
            right: 0,
            height: 100,
            child: AnimatedOpacity(
              opacity: _isAnimated ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              child: Column(
                crossAxisAlignment: .center,
                children: [
                  ClipRect(
                    child: Align(
                      alignment: .center,
                      heightFactor: 0.7,
                      child: Image.asset(
                        'assets/images/graphic.png',
                        height: 70,
                      ),
                    ),
                  ),
                  Text(
                    '${_cardData!['number']}번 ${_cardData!['name']}',
                    style: AppTextStyles.largeBold
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 80,
            left: 150,
            child: AnimatedOpacity(
              opacity: _isAnimated ? 1.0 : 0.0,
              duration: Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: .start,
                // TODO: 쪼끄만 로고, 생일, 텍스트
                children: [
                  ClipRect(
                    child: Align(
                      alignment: .centerLeft,
                      heightFactor: 0.7,
                      child: Image.asset(
                        'assets/images/graphic.png',
                        height: 70,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          '$_year년 $_month월 $_day일생,\n',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: .bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '당신의 소울카드는\n${_cardData!['number']}번 ${_cardData!['name']}입니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: .bold,
                            height: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 300,
            child: AnimatedOpacity(
              opacity: _isAnimated ? 1.0 : 0.0,
              duration: Duration(milliseconds: 800),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // TODO: 본문 텍스트
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: size.width - 70, // 좌우 여백 40씩 총 80을 뺌
                    // TODO: 본문 텍스트
                    child: Text(
                      formatStoryTelling(_cardData!['storytelling']),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 2.2,
                        fontWeight: .bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Align(
            // TODO: 닫기 버튼
            alignment: .bottomCenter,
            heightFactor: 17,
            child: Opacity(
              opacity: _isAnimated ? 1.0 : 0.0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => pushReplacementPage(context, HomeScreen()),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: .all(color: Colors.white54, width: 1)),
                  child: Center(
                    child: Text(
                      '×',
                      style: TextStyle(fontSize: 32, color: Colors.white54, height: 1),
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
