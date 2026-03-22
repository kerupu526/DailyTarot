import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/screens/info_input/birth_date_input_screen.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/pref_keys.dart';
import '../../widgets/tarot_background.dart';
import '../../widgets/custom_progress_bar.dart';

class GenderInputScreen extends StatefulWidget {
  const GenderInputScreen({super.key});

  @override
  State<GenderInputScreen> createState() => _GenderInputScreenState();
}

class _GenderInputScreenState extends State<GenderInputScreen> {

  String? _selectedGender;

  Future<void> _selectGender(String gender) async {
    setState(() {
      _selectedGender = gender;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys.userGender, gender);

    await Future.delayed(Duration(milliseconds: 300));

    if (!mounted) return;
    pushPage(context, BirthDateInputScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // 키보드 높이

    return TarotBackground(
      child: Stack(
        children:[
          // --- 1. 중앙 텍스트 & 입력창 (스크롤 가능) ---
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                // 로고(13% 위치) 아래쪽에 안내 텍스트가 자연스럽게 오도록 상단 여백 부여
                padding: EdgeInsets.only(top: size.height * 0.32, bottom: bottomInset + 150),
                child: Column(
                  children:[
                    // 안내 텍스트 (로고 바로 아래 중앙 정렬)
                    const Text(
                      "성별을 선택해주세요.",
                      style: AppTextStyles.boldText
                    ),

                    // 프로토타입처럼 텍스트와 입력창 사이에 넉넉한 간격
                    const SizedBox(height: 80),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        // 여성 버튼
                        _buildGenderButton(
                          genderCode: 'F',
                          iconData: 'assets/icons/female_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                        ),
                        const SizedBox(width: 30), // 두 버튼 사이 간격
                        // 남성 버튼
                        _buildGenderButton(
                          genderCode: 'M',
                          iconData: 'assets/icons/male_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. 하단: < 이전 버튼 (테두리 없음, 아이콘 사용) ---
          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05), // 터치 영역 확보
                      borderRadius: .circular(60)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg', // 프로토타입 형태의 얇은 화살표
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 6), // 아이콘과 글자 사이의 간격
                      Text(
                        '이전',
                        style: AppTextStyles.bodyDefault
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- 3. 최하단: 공통 진행 바 ---
          const Positioned(
            bottom: 0,
            left: 5,
            right: 5,
            child: CustomProgressBar(currentStep: 3 ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String genderCode,
    required String iconData
}) {
    final isSelected = _selectedGender == genderCode;

    return GestureDetector(
        onTap: () => _selectGender(genderCode),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              borderRadius: .circular(20),
              color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
              border: .all(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              )
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              SvgPicture.asset(
                  iconData,
                width: 50,
                height: 50,
              )
            ],
          ),
        ),
    );
  }
}