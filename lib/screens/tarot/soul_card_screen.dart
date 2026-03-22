import 'package:daily_tarot/constants/app_colors.dart';
import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/constants/pref_keys.dart';
import 'package:daily_tarot/screens/tarot/my_soul_card_screen.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:daily_tarot/widgets/tarot_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 휠 스크롤 달력을 위해 추가
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/home_background.dart';

class SoulCardScreen extends StatefulWidget {
  const SoulCardScreen({super.key});

  @override
  State<SoulCardScreen> createState() => _SoulCardScreenState();
}

class _SoulCardScreenState extends State<SoulCardScreen> {
  DateTime? _selectedDate; // 선택된 생년월일
  int _currentMoons = 0;   // 현재 보유 달 개수

  @override
  void initState() {
    super.initState();
    _loadMoonCount();
  }

  // 달 개수 불러오기
  Future<void> _loadMoonCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentMoons = prefs.getInt(PrefKeys.moonCount) ?? 10;
    });
  }

  // --- 요구사항 2: 평면 직선 휠 + 무한 스크롤(순환) + 개별 하이라이트 완벽 구현 ---
  void _showDatePickerDialog() {
    DateTime now = DateTime.now();
    int tempYear = _selectedDate?.year ?? now.year;
    int tempMonth = _selectedDate?.month ?? now.month;
    int tempDay = _selectedDate?.day ?? now.day;

    int selectedYearIndex = tempYear - 1900;
    int selectedMonthIndex = tempMonth - 1;
    int selectedDayIndex = tempDay - 1;

    FixedExtentScrollController yearController = FixedExtentScrollController(initialItem: selectedYearIndex);
    FixedExtentScrollController monthController = FixedExtentScrollController(initialItem: selectedMonthIndex);
    FixedExtentScrollController dayController = FixedExtentScrollController(initialItem: selectedDayIndex);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 다이얼로그 배경색

          // 🔥 [핵심 1] 이 녀석이 그라데이션을 덮어버리는 주범입니다! 무조건 투명하게 죽여야 합니다.
          surfaceTintColor: Colors.transparent,

          // 🔥 [핵심 2] 그림자 색상도 투명하게 해야 테두리(.all)가 깔끔하게 보입니다.
          shadowColor: Colors.transparent,

          elevation: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: .all(20),
            // [선수님 코드 원본 그대로]
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: .topLeft,
                    end: .bottomRight,
                    colors:[
                      AppColors.buttonEnd,
                      AppColors.backgroundBottom
                    ]
                ),
                borderRadius: .circular(20),
                border: .all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1
                )
            ),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                // 해당 월의 마지막 날짜 계산 (윤년 등 보정)
                int maxDays = DateTime(tempYear, tempMonth + 1, 0).day;

                // 만약 선택된 일이 새로운 달의 마지막 날보다 크다면 최대일로 보정 (예: 1월 31일 -> 2월 선택 시 28일로)
                if (tempDay > maxDays) {
                  tempDay = maxDays;
                }
                selectedDayIndex = tempDay - 1;

                // [핵심] 월이 바뀌어 maxDays가 변하면 무한 스크롤의 절대 인덱스(absolute index)가 꼬임
                // 이를 방지하기 위해 화면이 그려진 직후 인덱스를 강제로 재정렬
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (dayController.hasClients) {
                    int currentAbs = dayController.selectedItem;
                    int currentModulo = currentAbs % maxDays;
                    // 현재 표시되는 요일과 선택된 요일이 어긋난 경우 보정
                    if (currentModulo != selectedDayIndex) {
                      int targetAbs = currentAbs - currentModulo + selectedDayIndex;
                      dayController.jumpToItem(targetAbs);
                    }
                  }
                });

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    // 타이틀
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "생년월일 선택",
                        style: AppTextStyles.largeBold.copyWith(
                            fontFamily: 'NotoSansKR'
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),
                    const SizedBox(height: 16),

                    // --- 평면(2D) 휠 영역 ---
                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children:[
                          // 1. 3개의 휠 스크롤 (연, 월, 일)
                          Row(
                            children:[
                              //[연도 휠 - 연도는 순환하지 않음 (1900년 이전으로 돌아가면 안 되니까!)]
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: yearController,
                                  itemExtent: 45,
                                  perspective: 0.0001,
                                  diameterRatio: 3.0,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setDialogState(() {
                                      selectedYearIndex = index;
                                      tempYear = 1900 + index;
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: now.year - 1900 + 1,
                                    builder: (context, index) {
                                      bool isSelected = index == selectedYearIndex;
                                      return Center(
                                        child: Text(
                                          "${1900 + index}",
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                                            fontSize: isSelected ? 20 : 22,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              //[월 휠 - 무한 순환 적용!!]
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: monthController,
                                  itemExtent: 45,
                                  perspective: 0.0001,
                                  diameterRatio: 3.0,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setDialogState(() {
                                      selectedMonthIndex = index % 12; // 12로 나눈 나머지
                                      tempMonth = selectedMonthIndex + 1;
                                    });
                                  },
                                  childDelegate: ListWheelChildLoopingListDelegate( // 순환 델리게이트!
                                    children: List.generate(12, (index) {
                                      bool isSelected = index == selectedMonthIndex;
                                      return Center(
                                        child: Text(
                                          (index + 1).toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                                            fontSize: isSelected ? 20 : 22,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              //[일 휠 - 무한 순환 적용!!]
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: dayController,
                                  itemExtent: 45,
                                  perspective: 0.0001,
                                  diameterRatio: 3.0,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setDialogState(() {
                                      selectedDayIndex = index % maxDays; // maxDays로 나눈 나머지
                                      tempDay = selectedDayIndex + 1;
                                    });
                                  },
                                  childDelegate: ListWheelChildLoopingListDelegate( // 순환 델리게이트!
                                    children: List.generate(maxDays, (index) {
                                      bool isSelected = index == selectedDayIndex;
                                      return Center(
                                        child: Text(
                                          (index + 1).toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                                            fontSize: isSelected ? 20 : 22,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // 2. 짧은 가로 구분선 3개 오버레이
                          IgnorePointer(
                            child: SizedBox(
                              height: 45,
                              child: Row(
                                children:[
                                  Expanded(child: _buildShortDivider()),
                                  Expanded(child: _buildShortDivider()),
                                  Expanded(child: _buildShortDivider()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),
                    const SizedBox(height: 8),

                    // --- 하단 취소 / 선택 버튼 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:[
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text("취소", style: AppTextStyles.bodyMedium),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            DateTime picked = DateTime(tempYear, tempMonth, tempDay);
                            if (picked.isAfter(now)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미래의 날짜는 선택할 수 없습니다.')));
                              return;
                            }
                            setState(() => _selectedDate = picked);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text("선택", style: AppTextStyles.boldText.copyWith(
                                fontFamily: 'NotoSansKR'
                            )),
                          ),
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 각 칼럼(연, 월, 일)의 가운데에 들어가는 짧은 구분선 위젯
  Widget _buildShortDivider() {
    return Container(
      // [디테일] 좌우 여백을 주어 선이 길게 이어지지 않고 숫자 아래에서 짤막하게 보이도록 함
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
        ),
      ),
    );
  }

  // --- 요구사항 4, 5: 달 부족 검사 및 차감 로직 ---
  Future<void> _checkAndNavigate() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('생년월일을 선택해주세요.', style: TextStyle(fontFamily: 'NotoSansKR')),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentMoons < 10) {
      // 달 부족 시 안내 메시지 팝업
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.homeBackground,
          title: const Text('달 부족', style: TextStyle(color: Colors.white, fontFamily: 'NotoSansKR')),
          content: const Text('달이 부족합니다.\n충전 후 다시 시도해주세요.', style: TextStyle(color: Colors.white70, fontFamily: 'NotoSansKR')),
          actions:[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // 통과 시 10개 차감 및 저장
    setState(() => _currentMoons -= 10);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKeys.moonCount, _currentMoons);

    // 선택된 생년월일을 다음 화면(애니메이션+결과)으로 전달하기 위해 저장
    String formattedDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    await prefs.setString(PrefKeys.soulDate, formattedDate);

    if (!mounted) return;

    pushAndRemoveAllPage(context, MySoulCardScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return HomeBackground(
      child: Column(
        children:[
          // --- 1. 상단 뒤로가기 버튼 ---
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: SvgPicture.asset(
                  'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                  width: 24, height: 24,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),

          // --- 2. 타이틀 영역 ---
          const SizedBox(height: 10),
          Image.asset('assets/images/graphic.png', width: 45), // 가운데 작은 그래픽
          const SizedBox(height: 15),
          Text(
            "나의 생일로 알아보는 소울카드",
            style: AppTextStyles.extraLargeBold
          ),

          const SizedBox(height: 40),

          // --- 3. 본문 텍스트 (RichText를 활용한 특정 단어 강조 완벽 구현) ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children:[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      // 기본 텍스트 스타일
                      style: AppTextStyles.storytelling.copyWith(
                        height: 2.2
                      ),
                      children:[
                        TextSpan(text: '소울 넘버', style: TextStyle(color: AppColors.highlightYellow, fontWeight: FontWeight.bold)),
                        TextSpan(text: '는 생년월일의 숫자를 모두 더해\n얻는 최종적인 한 자리 숫자로,\n당신의 핵심적인 에너지와 삶의 테마를 나타냅니다.\n이 소울 넘버에 해당하는\n메이저 아르카나 타로 카드가 바로 '),
                        TextSpan(text: '소울 카드', style: TextStyle(color: AppColors.highlightYellow, fontWeight: FontWeight.bold)),
                        TextSpan(text: '이며,\n이는 당신의 타고난 성격, 기질,\n그리고 삶의 목적을 상징합니다.\n즉, 소울 넘버는 당신의 '),
                        TextSpan(text: '영혼의 번호', style: TextStyle(color: AppColors.highlightYellow, fontWeight: FontWeight.bold)),
                        TextSpan(text: '이고,\n소울 카드는 그 번호가 의미하는\n'),
                        TextSpan(text: '영혼의 본질', style: TextStyle(color: AppColors.highlightYellow, fontWeight: FontWeight.bold)),
                        TextSpan(text: '을 보여주는 상징인 셈입니다.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 생년월일 선택 버튼
                  GestureDetector(
                    onTap: _showDatePickerDialog,
                    child: Container(
                      width: size.width * 0.63,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          _selectedDate == null
                              ? "생년월일을 선택해주세요 >"
                              : "${_selectedDate!.year}.${_selectedDate!.month.toString().padLeft(2,'0')}.${_selectedDate!.day.toString().padLeft(2,'0')} >",
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.white54 : Colors.white,
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 4. 하단 버튼 영역 ---
          Padding(
            padding: const EdgeInsets.only(bottom: 70, left: 45, right: 45),
            child: Column(
              children:[
                // 달 10개로 찾기 버튼
                TarotGradientButton(text: '달 10개로 소울카드 찾기', prefixIcon: Image.asset('assets/images/moon.png', width: 20,), onTap: _checkAndNavigate),

                const SizedBox(height: 10),

                // 주의사항 텍스트
                const Text(
                  "소울카드에 사용되는 정보는\n카드 조합 용도 외에 사용되지 않습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'NotoSansKR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}