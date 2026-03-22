import 'package:daily_tarot/constants/app_colors.dart';
import 'package:daily_tarot/constants/app_text_styles.dart';
import 'package:daily_tarot/screens/home/home_screen.dart';
import 'package:daily_tarot/screens/info_input/age_input_screen.dart';
import 'package:daily_tarot/screens/info_input/birth_date_input_screen.dart';
import 'package:daily_tarot/screens/info_input/gender_input_screen.dart';
import 'package:daily_tarot/screens/info_input/name_input_screen.dart';
import 'package:daily_tarot/screens/info_input/time_input_screen_dart.dart';
import 'package:daily_tarot/utils/navigation_helper.dart';
import 'package:daily_tarot/widgets/tarot_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/pref_keys.dart';

class InfoConfirmScreen extends StatefulWidget {
  const InfoConfirmScreen({super.key});

  @override
  State<InfoConfirmScreen> createState() => _InfoConfirmScreenState();
}

class _InfoConfirmScreenState extends State<InfoConfirmScreen> {
  bool _isLoading = true;
  String _name = '';
  String _age = '';
  String _gender = '';
  String _birthDate = '';
  String _time = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString(PrefKeys.userName) ?? '알 수 없음';
      _age = (prefs.getInt(PrefKeys.userAge) ?? 0).toString();
      _gender = prefs.getString(PrefKeys.userGender) ?? 'M';

      String rawDate = prefs.getString(PrefKeys.userDate) ?? '2000-01-01';
      _birthDate = rawDate.replaceAll('-', '.');
      _time = prefs.getString(PrefKeys.userTime) ?? '00:00';

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return TarotBackground(
        child: Stack(
          children: [
            Positioned.fill(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: .only(top: size.height * 0.3, bottom: 120),
                  child: Padding(
                    padding: .symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.01),
                        Text(
                          "입력한 정보가 맞는지 확인해주세요.",
                          style: AppTextStyles.boldText
                        ),
                        SizedBox(height: 35,),
                        _buildInfoBox(
                          label: '이름 : $_name',
                          onTap: () => pushPage(context, NameInputScreen())
                        ),
                        SizedBox(height: 15,),

                        Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: _buildInfoBox(
                                    label: '나이 : $_age세',
                                    onTap: () => pushPage(context, AgeInputScreen())
                                )
                            ),
                            SizedBox(width: 12,),
                            Expanded(
                              flex: 1,
                              child: _buildGenderBox(
                                  genderCode: _gender,
                                  onTap: () => pushPage(context, GenderInputScreen())
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        
                        _buildInfoBox(
                            label: '생일 : $_birthDate',
                            onTap: () => pushPage(context, BirthDateInputScreen())
                        ),
                        SizedBox(height: 15,),

                        _buildInfoBox(
                            label: '태어난 시간 : $_time',
                            onTap: () => pushPage(context, TimeInputScreen())
                        ),
                      ],
                    ),
                  ),
                )
            ),
            if (!_isLoading)
              Positioned(
                  bottom: size.height * 0.08,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        pushReplacementPage(context, HomeScreen());
                      },
                      child: Container(
                        padding: .symmetric(horizontal: 55, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: .circular(50),
                          gradient: LinearGradient(
                            begin: Alignment(-1, -0.8),
                            end: Alignment(0, 1),
                            colors: [AppColors.buttonStart, AppColors.buttonMiddle, AppColors.buttonEnd],
                          ),
                          boxShadow: const[BoxShadow(color: AppColors.buttonShadow, blurRadius: 3, offset: Offset(0, 6))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 가로 차지
                          children:[
                            const Text(
                              '시작하기', // ">" 기호 제거
                              style: AppTextStyles.boldText
                            ),
                            // 제공된 arrow_back 아이콘을 180도 회전시켜서 사용
                            Transform.rotate(
                              angle: 3.14159, // 180도 (pi)
                              child: SvgPicture.asset(
                                'assets/icons/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
          ],
        ));
  }

  Widget _buildInfoBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, // 수정하러 가기
      child: Container(
        width: double.infinity,
        padding: .symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: .all(color: Colors.white.withValues(alpha: 0.5), width: 1),
          borderRadius: .circular(30)
        ),
        child: Text(
          label,
          textAlign: .start,
          style: AppTextStyles.bodyDefault
        ),
      ),
    );
  }

  Widget _buildGenderBox({required String genderCode, required VoidCallback onTap}) {
    String iconPath = genderCode == 'M'
        ? 'assets/icons/male_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg'
        : 'assets/icons/female_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: .all(color: Colors.white.withValues(alpha: 0.5), width: 1),
          borderRadius: .circular(40)
        ),
        child: SvgPicture.asset(iconPath, width: 32, height: 32),
      ),
    );
  }
}
