import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inninglog/app_colors.dart';

class AddSeatPage extends StatefulWidget {
  const AddSeatPage({super.key});

  @override
  State<AddSeatPage> createState() => _AddSeatPageState();
}

class _AddSeatPageState extends State<AddSeatPage> {
  String? selectedZone;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();
  File? seatImage;
  final List<String> selectedTags = [];

  final List<String> hashTags = [
    "#시야_탁트임", "#햇빛_강함", "#응원_분위기_최고","#응원_분위기_최고",
    "#응원_단상_가까움", "#가성비_최고", "#지붕_있어요",
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        seatImage = File(picked.path);
      });
    }
  }

  bool get isFormValid {
    return selectedZone != null &&
        sectionController.text.trim().isNotEmpty &&
        rowController.text.trim().isNotEmpty &&
        seatImage != null;
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ 네가 만든 커스텀 헤더 - 유지함
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/back_but.svg',
                      width: 10,
                      height: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 0),
                  const Text(
                    '직관 일지 작성',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.26,
                      color: Color(0xFF272727),
                      fontFamily: 'MBC1961GulimOTF',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/Alarm.svg',
                      width: 18.05,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ✅ 본문: 스크롤 가능한 입력폼
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 경기 정보 박스
                    Container(
                      width: double.infinity,
                      height: 79,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFDFEFC) ,
                        border: Border.all(
                            color: AppColors.primary400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '잠실 종합운동장 잠실야구장',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '06.26(목) 17:00',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '오늘 앉은 좌석',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: '존을 선택하세요.',
                        hintStyle: TextStyle(
                          color: AppColors.gray700,         // 글자 색
                          fontSize: 16,               // 글자 크기
                          fontWeight: FontWeight.w500, // 두께
                          fontFamily: 'Pretendard',   // 폰트 (지정했을 경우)
                        ),
                        filled: true, // 내부 색상 적용하려면 이거 true!
                        fillColor: AppColors.gray100, // 내부 배경 색상 (연한 회색 등)
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300), // 기본 border 색상
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300), // 비활성 상태 테두리
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                          // 포커스 시 테두리
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      value: selectedZone,
                      items: ['1루', '3루', '중앙', '외야'].map((zone) {
                        return DropdownMenuItem(value: zone, child: Text(zone));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedZone = value);
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sectionController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'ex) 314',
                              hintStyle: TextStyle(
                                color: AppColors.gray700,         // 글자 색
                                fontSize: 16,               // 글자 크기
                                fontWeight: FontWeight.w500, // 두께
                                fontFamily: 'Pretendard',   // 폰트 (지정했을 경우)
                              ),
                              filled: true, // 내부 색상 적용하려면 이거 true!
                              fillColor: AppColors.gray100, // 내부 배경 색상 (연한 회색 등)
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300), // 기본 border 색상
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300), // 비활성 상태 테두리
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                                // 포커스 시 테두리
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('구역',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                            ),),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: rowController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'ex) 3',
                              hintStyle: TextStyle(
                                color: AppColors.gray700,         // 글자 색
                                fontSize: 16,               // 글자 크기
                                fontWeight: FontWeight.w500, // 두께
                                fontFamily: 'Pretendard',   // 폰트 (지정했을 경우)
                              ),

                              filled: true, // 내부 색상 적용하려면 이거 true!
                              fillColor: AppColors.gray100, // 내부 배경 색상 (연한 회색 등)
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300), // 기본 border 색상
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300), // 비활성 상태 테두리
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                                // 포커스 시 테두리
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('열' ,
                          style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),),
                      ],
                    ),

                    const SizedBox(height: 26),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '좌석 시야 사진',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                DiaryImagePicker(
                  onImageSelected: (file) {
                    setState(() {
                      seatImage = file; // ✅ 이게 있어야 isFormValid가 true가 됨
                    });
                  },
                ),

                  const SizedBox(height: 26),
                    const Text('좌석 해시태그',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),),
                    const Text(
                      '최대 2개까지 고를 수 있어요.',
                      style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hashTags.map((tag) {
                        final selected = selectedTags.contains(tag);
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(tag),
                          selected: selected,
                          onSelected: (selectedNow) {
                            setState(() {
                              if (selectedNow) {
                                if (selectedTags.length < 2) {
                                  selectedTags.add(tag);
                                }
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                          selectedColor: AppColors.primary100, // 선택됐을 때 배경색
                          backgroundColor: Colors.white
                          , // 선택 안 됐을 때 배경색
                          labelStyle: TextStyle(
                            color: selected ?  Color(0xFF272727) : AppColors.gray700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // ✅ 모서리 둥글게 8
                            side: BorderSide(
                              color: selected ? AppColors.primary700 :AppColors.gray300, // ✅ 테두리 색
                              width: 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),


                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isFormValid ? () {
                          // 작성 완료 처리
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormValid ? AppColors.primary700 : AppColors.gray200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                            side: BorderSide(
                              color: isFormValid ? AppColors.primary700 : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          '작성 완료',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isFormValid ? Colors.white : AppColors.gray700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DiaryImagePicker extends StatefulWidget {
  final Function(File) onImageSelected;

  const DiaryImagePicker({super.key, required this.onImageSelected});

  @override
  State<DiaryImagePicker> createState() => _DiaryImagePickerState();
}

class _DiaryImagePickerState extends State<DiaryImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final file = File(image.path);
      setState(() {
        _pickedImage = file;
      });
      widget.onImageSelected(file); // ✅ 부모에게 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          color: const Color(0xFFF5F5F5),
        ),
        child: _pickedImage == null
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
            child: Icon(Icons.camera_alt, size: 28.3, color: Colors.grey),
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _pickedImage!,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
