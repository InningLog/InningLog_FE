// lib/pages/post_compose_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/app_colors.dart';

class PostComposePage extends StatefulWidget {
  final String teamLabel; // 예: '두산 베어스 🐻'
  const PostComposePage({super.key, required this.teamLabel});

  @override
  State<PostComposePage> createState() => _PostComposePageState();
}

class _PostComposePageState extends State<PostComposePage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _titleFocus = FocusNode();

  bool _titleFocused = false;
  ImageProvider? _attachedImage; // 데모: 1장만

  @override
  void initState() {
    super.initState();
    _titleFocus.addListener(() {
      setState(() => _titleFocused = _titleFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _pickImage() async {
    // TODO: image_picker 연동
    // 데모용 회색 사각형 이미지 대체 (없으면 null 그대로)
    setState(() {
      _attachedImage = const AssetImage('assets/images/placeholder_square.png');
    });
  }

  void _removeImage() {
    setState(() => _attachedImage = null);
  }

  void _submit() {
    // TODO: 등록 API
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 스크롤 영역
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120), // 하단바 공간
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComposeAppBar(
                    teamLabel: widget.teamLabel,
                    onClose: () => Navigator.of(context).pop(),
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 12),

                  // 제목
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _titleFocused ? AppColors.gray400 : Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _titleCtrl,
                      focusNode: _titleFocus,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        fontFamily: 'Pretendard',
                      ),
                      decoration: const InputDecoration(
                        hintText: '제목을 입력해주세요.',
                        hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600,
                          fontFamily: 'Pretendard',
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 본문
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray900,
                      fontFamily: 'Pretendard',
                    ),
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요.',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray600,
                        fontFamily: 'Pretendard',
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 선택된 이미지 미리보기 (본문 영역에도 노출)
                  if (_attachedImage != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: _attachedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 하단 툴바 (키보드 위로 붙음)
            AnimatedPadding(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: SafeArea(
                  top: false,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 이미지 버튼 (좌측)
                        _ToolbarIconButton(
                          asset: 'assets/icons/image.svg', // 없으면 errorBuilder로 fallback
                          onTap: _pickImage,
                        ),
                        const SizedBox(width: 12),

                        // 썸네일 (작게, 스샷 우측 예시)
                        if (_attachedImage != null)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: _attachedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -6,
                                top: -6,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
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

class _ComposeAppBar extends StatelessWidget {
  final String teamLabel;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const _ComposeAppBar({
    required this.teamLabel,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          // 좌측 닫기(X) — back_board.svg 사용
          IconButton(
            onPressed: onClose,
            icon: SvgPicture.asset(
              'assets/icons/cancel_but.svg',
              width: 15,
              height: 15,
              // 필요 시 색 입히기:
              // colorFilter: const ColorFilter.mode(Color(0xFF1F2937), BlendMode.srcIn),
            ),
          ),
          const Spacer(),

          // 중앙 타이틀/팀
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '글쓰기',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gray900,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                teamLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray700,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const Spacer(),

          // 우측 등록
          TextButton(
            onPressed: onSubmit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              foregroundColor: AppColors.gray400,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
              ),
            ),
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _ToolbarIconButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 22,
            height: 22,
            // SVG 없을 때 대비
            placeholderBuilder: (_) => const Icon(Icons.image_outlined, size: 20),
            // 필요 시 색:
            // colorFilter: const ColorFilter.mode(Color(0xFF4B5563), BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
