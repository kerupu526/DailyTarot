import 'package:daily_tarot/widgets/tarot_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _name = prefs.getString('user_name') ?? '알 수 없음';
      _age = (prefs.getInt('user_age') ?? 0).toString();
      _gender = prefs.getString('user_gender') ?? 'M';

      String rawDate = prefs.getString('user_birth_date') ?? '2000-01-01';
      _birthDate = rawDate.replaceAll('-', '.');
      _time = prefs.getString('user_time') ?? '00:00';

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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: .w800,
                          ),
                        ),
                        SizedBox(height: 35,),
                        _buildInfoBox(
                          label: '이름 : $_name',
                          onTap: () => Navigator.pushNamed(context, '/info_input')
                        ),
                        SizedBox(height: 15,),

                        Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: _buildInfoBox(
                                    label: '나이 : $_age세',
                                    onTap: () => Navigator.pushNamed(context, '/info_input_age')
                                )
                            ),
                            SizedBox(width: 15,),
                            Expanded(
                              flex: 1,
                              child: _buildGenderBox(
                                  genderCode: _gender,
                                  onTap: () => Navigator.pushNamed(context, '/info_input_gender')
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        
                        _buildInfoBox(
                            label: '생일 : $_birthDate',
                            onTap: () => Navigator.pushNamed(context, '/info_input_birth')
                        ),
                        SizedBox(height: 15,),

                        _buildInfoBox(
                            label: '태어난 시간 : $_time',
                            onTap: () => Navigator.pushNamed(context, '/info_input_time')
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
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Container(
                        padding: .symmetric(horizontal: 55, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: .circular(50),
                          gradient: LinearGradient(
                            begin: Alignment(-1, -0.8),
                            end: Alignment(0, 1),
                            colors: [Color(0xFF806381), Color(0xFF745074), Color(0xFF432267)],
                          ),
                          boxShadow: const[BoxShadow(color: Color(0x90846881), blurRadius: 3, offset: Offset(0, 6))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 가로 차지
                          children:[
                            const Text(
                              '시작하기', // ">" 기호 제거
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'NotoSansKR'),
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
        padding: .symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: .all(color: Colors.white.withValues(alpha: 0.5), width: 1),
          borderRadius: .circular(30)
        ),
        child: SvgPicture.asset(iconPath, width: 24, height: 24),
      ),
    );
  }
}
