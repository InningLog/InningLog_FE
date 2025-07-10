import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../navigation/main_navigation.dart';
import 'home_page.dart';

class OnboardingPage6 extends StatefulWidget {
  const OnboardingPage6({super.key});

  @override
  State<OnboardingPage6> createState() => _OnboardingPage6State();
}

class _OnboardingPage6State extends State<OnboardingPage6> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final int _maxLength = 10;
  String? _selectedTeam;

  final List<String> _teams = [
    '기아 타이거즈',
    '두산 베어스',
    '롯데 자이언츠',
    '삼성 라이온즈',
    '키움 히어로즈',
    '한화 이글즈',
    'KT 위즈',
    'LG 트윈스',
    'NC 다이노스',
    'SSG 랜더스',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled =
        _nicknameController.text.trim().isNotEmpty && _selectedTeam != null;
    bool isFocusedOrFilled =
        _focusNode.hasFocus || _nicknameController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 38),
            const Text(
              '닉네임을 입력해주세요!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              focusNode: _focusNode,
              maxLength: _maxLength,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isFocusedOrFilled
                    ? AppColors.primary50
                    : AppColors.gray100,
                hintText: '닉네임을 입력해주세요.',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),
                counter: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '(${_nicknameController.text.length}/$_maxLength)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary700),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 38),
            const Text(
              '응원팀을 선택해주세요!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: _teams.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 169,
                  mainAxisExtent: 70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 21,
                ),
                itemBuilder: (context, index) {
                  final team = _teams[index];
                  final isSelected = _selectedTeam == team;

                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTeam = team;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary600
                            : const Color(0xFFD3D3D3),
                      ),
                      backgroundColor: isSelected
                          ? AppColors.primary100
                          : AppColors.primary50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      team,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigation(child: HomePage()),

                    ),
                  );
                }
                    : null,

              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: isButtonEnabled
                    ? AppColors.primary700
                    : const Color(0xFFD3D3D3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              child: const Text(
                '이닝로그 시작하기',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
