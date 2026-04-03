import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/feature/mypage/viewmodel/profile_edit_view_model.dart';
import 'package:inninglog/feature/user/repositories/user_repository.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

// =====================================================
// 진입점
// 사용법: ProfileEditFlow.start(context, profile: vm.profile!)
// =====================================================
class ProfileEditFlow {
  static Future<bool> start(
    BuildContext context, {
    required MemberProfileResponse profile,
  }) async {
    final repo =
        Provider.of<AppScope>(context, listen: false).userRepository;
    final vm = ProfileEditViewModel(
      repo: repo,
      nickname: profile.nickname,
      profileUrl: profile.profileUrl,
      teamShortCode: profile.teamShortCode,
    );

    final updated = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const ProfileEditScreen(),
        ),
      ),
    );

    return updated == true;
  }
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nicknameController;
  final FocusNode _focusNode = FocusNode();
  final int _maxLength = 10;

  bool get _isValid =>
      _nicknameController.text.isNotEmpty &&
      _nicknameController.text.length <= _maxLength;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ViewModel의 현재 닉네임으로 초기화 (한 번만)
    if (!_controllerInitialized) {
      final vm = context.read<ProfileEditViewModel>();
      _nicknameController = TextEditingController(text: vm.nickname);
      _nicknameController.addListener(() => setState(() {}));
      _controllerInitialized = true;
    }
  }

  bool _controllerInitialized = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onPickImage() async {
    await context.read<ProfileEditViewModel>().pickImage();
  }

  Future<void> _onComplete() async {
    final vm = context.read<ProfileEditViewModel>();
    final success = await vm.save(_nicknameController.text);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? '저장에 실패했어요.'),
          backgroundColor: AppColors.secondary700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileEditViewModel>();
    final hasPickedImage = vm.pickedImageBytes != null;
    final hasProfileUrl = vm.profileUrl.isNotEmpty;
    final teamColor = kboTeamColorOf(vm.teamShortCode);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 타이틀 + 닫기 버튼
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '프로필 편집',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.2,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Icon(
                        Icons.close,
                        size: 26,
                        color: Color(0xFFBCBCBC),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 46),

                    // 프로필 이미지
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 141,
                            height: 141,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: teamColor,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(11),
                              child: ClipOval(
                                  child: hasPickedImage
                                      ? Image.memory(
                                          vm.pickedImageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : hasProfileUrl
                                          ? Image.network(
                                              vm.profileUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _onPickImage,
                              child: SvgPicture.asset(
                                'assets/icons/cameraIcon.svg',
                                width: 39,
                                height: 39,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 닉네임 라벨
                    const Text(
                      '닉네임',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF272727),
                        fontFamily: 'Pretendard',
                        letterSpacing: -0.18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 닉네임 입력 필드
                    TextField(
                      controller: _nicknameController,
                      focusNode: _focusNode,
                      maxLength: _maxLength,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(_maxLength),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF272727),
                        fontFamily: 'Pretendard',
                        height: 1.25,
                        letterSpacing: -0.16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력하세요',
                        hintStyle:
                            const TextStyle(color: Colors.black38),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary700,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // 글자 수 카운터
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 2),
                      child: Text(
                        '(${_nicknameController.text.length}/$_maxLength)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray500,
                          fontFamily: 'Pretendard',
                          height: 1.42857,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // 완료 버튼
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 39 + MediaQuery.of(context).viewInsets.bottom,
                top: 8,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _isValid ? _onComplete : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary700,
                          disabledBackgroundColor:
                              const Color(0xFFCCCCCC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                            letterSpacing: -0.16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
