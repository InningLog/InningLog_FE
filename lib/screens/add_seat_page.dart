import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inninglog/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_view.dart';
import '../service/api_service.dart';
import 'add_diary_page.dart';
import 'diary_page.dart';
import 'package:http/http.dart' as http;




class AddSeatPage extends StatefulWidget {
  const AddSeatPage({super.key});



  @override
  State<AddSeatPage> createState() => _AddSeatPageState();
}

class _AddSeatPageState extends State<AddSeatPage> {

  MyTeamSchedule? todaySchedule;
  DateTime currentDate = DateTime.now();

  String? selectedZone;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();
  File? seatImage;
  final Map<String, String> selectedTags = {};

  Future<void> loadTodaySchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'schedule_${currentDate.toIso8601String().split("T")[0]}';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return;

    final jsonData = jsonDecode(jsonString);
    setState(() {
      todaySchedule = MyTeamSchedule.fromJson(jsonData);
    });
  }


  // 각 카테고리 정의
  final Map<String, List<String>> tagCategories = {
    '응원': ['#일어남', '#일어날_사람은_일어남', '#앉아서'],
    '햇빛': ['#강함', '#있다가_그늘짐', '#없음'],
    '지붕': ['#있음', '#없음'],
    '시야 방해': ['#그물', '#아크릴_가림막', '#없음'],
    '좌석 공간': ['#아주_넓음', '#넓음', '#보통', '#좁음'],
  };


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        seatImage = File(picked.path);
      });
    }
  }

  //버튼 활성화 조건
  bool get isFormValid {
    return selectedZone != null &&
        sectionController.text.trim().isNotEmpty &&
        rowController.text.trim().isNotEmpty &&
        seatImage != null&&
        selectedTags.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    loadTodaySchedule();
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
                      child: todaySchedule == null
                          ? const Text('경기 정보 없음')
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stadiumNameMap[todaySchedule!.stadium] ?? todaySchedule!.stadium,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todaySchedule!.gameDateTime.replaceAll('-', '.'),
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
                    const Text('좌석에 관한 해시태그로 검색해보세요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),),
                    const Text(
                      '최대 5개까지 고를 수 있어요.',
                      style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tagCategories.entries.map((entry) {
                        final category = entry.key;
                        final tags = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category,
                                style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                  fontSize: 14,)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: tags.map((tag) {
                                final selected = selectedTags[category] == tag;
                                return ChoiceChip(
                                  showCheckmark: false, // ✅ 체크 아이콘 제거
                                  label: Text(tag),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      if (selected) {
                                        // ✅ 이미 선택된 경우 → 해제
                                        selectedTags.remove(category);
                                      } else {
                                        // ✅ 선택되지 않은 경우 → 해당 카테고리에 tag 할당
                                        selectedTags[category] = tag;
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.primary100,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: selected ?  Color(0xFF272727) : AppColors.gray700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: selected ? AppColors.primary700 : AppColors.gray300,
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),




                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isFormValid ? () async {
                          if (seatImage == null || todaySchedule == null) return;

                          final fileName = 'seatview_${DateTime.now().millisecondsSinceEpoch}.jpeg';
                          final presignedUrl = await getPresignedUrl(fileName, 'image/jpeg');
                          if (presignedUrl == null) return;

                          final success = await uploadToS3(presignedUrl, seatImage!);
                          if (!success) return;

                          final zoneCode = getZoneShortCode(selectedZone!);
                          if (zoneCode == null) return;

                          final tagCodes = selectedTags.values
                              .map((tag) => tagCodeMap[tag])
                              .whereType<String>()
                              .toList();

                          await uploadSeatView(
                            journalId: 123, // 👈 실제 journalId 전달 필요
                            stadiumSC: todaySchedule!.stadium,
                            zoneSC: zoneCode,
                            section: sectionController.text.trim(),
                            row: rowController.text.trim(),
                            tagCodes: tagCodes,
                            fileName: fileName,
                          );

                          if (context.mounted) Navigator.pop(context);
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

  Future<String?> getPresignedUrl(String fileName, String contentType) async {
    final url = Uri.parse('https://api.inninglog.shop/s3/journal/presigned?fileName=$fileName&contentType=$contentType');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body)['data'];
    return null;
  }
  Future<bool> uploadToS3(String presignedUrl, File file) async {
    final bytes = await file.readAsBytes();
    final res = await http.put(Uri.parse(presignedUrl), headers: {
      'Content-Type': 'image/jpeg',
    }, body: bytes);
    return res.statusCode == 200;
  }
  // Future<void> loadTodaySchedule() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final key = 'schedule_${currentDate.toIso8601String().split("T")[0]}';
  //   final jsonString = prefs.getString(key);
  //   if (jsonString == null) return;
  //
  //   final jsonData = jsonDecode(jsonString);
  //   setState(() {
  //     todaySchedule = MyTeamSchedule.fromJson(jsonData);
  //   });
  // }

}


String? getZoneShortCode(String zone) {
  const map = {
    '1루': 'JAM_BLUE',
    '3루': 'JAM_RED',
    '중앙': 'JAM_CENTER',
    '외야': 'JAM_OUTFIELD',
  };
  return map[zone];
}
final Map<String, String> tagCodeMap = {
  '#일어남': 'CHEERING_MOSTLY_STANDING',
  '#일어날_사람은_일어남': 'CHEERING_HALF_STANDING',
  '#앉아서': 'CHEERING_SITTING',
  '#강함': 'SUN_STRONG',
  '#있다가_그늘짐': 'SUN_TEMPORARY',
  '#없음': 'SUN_NONE',
  '#있음': 'COVER_EXIST',
  '#없음': 'COVER_NONE',
  '#그물': 'OBSTRUCTION_NET',
  '#아크릴_가림막': 'OBSTRUCTION_PLEXI',
  '#아주_넓음': 'SPACE_VERY_WIDE',
  '#넓음': 'SPACE_WIDE',
  '#보통': 'SPACE_NORMAL',
  '#좁음': 'SPACE_NARROW',
};
