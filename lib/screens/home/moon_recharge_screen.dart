import 'package:daily_tarot/constants/pref_keys.dart';
import 'package:daily_tarot/widgets/home_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoonRechargeScreen extends StatefulWidget {
  const MoonRechargeScreen({super.key});

  @override
  State<MoonRechargeScreen> createState() => _MoonRechargeScreenState();
}

class _MoonRechargeScreenState extends State<MoonRechargeScreen> {
  int _currentMoons = 0;

  // 충전 리스트 데이터화
  final List<Map<String, dynamic>> _rechargeItems = [
    {'amount': 25, 'discount': '약 750원 할인', 'price': '5,500원'},
    {'amount': 50, 'discount': '약 2,600원 할인', 'price': '9,900원'},
    {'amount': 75, 'discount': '약 4,750원 할인', 'price': '14,000원'},
    {'amount': 100, 'discount': '약 8,000원 할인', 'price': '17,000원'},
    {'amount': 200, 'discount': '약 17,000원 할인', 'price': '33,000원'},
    {'amount': 300, 'discount': '약 32,000원 할인', 'price': '55,000원'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentMoons();
  }

  // 보유중인 달 개수 표시
  Future<void> _loadCurrentMoons() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentMoons = prefs.getInt(PrefKeys.moonCount) ?? 10;
    });
  }

  // 항목 클릭 시 충전 및 업데이트, 토스트 표시
  Future<void> _rechargeMoon(int addedAmount) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _currentMoons += addedAmount;
    });
    await prefs.setInt(PrefKeys.moonCount, _currentMoons); // 로컬 저장

    if (!mounted) return;

    // 구매 완료 토스트 팝업
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '달 $addedAmount개가 충전되었습니다!\n(현재 $_currentMoons개 보유 중',
          textAlign: .center,
          style: TextStyle(fontFamily: 'NotoSansKR', fontWeight: .w500),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(borderRadius: .circular(20)),
        margin: .only(bottom: 40, left: 40, right: 40),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: Column(
        crossAxisAlignment: .center,
        children: [
          // 상단 뒤로가기 버튼
          Align(
            alignment: .centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // 홈 화면으로 이동
              child: Padding(
                padding: .only(left: 20, top: 15, bottom: 5),
                child: SvgPicture.asset(
                  'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                  // 공통 아이콘
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          Image.asset('assets/images/graphic.png', width: 70),
          Text(
            "달 충전",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: .w600,
            ),
          ),
          SizedBox(height: 30),

          const Text(
            "현재 보유중인 달",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: .w500,
              fontFamily: 'NotoSansKR',
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: .center,
            children: [
              Image.asset('assets/images/moon.png', width: 48, height: 48),
              SizedBox(width: 8),
              Text(
                '$_currentMoons',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansKR',
                ),
              ),
            ],
          ),

          // 달 충전 리스트 영역
          Expanded(
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              padding: .symmetric(horizontal: 20, vertical: 8),
              itemCount: _rechargeItems.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.2),
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final item = _rechargeItems[index];

                return InkWell(
                  onTap: () => {
                    _rechargeMoon(item['amount'])

                  },
                  splashColor: Colors.white.withValues(alpha: 0.1),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: .symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/moon.png',
                          width: 48,
                          height: 48,
                        ),

                        SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              "달 ${item['amount']}개",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: .w400,
                                fontFamily: 'NotoSansKR',
                              ),
                            ),
                            Text(
                              item['discount'],
                              style: TextStyle(
                                color: Color(0xffffcf00),
                                fontSize: 12,
                                fontWeight: .w500,
                                fontFamily: 'NotoSansKR',
                              ),
                            ),
                          ],
                        ),
                        Spacer(),

                        Text(item['price'], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: .w400, fontFamily: 'NotoSansKR'),)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
