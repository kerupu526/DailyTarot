import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/screens/info_input/info_confirm_screen.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/pref_keys.dart';
import '../../widgets/clock_widget.dart';
import '../../widgets/tarot_action_button.dart';
import '../../widgets/tarot_background.dart';
import '../../widgets/custom_progress_bar.dart';

class TimeInputScreen extends StatefulWidget {
  const TimeInputScreen({super.key});

  @override
  State<TimeInputScreen> createState() => _TimeInputScreenState();
}

class _TimeInputScreenState extends State<TimeInputScreen> {
  // AM/PM 토글 상태
  bool _isAm = true;
  int _hour = 9;
  int _minute = 0;
  bool _isSelectingHour = true;

  Future<void> _saveAndNavigate({bool isUnknown = false}) async {
    final prefs = await SharedPreferences.getInstance();

    int finalHour = _hour;
    int finalMinute = _minute;
    bool finalIsAm = _isAm;

    // '잘 모르겠어요' 클릭 시 09:00 AM으로 고정
    if (isUnknown) {
      finalHour = 9;
      finalMinute = 0;
      finalIsAm = true;
    }

    // 24시간제로 변환하여 저장
    int savedHour = finalHour;
    if (finalIsAm) {
      if (savedHour == 12) savedHour = 0;
    } else {
      if (savedHour != 12) savedHour += 12;
    }

    String formattedTime = "${savedHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}";
    await prefs.setString(PrefKeys.userTime, formattedTime);

    if (!mounted) return;
    pushPage(context, InfoConfirmScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return TarotBackground(
      child: Stack(
        children: [
          // 중앙 콘텐츠 영역 (시계 등 배치 예정)
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.32),
                const Text(
                  "태어난 시간을 입력해주세요.",
                  style: AppTextStyles.boldText,
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .center,
                  children: [
                    // 시간 영역
                    GestureDetector(
                      onTap: () => setState(() => _isSelectingHour = true),
                      child: Container(
                        padding: .symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: .all(
                            color: _isSelectingHour ? Colors.white.withValues(alpha: 0.5) : Colors.transparent
                          ),
                          borderRadius: .circular(15)
                        ),
                        child: Text(
                          _hour.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: _isSelectingHour ? Colors.white : Colors.white.withValues(alpha: 0.5),
                            fontSize: 38,
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: .symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: TextStyle(color: Colors.white, fontSize: 36),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => setState(() => _isSelectingHour = false),
                      child: Container(
                        padding: .symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: .all(
                            color: !_isSelectingHour ? Colors.white.withValues(alpha: 0.5) : Colors.transparent
                          ),
                          borderRadius: .circular(15)
                        ),
                        child: Text(
                          _minute.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: !_isSelectingHour ? Colors.white : Colors.white.withValues(alpha: 0.5),
                            fontSize: 38
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    SizedBox(
                      width: 48,
                      height: 64, // 위아래 32씩 딱 떨어지게 설정
                      child: Stack(
                        children: [
                          // --- [베이스 레이어] 전체 어두운 캡슐 모양 ---
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          // --- [베이스 레이어] 가운데 어두운 가로 구분선 ---
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),

                          // --- [하이라이트 레이어] AM이 선택되었을 때 윗부분 하얀 테두리 ---
                          if (_isAm)
                            Positioned(
                              top: 0, left: 0, right: 0,
                              height: 33, // 가운데 선을 완벽히 덮기 위해 33으로 설정
                              child: IgnorePointer( // 터치 방해 금지
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  ),
                                ),
                              ),
                            ),

                          // --- [하이라이트 레이어] PM이 선택되었을 때 아랫부분 하얀 테두리 ---
                          if (!_isAm)
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              height: 33, // 가운데 선을 완벽히 덮음
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                  ),
                                ),
                              ),
                            ),

                          // --- [터치 및 텍스트 레이어] ---
                          Column(
                            children:[
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _isAm = true),
                                  child: Center(
                                    child: Text(
                                      'AM',
                                      style: TextStyle(
                                        color: _isAm ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                        fontSize: 14,
                                        fontWeight: _isAm ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _isAm = false),
                                  child: Center(
                                    child: Text(
                                      'PM',
                                      style: TextStyle(
                                        color: !_isAm ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                        fontSize: 14,
                                        fontWeight: !_isAm ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: ClockWidget(
                    isHourMode: _isSelectingHour,
                    selectedValue: _isSelectingHour ? _hour : _minute,
                    onValueSelected: (val) {
                      setState(() {
                        if (_isSelectingHour) {
                          _hour = val;
                          _isSelectingHour = false;
                        } else {
                          _minute = val;
                          // --- [수정] 분 선택 시 저장 및 이동 ---
                          _saveAndNavigate(isUnknown: false);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 하단 버튼 영역 (이전 + 잘 모르겠어요)
          // --- 하단 버튼 영역 ---
          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. 이전 버튼 (선수님 코드 스타일)
                TarotActionButton(
                  text: '이전',
                  iconPath: 'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                  onTap: () => Navigator.pop(context),
                  isFlipped: false,
                ),
                const SizedBox(width: 16), // 버튼 사이 간격
                // 2. 잘 모르겠어요 버튼
                TarotActionButton(
                  text: '잘 모르겠어요',
                  iconPath: 'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                  // ---[수정] 09:00으로 저장 및 이동 ---
                  onTap: () => _saveAndNavigate(isUnknown: true),
                  isFlipped: true,
                ),
              ],
            ),
          ),

          // 최하단 진행 바 (5/5)
          const Positioned(
            bottom: 0,
            left: 5,
            right: 5,
            child: CustomProgressBar(currentStep: 5),
          ),
        ],
      ),
    );
  }
}