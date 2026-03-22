import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/screens/info_input/time_input_screen_dart.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/pref_keys.dart';
import '../../widgets/tarot_background.dart';
import '../../widgets/custom_progress_bar.dart';

class BirthDateInputScreen extends StatefulWidget {
  const BirthDateInputScreen({super.key});

  @override
  State<BirthDateInputScreen> createState() => _BirthDateInputScreenState();
}

class _BirthDateInputScreenState extends State<BirthDateInputScreen> {
  // 현재 달력에서 보고 있는 연도와 월을 추적 (기본값: 오늘 날짜)
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 달력은 '일(day)'과 상관없이 해당 월의 1일을 기준으로 계산하는 것이 편합니다.
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  // 1. 연도와 월을 선택하는 팝업 다이얼로그
  void _showYearMonthPicker() {
    int tempYear = _focusedMonth.year;
    int tempMonth = _focusedMonth.month;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.homeBackground, // 배경톤에 맞춘 어두운 보라색
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('연도와 월 선택', style: AppTextStyles.largeText.copyWith(
              fontFamily: 'NotoSansKR'
          )),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Row(
                children:[
                  // 연도 선택 드롭다운
                  Expanded(
                    child: DropdownButton<int>(
                      value: tempYear,
                      dropdownColor: AppColors.birthDropDown,
                      isExpanded: true,
                      style: AppTextStyles.bodyDefault.copyWith(fontFamily: 'NotoSansKR'),
                      // 1900년부터 현재 연도까지 리스트 생성
                      items: List.generate(130, (i) => DateTime.now().year - i)
                          .map((y) => DropdownMenuItem(value: y, child: Text('$y년')))
                          .toList(),
                      onChanged: (val) => setDialogState(() => tempYear = val!),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // 월 선택 드롭다운
                  Expanded(
                    child: DropdownButton<int>(
                      value: tempMonth,
                      dropdownColor: AppColors.birthDropDown,
                      isExpanded: true,
                      style: AppTextStyles.bodyDefault.copyWith(fontFamily: 'NotoSansKR'),
                      // 1월부터 12월까지
                      items: List.generate(12, (i) => i + 1)
                          .map((m) => DropdownMenuItem(value: m, child: Text('$m월')))
                          .toList(),
                      onChanged: (val) => setDialogState(() => tempMonth = val!),
                    ),
                  ),
                ],
              );
            },
          ),
          actions:[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // 확인 누르면 달력 뷰 업데이트
                setState(() {
                  _focusedMonth = DateTime(tempYear, tempMonth, 1);
                });
                Navigator.pop(context);
              },
              child: const Text('선택', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 2. 달력에 표시할 42일(6주)치 날짜 계산 함수 (초격차 팁!)
  List<DateTime> _getCalendarDays() {
    // 이번 달 1일의 요일 (월요일=1, 일요일=7)
    int weekdayOfFirstDay = _focusedMonth.weekday;
    // 일요일(7)부터 시작하도록 달력 앞의 빈 칸(이전 달 날짜) 계산
    int daysToSubtract = weekdayOfFirstDay == 7 ? 0 : weekdayOfFirstDay;

    // 달력의 가장 첫 번째 칸에 들어갈 날짜
    DateTime startDate = _focusedMonth.subtract(Duration(days: daysToSubtract));

    // 총 42칸(7일 * 6줄)의 날짜 리스트 생성
    return List.generate(42, (index) => startDate.add(Duration(days: index)));
  }

  // 3. 날짜 클릭 시 저장 및 다음 화면 이동
  Future<void> _onDateSelected(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    // 날짜를 YYYY-MM-DD 형태로 저장
    String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await prefs.setString(PrefKeys.userDate, formattedDate);

    if (!mounted) return;
    // 다음 화면(시간 입력)으로 이동
    pushPage(context, TimeInputScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final calendarDays = _getCalendarDays();

    return TarotBackground(
      child: Stack(
        children:[
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top: size.height * 0.32, bottom: 150),
                child: Column(
                  children:[
                    const Text(
                      "태어난 날짜를 입력해주세요.",
                      style: AppTextStyles.boldText,
                    ),
                    const SizedBox(height: 30),

                    // [요구사항] {년}.{월} 텍스트 (클릭 시 팝업)
                    GestureDetector(
                      onTap: _showYearMonthPicker,
                      child: Text(
                        "${_focusedMonth.year}.${_focusedMonth.month}",
                        style: AppTextStyles.titleText.copyWith(
                            fontFamily: '나눔명조',
                          fontWeight: .w600
                        )
                      ),
                    ),
                    const SizedBox(height: 10),

                    // [핵심] 커스텀 달력 그리드 뷰
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: GridView.builder(
                        shrinkWrap: true, // ScrollView 안에서 쓰기 위해 필수
                        physics: const NeverScrollableScrollPhysics(), // 자체 스크롤 방지
                        itemCount: 42, // 7일 * 6줄
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7, // 일주일은 7일
                          childAspectRatio: 1.2, // 숫자가 들어갈 칸의 가로세로 비율
                        ),
                        itemBuilder: (context, index) {
                          DateTime date = calendarDays[index];
                          // 현재 보고 있는 월의 날짜인지 판별 (이전/다음 달 날짜는 흐리게)
                          bool isCurrentMonth = date.month == _focusedMonth.month;

                          return GestureDetector(
                            onTap: () => _onDateSelected(date),
                            child: Center(
                              child: Text(
                                '${date.day}', // 날짜 숫자만 표시
                                style: TextStyle(
                                  // 현재 월이면 흰색, 아니면 흐린 흰색 (도면 반영)
                                  color: isCurrentMonth ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                  fontSize: 16,
                                  fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 하단 < 이전 버튼 ---
          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(60)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      SvgPicture.asset(
                        'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                        width: 20, height: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '이전',
                        style: AppTextStyles.bodyDefault,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- 최하단 진행 바 (4/5) ---
          const Positioned(
            bottom: 0,
            left: 5,
            right: 5,
            child: CustomProgressBar(currentStep: 4), // 4단계로 변경!
          ),
        ],
      ),
    );
  }
}