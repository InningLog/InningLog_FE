// lib/pages/post_compose_page.dart
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart'; // ✅ 갤러리
import 'package:inninglog/shared/theme/app_colors.dart';

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
  bool _isFilled = false;

  // ✅ 여러 장 첨부 (최대 5장)
  final List<ImageProvider> _attachedImages = [];
  static const int _maxImages = 5;

  // 하단 영역 고정 높이
  static const double _toolbarHeight = 72;
  static const double _footerHeight = 104; // 경고문구 영역 높이(디자인 여백 포함)

  @override
  void initState() {
    super.initState();
    _titleFocus.addListener(() {
      setState(() => _titleFocused = _titleFocus.hasFocus);
    });

    // ✅ 제목/본문 입력 변화 감지해서 _isFilled 갱신
    _titleCtrl.addListener(_updateFilled);
    _bodyCtrl.addListener(_updateFilled);
  }

// ✅ 제목과 본문이 모두 채워져야 활성화
  void _updateFilled() {
    final filled = _titleCtrl.text.trim().isNotEmpty
        && _bodyCtrl.text.trim().isNotEmpty; // ← AND로 변경
    if (_isFilled != filled) {
      setState(() => _isFilled = filled);
    }
  }






  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_attachedImages.length >= _maxImages) return;

    final remain = _maxImages - _attachedImages.length;
    final picker = ImagePicker();

    // ✅ 다중 선택
    final files = await picker.pickMultiImage(
      imageQuality: 85,
      limit: remain, // 일부 기기만 적용, 초과 시 수동 컷
    );

    if (files.isEmpty) return;

    final List<ImageProvider> next = [];
    for (final x in files.take(remain)) {
      if (kIsWeb) {
        final bytes = await x.readAsBytes();
        next.add(MemoryImage(bytes));
      } else {
        next.add(FileImage(File(x.path)));
      }
    }

    if (!mounted) return;
    setState(() => _attachedImages.addAll(next));
  }

  void _removeImageAt(int index) {
    setState(() => _attachedImages.removeAt(index));
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
            // 본문 스크롤: 하단 고정(푸터+툴바) 높이만큼 여유
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(
                top: 0,
                bottom: _footerHeight + _toolbarHeight + 24, // ✅ 피그마처럼 하단과 충분히 띄움
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComposeAppBar(
                    teamLabel: widget.teamLabel,
                    onClose: () => Navigator.of(context).pop(),
                    onSubmit: _submit,
                    isFilled: _isFilled,
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
                ],
              ),
            ),

            // ✅ 하단 고정: [경고문구 푸터] + [툴바], 키보드 위로 함께 올라옴
            AnimatedPadding(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== 경고문구(푸터) =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                          ),
                        ),
                        child: const _GuidelinesFooter(), // ← 내용은 아래 위젯으로 교체
                      ),


                      // ===== 하단 툴바 =====
                      Container(
                        height: _toolbarHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            // 이미지 버튼
                            Opacity(
                              opacity: _attachedImages.length >= _maxImages ? 0.4 : 1,
                              child: _ToolbarIconButton(
                                asset: 'assets/icons/image.svg',
                                onTap: _attachedImages.length >= _maxImages ? () {} : _pickFromGallery,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 썸네일 리스트
                            Expanded(
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _attachedImages.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return _Thumb(
                                    image: _attachedImages[index],
                                    onRemove: () => _removeImageAt(index),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  final bool isFilled;

  const _ComposeAppBar({
    required this.teamLabel,
    required this.onClose,
    required this.onSubmit,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: SvgPicture.asset('assets/icons/cancel_but.svg', width: 15, height: 15),
          ),
          const Spacer(),
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
          TextButton(
            onPressed: isFilled ? onSubmit : null,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return AppColors.gray700; // 비활성 색
                }
                return AppColors.primary700; // 활성 색
              }),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              ),
              textStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
                final isDisabled = states.contains(MaterialState.disabled);
                return TextStyle(
                  fontSize: 16,
                  fontWeight: isDisabled ? FontWeight.w400 : FontWeight.w700, // ✅ 두께 변경
                  fontFamily: 'Pretendard',
                );
              }),
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.disabled)) return Colors.transparent;
                return null;
              }),
            ),
            child: const Text('등록'),
          )


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
          child: Image.asset(
            'assets/images/image-uploa.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ✅ 썸네일(56x56) + 삭제 버튼
class _Thumb extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;

  const _Thumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color (0xFF6C6C6C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, size: 12, color: AppColors.gray400),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ 하단 고정용 경고문구 (피그마 위치)
class _GuidelinesFooter extends StatelessWidget {
  const _GuidelinesFooter();

  @override
  Widget build(BuildContext context) {
    const p = TextStyle(
      fontSize: 12,
      height: 1.4,
      color: AppColors.gray600,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
    );
    const strong = TextStyle(
      fontSize: 12,
      height: 1.4,
      color: AppColors.gray700,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
    );

    Widget warning(String t) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📝', style: TextStyle(fontSize: 12, color: AppColors.gray800, fontWeight: FontWeight.w300,)),
        Expanded(child: Text(t, style: p)),
      ],
    );

    Widget bullet(String t) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('-',  style: TextStyle(fontSize: 12, color: AppColors.gray800, fontWeight: FontWeight.w300,)),
        Expanded(child: Text(t, style: p)),
      ],
    );

    Widget warn(String t) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚠️️', style: TextStyle(fontSize: 12, color: AppColors.gray800, fontWeight: FontWeight.w300,)),
        Expanded(child: Text(t, style: p)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        warning('게시물 작성 시 유의사항'),
        const SizedBox(height: 2),
        bullet('불법 도박, 음란물, 폭력성·혐오 표현, 개인정보 유출, 특정인 비방 등의 내용은 작성이 제한될 수 있습니다.'),
        const SizedBox(height: 2),
        bullet('위반 시 게시글이 삭제되거나 계정이 제한될 수 있습니다.'),
        const SizedBox(height: 8),
        warn('커뮤니티 이용 규칙을 위반한 게시물은 사전 통보 없이 삭제될 수 있습니다.'),
      ],

    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('•  ', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        Expanded(
          child: Text(
            // 스타일 고정(푸터)
            '',
            style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray600, fontFamily: 'Pretendard'),
          ),
        ),
      ],
    );
  }
}

class _Warn extends StatelessWidget {
  final String text;
  const _Warn(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('⚠️ ', style: TextStyle(fontSize: 12)),
        Expanded(
          child: Text(
            '',
            style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray700, fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
