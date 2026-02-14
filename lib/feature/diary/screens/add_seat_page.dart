import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../main.dart';
import '../../../shared/service/api_service.dart';
import '../../../shared/service/home_view.dart';
import '../../../shared/service/api_service.dart';
import '../../field/widgets/jamsil_map.dart';
import 'add_diary_page.dart';
import 'diary_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';



Future<String?> getPresignedUrlSeat(String fileName, String contentType) async {
  final prefs = await SharedPreferences.getInstance();
  final memberId = prefs.getInt('member_id'); // ✅ 추가

  if (memberId == null) {
    print('❌ SharedPreferences에서 member_id를 찾을 수 없습니다.');
    return null;
  }

  final url = Uri.parse(
    'https://api.inninglog.shop/s3/seatView/presigned?fileName=$fileName&contentType=$contentType&memberId=$memberId',
  );

  final res = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
  );

  print('📡 Presigned 요청 URL: $url');

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);
    return body['data'];
  } else {
    print('❌ Presigned URL 발급 실패: ${res.statusCode}');
    print('❌ 응답 내용: ${res.body}');
    return null;
  }
}



Future<bool> uploadToS3(String presignedUrl, {File? file, Uint8List? bytes}) async {
  try {
    final uploadBytes = bytes ?? await file!.readAsBytes();

    final res = await http.put(
      Uri.parse(presignedUrl),
      headers: {
        'Content-Type': 'image/png',
      },
      body: uploadBytes,
    );
    print('📤 S3 업로드 응답: ${res.statusCode}');
    return res.statusCode == 200;
  } catch (e) {
    print('❌ S3 업로드 오류: $e');
    return false;
  }
}






class AddSeatPage extends StatefulWidget {
  final int? journalId;            // ✅ nullable
  final String stadium;            // 이건 계속 required면 OK (없을 수도 있으면 이것도 ?로)
  final String? gameDateTime;      // ✅ nullable
  final bool showGameTime;

  final String? initialSection;
  final String? initialRow;

  const AddSeatPage({
    super.key,
    required this.stadium,
    this.journalId,
    this.gameDateTime,
    this.initialSection,
    this.initialRow,
    this.showGameTime = true,
  });

  @override
  State<AddSeatPage> createState() => _AddSeatPageState();
}


class _AddSeatPageState extends State<AddSeatPage> {

  bool _isDirectSheetOpen = false;
  String? _openPill;

  int reviewLength = 0;


  final TextEditingController reviewController = TextEditingController();
  int _reviewLen = 0;

  void _showDirectSearchBottomSheet() async {
    setState(() {
      _isDirectSheetOpen = true;
      _openPill = 'section';
    });

    // AddSeatPage에는 zone/section/row가 widget에 없음 → initial 값으로만 세팅
    if (sectionController.text.isEmpty && (widget.initialSection ?? '').trim().isNotEmpty) {
      sectionController.text = widget.initialSection!.trim();
    }
    if (rowController.text.isEmpty && (widget.initialRow ?? '').trim().isNotEmpty) {
      rowController.text = widget.initialRow!.trim();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final stadiumDisplayName = stadiumNameMap[widget.stadium] ?? widget.stadium;
            final isJamsil = stadiumDisplayName.replaceAll(' ', '') == '잠실야구장';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 36,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.gray700,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isJamsil) ...[
                      const Center(
                        child: Text(
                          '원하는 구역을 선택해서\n 좌석 시야를 확인하세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.16,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 360,
                        child: ClipRect(
                          child: InteractiveViewer(
                            panEnabled: true,
                            scaleEnabled: true,
                            minScale: 1,
                            maxScale: 5,
                            boundaryMargin: EdgeInsets.zero,
                            child: JamsilMap(
                              onSectionSelected: (section) {
                                sectionController.text = section;
                                setModalState(() {});
                                Navigator.pop(context);

                                // 닫고 나서 '열' 입력으로 포커스 이동(원하면)
                                // WidgetsBinding.instance.addPostFrameCallback((_) {
                                //   if (!mounted) return;
                                //   FocusScope.of(context).nextFocus();
                                // });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _isDirectSheetOpen = false;
      _openPill = null;
    });
  }


  bool isSaving = false;




  MyTeamSchedule? todaySchedule;
  DateTime currentDate = DateTime.now();
  File? seatImage;
  Uint8List? seatImageBytes;



  String? selectedZone;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();
  final Map<String, String> selectedTags = {};
  late String selectedStadiumCode;

  Future<void> loadTodaySchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'schedule_${currentDate.toIso8601String().split("T")[0]}';
    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      print('❌ 오늘 일정 없음 (SharedPreferences)');
      return;
    }



    print('📦 SharedPrefs key: $key');
    print('📦 SharedPrefs value: $jsonString');

    final jsonData = jsonDecode(jsonString);
    setState(() {
      todaySchedule = MyTeamSchedule.fromJson(jsonData);
    });
  }
  String _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null || rawDateTime.trim().isEmpty) return '';
    try {
      final date = DateTime.parse(rawDateTime);
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      final formattedDate = isToday ? 'Today' : DateFormat('MM.dd(E)', 'ko').format(date);
      final formattedTime = DateFormat('HH:mm').format(date);

      return '$formattedDate $formattedTime';
    } catch (e) {
      return rawDateTime;
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
    final hasZone = selectedZone != null && selectedZone!.isNotEmpty;
    final hasSection = sectionController.text.trim().isNotEmpty;
    final hasRow = rowController.text.trim().isNotEmpty;
    final hasImage = seatImage != null || seatImageBytes != null; // ✅ 여기 수정됨!

    return hasZone && hasSection && hasRow && hasImage;
  }




  @override
  void initState() {
    super.initState();


    reviewController.addListener(() {
      if (!mounted) return;
      setState(() => _reviewLen = reviewController.text.characters.length);
    });


    selectedStadiumCode = widget.stadium; // widget.stadium이 이미 'JAM' 같은 코드라면 OK


    if ((widget.initialSection ?? '').trim().isNotEmpty) {
      sectionController.text = widget.initialSection!.trim();
    }
    if ((widget.initialRow ?? '').trim().isNotEmpty) {
      rowController.text = widget.initialRow!.trim();
    }
    loadTodaySchedule();

  }

  List<String> get availableZoneCodes {
    final map = stadiumZones[selectedStadiumCode];
    if (map == null) return [];
    return map.keys.toList();
  }

// build 안에서 (경기 정보 박스 만들기 직전에)
  late final dt = widget.gameDateTime;

// 날짜/시간 표시 문자열 만들어두기
  late final dateTimeText = widget.showGameTime ? _formatDateTime(dt) : _formatDateOnly(dt);

// _formatDateTime / _formatDateOnly가 ''를 리턴하면 "표시할 게 없음"으로 판단
  late final hasDateTime = dateTimeText.trim().isNotEmpty;



  @override
  void dispose() {
    sectionController.dispose();
    rowController.dispose();
    reviewController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {


    final dt = widget.gameDateTime;




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
                    onPressed: () {
                      Navigator.pop(context);
                    },

                  ),
                  const Text(
                    '좌석 후기',
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
                      margin: EdgeInsets.symmetric(vertical: hasDateTime ? 16 : 12), // ✅ 없으면 margin도 살짝 줄임
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: hasDateTime ? 12 : 10, // ✅ 없으면 세로 padding 줄임
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        border: Border.all(color: AppColors.primary400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // ✅ 내용만큼만
                        children: [
                          Text(
                            stadiumNameMap[widget.stadium] ?? widget.stadium,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // ✅ 날짜/시간 있을 때만 간격+텍스트 렌더
                          if (hasDateTime) ...[
                            const SizedBox(height: 4),
                            Text(
                              dateTimeText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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



                    // DropdownButtonFormField<String>(
                    //   dropdownColor: Colors.white,
                    //   decoration: InputDecoration(
                    //     hintText: '존을 선택하세요.',
                    //     hintStyle: const TextStyle(
                    //       color: AppColors.gray700,
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w500,
                    //       fontFamily: 'Pretendard',
                    //     ),
                    //     filled: true,
                    //     fillColor: AppColors.gray100,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: AppColors.gray300),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: AppColors.gray300),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: AppColors.primary700),
                    //     ),
                    //     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    //   ),
                    //   value: selectedZone,
                    //   items: stadiumZones[selectedStadiumCode]!.entries.map((entry) {
                    //     final code = entry.key;
                    //     final name = entry.value;
                    //     return DropdownMenuItem<String>(
                    //       value: code, // ✅ key로 저장
                    //       child: Text(name), // ✅ 사용자에겐 name 보여줌
                    //     );
                    //   }).toList(),
                    //
                    //   onChanged: (value) {
                    //
                    //     setState(() => selectedZone = value);
                    //   },
                    // ),
                    // const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: _showDirectSearchBottomSheet,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: sectionController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'ex) 314',
                                  hintStyle: TextStyle(
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
                                    borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

                                ),
                              ),
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
                      onImageSelected: (file, bytes) {
                        setState(() {
                          seatImage = file;
                          seatImageBytes = bytes;
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

                    const SizedBox(height: 16),

                    const Text(
                      '좌석 후기 한줄평',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                        letterSpacing: -0.16,
                        color: AppColors.gray900
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '다른 사람들이 후기를 참고할 수 있어요.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray500,
                        fontFamily: 'Pretendard',
                        letterSpacing: -0.12
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gray300),
                      ),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: reviewController,
                            maxLength: 150,
                            maxLines: 5,
                            minLines: 5,
                            textInputAction: TextInputAction.newline,

                            onChanged: (value) {
                              setState(() {
                                reviewLength = value.length;
                              });
                              // ✅ 글자가 1자 이상 입력된 순간 한 번만 로그 전송

                            },

                            decoration: const InputDecoration(
                              hintText: '후기를 입력해보세요!',
                              hintStyle: TextStyle(
                                color: AppColors.gray700,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Pretendard',
                                height: 1.42857,
                                letterSpacing: -0.14,
                              ),
                              border: InputBorder.none,
                              counterText: '', // 기본 카운터 숨김(우리가 아래에서 커스텀으로 보여줄거)
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Pretendard',
                              color:AppColors.gray900,
                              height: 1.25,
                              letterSpacing: -0.16,
                            ),
                          ),
                        ],
                      ),


                    ),

                    const SizedBox(height: 4),


                    Text(
                      '($_reviewLen/150)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.gray500,
                        fontFamily: 'Pretendard',
                        height: 1.16667,
                      ),
                    ),

                    const SizedBox(height: 24),





                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (isFormValid && !isSaving) // 저장 중이면 비활성화
                        ? () async {

                          final jid = widget.journalId;
                          if (jid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('일기 정보가 없어서 저장할 수 없어요.')),
                            );
                            return;
                          }

                          setState(() => isSaving = true); // 저장 시작

                        try {
                          print('🟢 버튼 클릭됨!');
                          print('🧪 isFormValid: $isFormValid');


                          await  AmplitudeFlutter.getInstance().logEvent(
                            'select_seat_zone',
                            eventProperties: {
                              'component': 'btn_click',
                              'seat_zone': selectedZone,
                              'importance': 'High',
                            },
                          );

                          await  AmplitudeFlutter.getInstance().logEvent(
                            'enter_seat_section_row',
                            eventProperties: {
                              'component': 'form_submit',
                              'section': sectionController.text,
                              'row': rowController.text,
                              'importance': 'High',
                            },
                          );

                          await  AmplitudeFlutter.getInstance().logEvent(
                            'upload_seat_photo',
                            eventProperties: {
                              'component': 'event',
                              'photo_count': '1',
                              'importance': 'High',
                            },
                          );

                          await  AmplitudeFlutter.getInstance().logEvent(
                            'select_seat_hashtag',
                            eventProperties: {
                              'component': 'btn_click',
                              'hashtag_cheering': selectedTags['응원'],         // 예: '일어남'
                              'hashtag_sunlight': selectedTags['햇빛'],
                              'hashtag_roof': selectedTags['지붕'],
                              'hashtag_view_obstruction': selectedTags['시야 방해'],
                              'hashtag_seat_space': selectedTags['좌석 공간'],
                              'importance': 'High',
                            },
                          );


                          await  AmplitudeFlutter.getInstance().logEvent(
                            'complete_seat_review',
                            eventProperties: {
                              'component': 'btn_click',
                              'diary_id': widget.journalId,
                              'importance': 'High',
                            },
                          );





                          final fileName = 'journal_${widget.journalId}_${DateTime.now().millisecondsSinceEpoch}.png';
                          final presignedUrl = await getPresignedUrlSeat(fileName, 'image/png');
                          print('📡 Presigned 요청 URL: $presignedUrl');


                          if (presignedUrl == null) return;

                          final success = await uploadToS3(
                            presignedUrl,
                            file: kIsWeb ? null : seatImage,
                            bytes: kIsWeb ? seatImageBytes : null,
                          );
                          print('✅ 업로드 성공 여부: $success');

                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('사진 업로드 실패')),

                            );
                            return;
                          }

                          final zoneCode = (selectedZone!);
                          if (zoneCode == null) return;

                          final tagCodes = selectedTags.values
                              .map((tag) => tagCodeMap[tag])
                              .whereType<String>()
                              .toList();

                          await ApiService.uploadSeatView(
                            journalId: jid,
                            stadiumShortCode: widget.stadium,
                            zoneShortCode: selectedZone!,
                            section: sectionController.text.trim(),
                            seatRow: rowController.text.trim(),
                            emotionTagCodes: tagCodes,
                            fileName: fileName,
                          );


                          if (success) {
                            print('🎉 좌석 시야 등록 성공!');
                          }



                          print('📦 uploadSeatView 호출 인자:');
                          print('  journalId: ${widget.journalId}');
                          print('  stadiumSC: ${ widget.stadium}');
                          print('  zoneSC: ${selectedZone!}');
                          print('  section: ${sectionController.text.trim()}');
                          print('  row: ${rowController.text.trim()}');
                          print('  tagCodes: $tagCodes');
                          print('  fileName: $fileName');


                          if (context.mounted) {
                            context.go('/diary');
                          }
                          } finally {
                            setState(() => isSaving = false); // 저장 종료 → 버튼 다시 활성화
                          }
                          }
                              : null,

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
                        child: isSaving
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                        ),
                        )
                            : Text(
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


  String _formatDateOnly(String? rawDateTime) {
    if (rawDateTime == null || rawDateTime.trim().isEmpty) return '';
    try {
      final date = DateTime.parse(rawDateTime);
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      return isToday ? 'Today' : DateFormat('MM.dd(E)', 'ko').format(date);
    } catch (e) {
      return rawDateTime;
    }
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
  final Function(File?, Uint8List?) onImageSelected;

  const DiaryImagePicker({super.key, required this.onImageSelected});

  @override
  State<DiaryImagePicker> createState() => _DiaryImagePickerState();
}

class _DiaryImagePickerState extends State<DiaryImagePicker> {
  File? _pickedImage;
  Uint8List? _pickedImageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
        });
        widget.onImageSelected(null, bytes); // 웹
      } else {
        final file = File(image.path);
        setState(() {
          _pickedImage = file;
        });
        widget.onImageSelected(file, null); // 앱
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewWidget = kIsWeb
        ? (_pickedImageBytes == null
        ? const Icon(Icons.camera_alt, size: 28.3, color: Colors.grey)
        : Image.memory(_pickedImageBytes!, fit: BoxFit.fitWidth))
        : (_pickedImage == null
        ? const Icon(Icons.camera_alt, size: 28.3, color: Colors.grey)
        : Image.file(_pickedImage!, fit: BoxFit.fitWidth));

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          color: const Color(0xFFF5F5F5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(child: previewWidget),
        ),
      ),
    );
  }
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




  final Map<String, String> stadiumNameToCode = {
    '잠실 종합 운동장 잠실 야구장': 'JAM',
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
  '#일어남': 'CHEERING_STANDING',
  '#일어날_사람은_일어남': 'CHEERING_MOSTLY_STANDING',
  '#앉아서': 'CHEERING_SEATED',
  '#강함': 'SUN_STRONG',
  '#있다가_그늘짐': 'SUN_MOVES_TO_SHADE',
  '#없음': 'SUN_NONE', // 햇빛 - 없음
  '#있음': 'ROOF_EXISTS', // 지붕 - 있음
  '#없음_지붕': 'ROOF_NONE', // 구분 위해 이름 바꿈
  '#그물': 'VIEW_OBSTRUCT_NET',
  '#아크릴_가림막': 'VIEW_OBSTRUCT_ACRYLIC',
  '#없음_시야방해': 'VIEW_NO_OBSTRUCTION', // 구분 위해 이름 바꿈
  '#아주_넓음': 'SEAT_SPACE_VERY_WIDE',
  '#넓음': 'SEAT_SPACE_WIDE',
  '#보통': 'SEAT_SPACE_NORMAL',
  '#좁음': 'SEAT_SPACE_NARROW',
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

