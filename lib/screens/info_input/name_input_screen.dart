import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/tarot_background.dart';
import '../../widgets/custom_progress_bar.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateAndSubmit(String value) async {
    final name = value.trim();
    if (name.length < 2 || name.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이름은 최소 2자, 최대 20자까지 가능합니다.'),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // TODO: 데이터 저장 후 나이 입력 화면으로 이동
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    if (!mounted) return;
    Navigator.pushNamed(context, '/info_input_age');
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
                      "이름을 입력해주세요.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    // 프로토타입처럼 텍스트와 입력창 사이에 넉넉한 간격
                    const SizedBox(height: 45),

                    // 텍스트 필드 (왼쪽 정렬 + 여백 완벽 구현)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: TextField(
                        controller: _nameController,
                        // [요구사항 반영] 커서를 왼쪽으로!
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'NotoSansKR'),
                        maxLength: 20,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _validateAndSubmit,
                        decoration: InputDecoration(
                          hintText: "이름을 입력해주세요.",
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 15,
                          ),
                          counterText: "",
                          // [요구사항 반영] 왼쪽 테두리에서 글씨가 살짝 떨어지도록 left padding 부여
                          contentPadding: const EdgeInsets.only(left: 24, top: 18, bottom: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
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
                onTap: () => Navigator.pushReplacementNamed(context, '/onboarding'),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'NotoSansKR'
                        ),
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
            child: CustomProgressBar(currentStep: 1),
          ),
        ],
      ),
    );
  }
}