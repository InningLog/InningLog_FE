import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inninglog/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../models/home_view.dart';
import '../service/api_service.dart';
import 'add_diary_page.dart';
import 'diary_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';






class AddSeatPage extends StatefulWidget {
  final String stadium;
  final String gameDateTime;
  final int journalId;

  const AddSeatPage({
    required this.journalId,
    super.key,
    required this.stadium,
    required this.gameDateTime,
  });


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
  late String selectedStadiumCode;

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
  String _formatDateTime(String rawDateTime) {
    try {
      final date = DateTime.parse(rawDateTime);
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      final formattedDate = isToday
          ? 'Today'
          : DateFormat('MM.dd(E)', 'ko').format(date);
      final formattedTime = DateFormat('HH:mm').format(date);

      return '$formattedDate $formattedTime';
    } catch (e) {
      return rawDateTime; // 파싱 실패 시 원본 그대로
    }
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
    final hasZoneOrSection =
        (selectedZone != null && selectedZone!.isNotEmpty) ||
            sectionController.text.trim().isNotEmpty;

    return hasZoneOrSection && seatImage != null;
  }


  @override
  void initState() {
    super.initState();
    selectedStadiumCode = widget.stadium;
    loadTodaySchedule();
  }


  List<String> get availableZoneCodes {
    var selectedStadiumCode;
    final map = stadiumZones[selectedStadiumCode];
    if (map == null) return [];
    return map.keys.toList(); // ✅ key만 리스트로
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
                    // 경기 정보 박스
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        border: Border.all(color: AppColors.primary400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 중앙 정렬
                        children: [
                          // 경기장 이름
                          Text(
                            stadiumNameMap[widget.stadium] ?? widget.stadium,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center, // ✅ 가운데 정렬
                          ),
                          const SizedBox(height: 4),
                          // 날짜 + 시간
                          Text(
                            _formatDateTime(widget.gameDateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center, // ✅ 가운데 정렬
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
                        hintStyle: const TextStyle(
                          color: AppColors.gray700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                        filled: true,
                        fillColor: AppColors.gray100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary700),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      value: selectedZone,
                      items: stadiumZones[selectedStadiumCode]!.entries.map((entry) {
                        final code = entry.key;
                        final name = entry.value;
                        return DropdownMenuItem<String>(
                          value: code, // ✅ key로 저장
                          child: Text(name), // ✅ 사용자에겐 name 보여줌
                        );
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

                          final zoneCode = (selectedZone!);
                          if (zoneCode == null) return;

                          final tagCodes = selectedTags.values
                              .map((tag) => tagCodeMap[tag])
                              .whereType<String>()
                              .toList();

                          await uploadSeatView(
                            journalId: widget.journalId,
                            stadiumSC: todaySchedule!.stadium,
                            zoneSC: selectedZone!,
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

  String formatDateWithTodayCheck(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    if (isToday) return 'Today';
    return DateFormat('MM.dd(E)', 'ko').format(date);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedStadiumCode', selectedStadiumCode));
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
    print('프리사인드 전송 완료');
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



  final Map<String, String> stadiumNameToCode = {
    '잠실 야구장': 'JAM',
    '고척 스카이돔': 'GOC',
    '랜더스 필드': 'ICN',
    '위즈 파크': 'SUW',
    '한화생명 볼파크': 'DJN',
    '라이온즈 파크': 'DAE',
    '사직 야구장': 'BUS',
    'NC 파크장': 'CHW',
    '챔피언스 월드': 'GWJ',
  };



  final Map<String, Map<String, String>> stadiumZones = {
    'JAM': {
      'JAM_PREMIUM': '중앙석 (프리미엄석)',
      'JAM_TABLE': '테이블석',
      'JAM_EXCITING': '익사이팅존',
      'JAM_BLUE': '블루석',
      'JAM_ORANGE': '오렌지석',
      'JAM_RED': '레드석',
      'JAM_NAVY': '네이비석',
      'JAM_GREEN': '그린석 (좌석)',
    },
    'GOC': {
      'GOC_SKYBOX': '스카이박스',
      'GOC_RDDUB': 'R.d-dub',
      'GOC_LEXUS1': 'LEXUS 1층 테이블석',
      'GOC_LEXUS2': 'LEXUS 2층 테이블석',
      'GOC_NAVER': 'NAVER 2층 테이블석',
      'GOC_INFIELD_COUPLE': '내야커플석',
      'GOC_OUTFIELD_COUPLE': '외야커플석',
      'GOC_DARK_BURGUNDY': '다크버건디석',
      'GOC_BURGUNDY': '버건디석',
      'GOC_3F': '3층 지정석',
      'GOC_4F': '4층 지정석',
      'GOC_WHEELCHAIR': '휠체어석',
      'GOC_OUTFIELD': '외야 지정석',
      'GOC_OUTFIELD_FAMILY': '외야 패밀리석',
      'GOC_OUTFIELD_BABY': '외야 유아동반석',
    },
    'ICN': {
      'ICN_SKY_VIEW': '4층 SKY뷰석',
      'ICN_INFIELD_FIELD': '내야 필드석',
      'ICN_OUTFIELD_FIELD': '외야 필드석',
      'ICN_SKY_TABLE': 'SKY탁자석',
      'ICN_MINI_SKYBOX': '미니스카이박스',
      'ICN_OUTFIELD_FAMILY': '외야패밀리존',
      'ICN_EMART_FRIENDLY': '이마트 프렌들리존',
      'ICN_LANDERS_LIVE': '랜더스 라이브존',
      'ICN_PEACOCK_1F': '피코크 테이블석(1층)',
      'ICN_NOBRAND_2F': '노브랜드 테이블석(2층)',
      'ICN_DUGOUT_UPPER': '덕아웃 상단석',
      'ICN_MOLLIS_GREEN': '몰리스 그린존',
      'ICN_EUSSEUK': '으쓱이존',
      'ICN_AWAY': '원정응원석',
      'ICN_HOMERUN_COUPLE': '홈런커플존',
      'ICN_SKYBOX': '스카이박스',
      'ICN_OPEN_BBQ': '오픈 바비큐존',
      'ICN_EMART_BBQ': '이마트바비큐존',
      'ICN_YOGIYO_FAMILY': '요기요 내야패밀리존',
      'ICN_CHOGA': '초가정자',
      'ICN_ROCKET_PARTY': '로케트배터리 외야파티덱',
    },
    'SUW': {
      'SUW_CATCHER_TABLE': '포수 뒤 테이블석',
      'SUW_CENTER_TABLE': '중앙 테이블석',
      'SUW_BASE_TABLE': '1루/3루 테이블석',
      'SUW_HIGH_FIVE': '하이파이브존',
      'SUW_EXCITING': '익사이팅석',
      'SUW_CENTER': '중앙 지정석',
      'SUW_CHEER': '응원 지정석',
      'SUW_INFIELD': '내야 지정석',
      'SUW_SKY': '스카이존',
      'SUW_OUTFIELD_TABLE': '외야 테이블석',
      'SUW_OUTFIELD_GRASS': '외야 잔디자유석',
    },

    'DJN': {
      'DJN_CATCHER_BACK': '포수 후면석',
      'DJN_CENTER': '중앙 지정석',
      'DJN_CENTER_TABLE': '중앙 탁자석',
      'DJN_INFIELD_A': '내야 지정석A',
      'DJN_INFIELD_B': '내야 지정석B',
      'DJN_INFIELD_BOX': '내야 박스석',
      'DJN_INFIELD_COUPLE': '내야 커플석',
      'DJN_INFIELD_TABLE_4F': '내야 탁자석(4층)',
      'DJN_CASS_CHEER': '카스존(응원단석)',
      'DJN_INNINGS_VIP': '이닝스 VIP바 & 룸/테라스',
      'DJN_SKYBOX': '스카이박스',
      'DJN_OUTFIELD': '외야지정석',
      'DJN_BAMBKEL_GRASS': '밤켈존(잔디석)',
      'DJN_OUTFIELD_TABLE': '외야탁자석',
    },

    'DAE': {
      'DAE_SKY_YOGIBO': 'SKY 요기보 패밀리존',
      'DAE_SKY_LOWER': 'SKY 하단 지정석',
      'DAE_3B_SKY_UPPER': '3루 SKY 상단 지정석',
      'DAE_CENTER_SKY_UPPER': '중앙 SKY 상단 지정석',
      'DAE_1B_SKY_UPPER': '1루 SKY 상단 지정석',
      'DAE_SWEET_BOX': '스윗박스',
      'DAE_PARTY_LIVE': '파티플로어 라이브석',
      'DAE_VIP': 'VIP석',
      'DAE_EUTEUM_CENTER': '으뜸병원 중앙 테이블석',
      'DAE_ISU_3B': '이수그룹 3루 테이블석',
      'DAE_ISU_PETASYS_1B': '이수페타시스 1루 테이블석',
      'DAE_3B_EXCITING': '3루 익사이팅석',
      'DAE_1B_EXCITING': '1루 익사이팅석',
      'DAE_BLUE': '블루존',
      'DAE_AWAY': '원정 응원석',
      'DAE_1B_INFIELD': '1루 내야지정석',
      'DAE_WHEELCHAIR': '휠체어 장애인석',
      'DAE_OUTFIELD_FAMILY': '외야 패밀리석',
      'DAE_OUTFIELD_TABLE': '외야 테이블석',
      'DAE_OUTFIELD': '외야 지정석',
      'DAE_OUTFIELD_COUPLE': '외야 커플 테이블석',
      'DAE_ROOFTOP': '루프탑 테이블석',
    },
    'BUS': {
      'BUS_GROUND': '그라운드석',
      'BUS_CENTER_TABLE': '중앙탁자석',
      'BUS_WIDE_TABLE': '와이드탁자석',
      'BUS_CHEER_TABLE': '응원탁자석',
      'BUS_INFIELD_TABLE': '내야탁자석',
      'BUS_3B_GROUP': '3루 단체석',
      'BUS_INFIELD_FIELD': '내야필드석',
      'BUS_INFIELD_UPPER': '내야상단석',
      'BUS_ROCKET_BATTERY': '로케트 배터리존',
      'BUS_OUTFIELD': '외야석',
      'BUS_CENTER_UPPER': '중앙상단석',
      'BUS_WHEELCHAIR': '휠체어석',
    },

    'GWJ': {
      'GWJ_CHAMPION': '챔피언석',
      'GWJ_CENTER_TABLE': '중앙테이블석',
      'GWJ_DISABLED': '장애인지정석',
      'GWJ_K9': 'K9',
      'GWJ_K8': 'K8',
      'GWJ_K5': 'K5',
      'GWJ_SURPRISE': '서프라이즈석',
      'GWJ_TIGERS_FAMILY': '타이거즈가족석',
      'GWJ_WHEELCHAIR': '휠체어석',
      'GWJ_4F_PARTY': '4층파티석',
      'GWJ_SKYBOX': '스카이박스',
      'GWJ_SKY_PICNIC': '스카이피크닉석',
      'GWJ_EV': 'EV',
      'GWJ_5F_TABLE': '5층 테이블석',
      'GWJ_OUTFIELD': '외야석',
      'GWJ_OUTFIELD_TABLE': '외야테이블석',
    },

    'CHW': {
      'CHW_INFIELD': '내야석',
      'CHW_TABLE': '테이블석',
      'CHW_ROUND_TABLE': '라운드 테이블석',
      'CHW_OUTFIELD_GRASS': '외야잔디석',
      'CHW_OUTFIELD': '외야석',
      'CHW_3_4F_INFIELD': '3·4층 내야석',
      'CHW_WHEELCHAIR': '휠체어석',
      'CHW_MINI_TABLE': '미니테이블석',
      'CHW_FAMILY': '가족석',
      'CHW_SKYBOX': '스카이박스',
      'CHW_BULLPEN_FAMILY': '불펜 가족석',
      'CHW_BULLPEN': '불펜석',
      'CHW_COUNTER': '카운터석',
      'CHW_ABL_PREMIUM': 'ABL생명 프리미엄석',
      'CHW_ABL_PREMIUM_TABLE': 'ABL생명 프리미엄 테이블석',
      'CHW_BBQ': '바베큐석',
      'CHW_PICNIC_TABLE': '피크닉테이블석',
      'CHW_NORTH_PEAK_CAMPING': '노스피크캠핑석',
    },

  };


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



String formatScheduleDateTime(String rawDateTime) {
  try {
    final dt = DateTime.parse(rawDateTime);
    final date = DateFormat('yyyy.MM.dd').format(dt);
    final time = DateFormat('HH:mm').format(dt);
    return '$date  $time';
  } catch (e) {
    return rawDateTime; // 파싱 실패 시 원본 문자열 반환
  }
}



String? getZoneNameFromCode(String stadiumName, String? zoneCode) {
  if (zoneCode == null) return null;
  final code = stadiumNameToCode[stadiumName];
  return stadiumZones[code]?[zoneCode] ?? zoneCode;
}

