import 'package:daily_tarot/constants/app_colors.dart';
import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/constants/pref_keys.dart';
import 'package:daily_tarot/screens/home/moon_recharge_screen.dart';
import 'package:daily_tarot/screens/tarot/fruit_card_screen.dart';
import 'package:daily_tarot/screens/tarot/loves_card_screen.dart';
import 'package:daily_tarot/screens/tarot/soul_card_screen.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/home_background.dart'; // 방금 만든 홈 전용 배경

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _moonCount = 10; // 요구사항: 현재 보유한 달 개수 (도면 기준 10)

  @override
  void initState() {
    super.initState();
    _loadMoonCount();
  }

  // 요구사항 2: 앱을 종료하고 다시 접속해도 유지되어야 함
  Future<void> _loadMoonCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 저장된 값이 없으면 기본값 10 지급
      _moonCount = prefs.getInt(PrefKeys.moonCount) ?? 10;
    });
    // 초기화용 저장 (없을 경우를 대비)
    await prefs.setInt(PrefKeys.moonCount, _moonCount);
  }

  // 요구사항 5: 토스트 메시지 (SnackBar를 토스트처럼 활용)
  void _showComingSoonToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '준비 중입니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'NotoSansKR'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 요구사항 6: 웹 브라우저 띄우기
  Future<void> _launchWikipedia() async {
    final Uri url = Uri.parse('https://ko.wikipedia.org/wiki/타로');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return HomeBackground(
      child: Stack(
        children: [
          // --- 1. 메인 스크롤 콘텐츠 ---
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: size.height * 0.1, bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 로고 & 그래픽
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/Daily Tarot.png',
                          width: size.width * 0.5,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Image.asset(
                            'assets/images/graphic.png',
                            width: 60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Soul Card 섹션
                  _buildSectionTitle("Daily Tarot Soul Card"),
                  _buildSoulCard(),

                  const SizedBox(height: 30),

                  // 4. Tarot List 섹션 (가로 스크롤)
                  _buildSectionTitle("Daily Tarot List"),
                  _buildTarotList(size),

                  const SizedBox(height: 30),

                  // 5. Daily Master 섹션
                  _buildSectionTitle("Daily Master"),
                  _buildDailyMasterCard(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // --- 2. 상단 헤더 (달 보유 개수) ---
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                // 요구사항 3: 달 충전 화면으로 이동
                pushPage(context, MoonRechargeScreen());
                // 다녀온 후 달 개수 다시 로드 (실시간 업데이트 효과!)
                _loadMoonCount();
              },
              child: Row(
                children: [
                  Image.asset('assets/images/moon.png', width: 32, height: 32),
                  Text(
                    '$_moonCount',
                    style: AppTextStyles.etcText.copyWith(fontFamily: 'NotoSansKR', fontWeight: .bold)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 공통 타이틀 위젯 ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: AppTextStyles.extraLargeBold
      ),
    );
  }

  // --- 섹션 1: Soul Card ---
  Widget _buildSoulCard() {
    return GestureDetector(
      onTap: () => pushPage(context, SoulCardScreen()),
      // 요구사항 4: 소울카드 이동
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: AppColors.soulCardShadow,
              blurRadius: 12,
              blurStyle: .outer,
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/daily_tarot_soul_card.png'),
            // 에셋명 확인 필수
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 가독성을 위한 어두운 그라디언트
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // 요구사항 4-3, 4-4: 오른쪽 아래, 오른쪽 정렬
            Positioned(
              bottom: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    "Soul Card",
                    style: AppTextStyles.largeBold
                  ),
                  SizedBox(height: 4),
                  Text(
                    "운명적인 나만의 데일리 카드!\n매일 하루를 카운셀링 받으세요.",
                    textAlign: TextAlign.right,
                    style: AppTextStyles.miniBold
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 섹션 2: Tarot List (가로 스크롤) ---
  Widget _buildTarotList(Size size) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // 인연 타로 카드 (요구사항 5-3: 왼쪽 아래 정렬)
          _buildTarotListItem(
            width: size.width * 0.51,
            imagePath: 'assets/images/love_tarot.png',
            // 에셋명 확인 필수
            title: "인연 타로",
            desc: "지금은 힘들지만 그래도,\n그 사람과 인연이 될 수 있을까?",
            isBottomLeft: true, // 왼쪽 아래
            page: LovesCardScreen()
          ),
          const SizedBox(width: 16),
          // 열매 타로 카드 (요구사항 5-5: 왼쪽 위 정렬)
          _buildTarotListItem(
            width: size.width * 0.51,
            imagePath: 'assets/images/fruit_tarot.png',
            // 에셋명 확인 필수
            title: "열매 타로",
            desc: "지금 생각하고 있는 일은\n어떤 결과로 이어질까?",
            isBottomLeft: false, // 왼쪽 위
            page: FruitCardScreen()
          ),
        ],
      ),
    );
  }

  Widget _buildTarotListItem({
    required double width,
    required String imagePath,
    required String title,
    required String desc,
    required bool isBottomLeft,
    required Widget page
  }) {
    return GestureDetector(
      onTap: () {
        pushPage(context, page);
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withValues(alpha: 0.3), // 텍스트 가독성
              ),
            ),
            // 위치 제어 분기처리 (isBottomLeft 여부)
            Positioned(
              bottom: isBottomLeft ? 15 : null,
              top: isBottomLeft ? null : 15,
              left: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.largeBold.copyWith(
                      fontFamily: 'NotoSansKR'
                    )
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: AppTextStyles.miniBold.copyWith(
                        fontFamily: 'NotoSansKR'
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 섹션 3: Daily Master ---
  Widget _buildDailyMasterCard() {
    return GestureDetector(
      onTap: _launchWikipedia, // 요구사항 6: 위키백과 링크 이동
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: AppColors.buttonShadow, blurRadius: 4)],
          image: const DecorationImage(
            image: AssetImage('assets/images/daily_master.png'), // 에셋명 확인 필수
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),
            // 요구사항 6-3, 6-4: 왼쪽 위 정렬
            Positioned(
              top: 15,
              left: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "당신만을 위한 상담",
                    style: AppTextStyles.extraLargeBold
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "당신을 위해 모인 '데일리마스터'와\n직접 이야기를 나누어 보세요.",
                    style: AppTextStyles.descText
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
