import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../app_colors.dart';
import '../models/home_view.dart';
import '../service/api_service.dart';
import '../widgets/common_header.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_diary_page.dart';
import 'package:collection/collection.dart';
import '../main.dart';



const Map<String, String> teamNameMap = {
  'LG': 'LG',
  'OB': '두산',
  'SK': 'SSG',
  'HH': '한화',
  'SS': '삼성',
  'KT': 'KT',
  'LT': '롯데',
  'HT': 'KIA',
  'NC': 'NC',
  'WO': '키움',
};


const Map<String, String> stadiumNameMap = {
  'JAM': '잠실 야구장',
  'GOC': '고척 스카이돔',
  'ICN': '랜더스필드',
  'DJN': '한화생명 볼파크',
  'DAE': '라이온즈 파크',
  'SUW': '위즈파크',
  'BUS': '사직 야구장',
  'GWJ': '챔피언스 월드',
  'CHW': 'NC 파크',
};

const Map<String, String> resultFilterToScore = {
  '승리': '승',
  '패배': '패',
  '무승부': '무승부',
};


class DiaryPage extends StatefulWidget {
  final int? journalId;
  final String? stadium;
  final DateTime? gameDateTime;


  const DiaryPage({
    super.key,
    this.journalId,
    this.stadium,
    this.gameDateTime,
  });

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  int _selectedIndex = 0;

  String? selectedFilterCalendar;    // 캘린더 화면용 필터
  String? selectedFilterCollection;  // 모아보기 화면용 필터
  DateTime? selectedDate; //날짜 선택
  DateTime focusedDay = DateTime.now(); // ✅ 현재 보고 있는 달

  String baseImageUrl = 'https://inninglog-bucket.s3.ap-northeast-2.amazonaws.com/';

  List<Journal> journalList = [];



  bool isLoading = true;

  //인피니트 스크롤
  ScrollController _scrollController = ScrollController();
  int page = 0;
  bool isLoadingMore = false;
  bool hasMore = true;


  @override
  void initState() {
    super.initState();
    loadCalendar();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoadingMore && hasMore) {
        loadMoreSummary();

      }
    });

  }

  Future<void> loadCalendar() async {
    try {
      final result = await ApiService.fetchJournalCalendar(resultScore: selectedFilterCalendar);
      setState(() {
        journalList = result;
        isLoading = false;
      });
    } catch (e) {
      print('❌ 캘린더 로딩 실패: $e');
    }
  }

  Future<void> loadMoreSummary() async {
    setState(() => isLoadingMore = true);

    final scoreParam = selectedFilterCollection == '승리'
        ? '승'
        : selectedFilterCollection == '패배'
        ? '패'
        : selectedFilterCollection == '무승부'
        ? '무승부'
        : null;

    final newList = await ApiService.fetchJournalSummary(
      page: page,
      resultScore: scoreParam,
    );

    setState(() {
      if (newList.length < 10) hasMore = false;
      journalList.addAll(newList);
      page++;
      isLoadingMore = false;
    });

    print('📋 현재 일지 개수: ${journalList.length}');
    for (var j in journalList) {
      print('📝 ${j.journalId} | ${j.gameDate} | ${j.stadiumSC}');
    }
  }





  // 승/패/무 판단 함수
  String getGameResult(int ourScore, int theirScore) {
    if (ourScore > theirScore) return '승리';
    if (ourScore < theirScore) return '패배';
    return '무승부';
  }


  String _shortenResult(String result) {
    if (result == '승리') return '승';
    if (result == '패배') return '패';
    if (result == '무승부') return '무';
    return '';  // 혹시라도 잘못된 값 들어올 때 빈 문자열 처리
  }



  @override
  Widget build(BuildContext context) {
    final Map<String, Journal> gameMap = {};

    for (var game in journalList) {
      final key = '${game.gameDate}_${game.stadiumSC}';

      final isImageAvailable = game.mediaUrl != null && game.mediaUrl!.isNotEmpty;
      final isEmotionAvailable = emotionImageMap[game.emotion.trim()] != null;

      if (!gameMap.containsKey(key)) {
        gameMap[key] = game;
      } else {
        final existing = gameMap[key]!;
        final existingHasImage = existing.mediaUrl != null && existing.mediaUrl!.isNotEmpty;
        final existingHasEmotionImage = emotionImageMap[existing.emotion.trim()] != null;

        // ✅ 사진 → 감정 → 아무것도 없는 순으로 우선순위 정함
        if (
        // 1. 기존 건 사진 없고, 새로운 건 사진 있으면 교체
        (!existingHasImage && isImageAvailable) ||

            // 2. 기존 건 사진/감정 이미지 둘 다 없고, 새로운 건 감정 이미지라도 있으면 교체
            (!existingHasImage && !existingHasEmotionImage && isEmotionAvailable)
        ) {
          gameMap[key] = game;
        }
      }
    }

    final filteredGames = gameMap.values.where((game) {
      if (selectedFilterCollection == null) return true;

      final expectedResult = selectedFilterCollection!; // '승리' / '패배' / '무승부'
      final resultScore = game.resultScore;

      if (resultScore == '승' && expectedResult == '승리') return true;
      if (resultScore == '패' && expectedResult == '패배') return true;
      if (resultScore == '무승부' && expectedResult == '무승부') return true;

      return false;
    }).toList();





    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '직관 기록'),

            // 탭바
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton(index: 0, label: '캘린더')),
                  Expanded(child: _buildTabButton(index: 1, label: '모아보기')),
                ],
              ),
            ),

            // 화면 영역
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  // 캘린더 화면
                  Column(
                    children: [
                      // 승/패/무 필터 버튼 (고정)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterButton(
                              '승리',
                              selectedFilterCalendar,
                                  (value) {
                                setState(() {
                                  selectedFilterCalendar = value;
                                  loadCalendar();
                                  analytics.logEvent('select_diary_filter', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'filter_result': 'win',
                                  });
                                });
                              },
                            ),
                            _buildFilterButton(
                              '패배',
                              selectedFilterCalendar,
                                  (value) {
                                setState(() {
                                  selectedFilterCalendar = value;
                                  loadCalendar();
                                  analytics.logEvent('select_diary_filter', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'filter_result': 'lose',
                                  });
                                });
                              },
                            ),
                            _buildFilterButton(
                              '무승부',
                              selectedFilterCalendar,
                                  (value) {
                                setState(() {
                                  selectedFilterCalendar = value;
                                  loadCalendar();
                                  analytics.logEvent('select_diary_filter', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'filter_result': 'draw',
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),


                      // 나머지 전체 스크롤 영역
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 월 헤더
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 0),
                                    GestureDetector(
                                      onTap: () async {
                                        final newDate = await showMonthPicker(
                                          context: context,
                                          initialDate: focusedDay,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (newDate != null) {
                                          setState(() {
                                            focusedDay = newDate;
                                          });
                                          // ✅ Amplitude 이벤트 로깅
                                          analytics.logEvent('change_diary_calendar_month', properties: {
                                            'event_type': 'Custom',
                                            'component': 'event',
                                            'month': newDate.month,
                                          });
                                        }
                                      },
                                      child: _buildMonthHeader(),
                                    ),


                                    const SizedBox(height: 26),
                                  ],
                                ),
                              ),


                              // 달력
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TableCalendar(
                                  locale: 'ko_KR',
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  focusedDay: focusedDay,
                                  selectedDayPredicate: (day) {
                                    return selectedDate != null &&
                                        DateTime.utc(day.year, day.month, day.day) ==
                                            DateTime.utc(selectedDate!.year, selectedDate!.month, selectedDate!.day);
                                  },

                                  daysOfWeekHeight: 27.5,
                                  calendarStyle: CalendarStyle(
                                    selectedDecoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent, // 원래 배경 없게
                                      border: Border.all( // 테두리만 표시
                                        color: AppColors.primary700, // 원하는 색깔
                                        width: 2,
                                      ),
                                    ),
                                    todayDecoration: const BoxDecoration(),
                                    todayTextStyle: const TextStyle(),
                                    defaultTextStyle: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    outsideTextStyle: const TextStyle(
                                      color: Colors.transparent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    cellMargin: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  headerVisible: false,
                                  calendarBuilders: CalendarBuilders(
                                    selectedBuilder: (context, date, focusedDay) {
                                      final Journal? game = journalList.firstWhereOrNull(
                                            (j) => DateUtils.isSameDay(j.gameDate, date),
                                      );




                                      // 기본 색
                                      Color borderColor = AppColors.gray900;

                                      if (game != null && game.ourScore != null && game.theirScore != null) {
                                        final result = getGameResult(game.ourScore!, game.theirScore!);
                                        if (result == '승리') {
                                          borderColor = Color(0xFFAFD956);
                                        } else if (result == '패배') {
                                          borderColor = Color(0xFFE48F89);
                                        } else if (result == '무승부') {
                                          borderColor = AppColors.gray700;
                                        }
                                      } else {
                                        // 경기 없는 날 → 검정색 테두리
                                        borderColor = AppColors.gray900;
                                      }

                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // 날짜 숫자 항상 표시
                                          Center(
                                            child: Text(
                                              '${date.day}',
                                              style: const TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                          ),

                                          // 추가 테두리 원 (항상 표시)
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: borderColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },


                                    defaultBuilder: (context, date, _) => _buildDayCell(date),
                                    todayBuilder: (context, date, _) => _buildDayCell(date),
                                  ),

                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState((){

                                      // 같은 날짜를 다시 클릭하면 취소
                                      if (selectedDate != null &&
                                          DateTime.utc(selectedDate!.year, selectedDate!.month, selectedDate!.day) ==
                                              DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day)) {
                                        selectedDate = null; // 선택 해제
                                      } else {
                                        selectedDate = selectedDay; // 새로 선택
                                      }
                                    });
                                  },


                                ),

                              ),

                              // 하단 경기 기록
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(
                                  children: journalList
                                      .where((game) {
                                    final result = getGameResult(game.ourScore, game.theirScore);
                                    // 승패무 필터
                                    if (selectedFilterCalendar != null && result != selectedFilterCalendar) {
                                      return false;
                                    }
                                    // 날짜 필터 적용
                                    if (selectedDate != null) {
                                      final gameDate = DateTime.utc(game.gameDate.year,game.gameDate.month, game.gameDate.day);
                                      final selected = DateTime.utc(selectedDate!.year, selectedDate!.month, selectedDate!.day);
                                      if (gameDate != selected) {
                                        return false;
                                      }
                                    }

                                    return true;
                                  })

                                      .map((game) {
                                    final result = getGameResult(game.ourScore, game.theirScore);

                                    return GestureDetector(
                                      onTap: () async {

                                        await analytics.logEvent(
                                          'click_diary_calendar_diary',
                                          properties: {
                                            'component': 'btn_click',
                                            'diary_id': game.journalId.toString(), // UUID 또는 int → 문자열
                                            'importance': 'Medium',
                                          },
                                        );
                                        // 여기에 navigation 처리
                                        context.push(
                                          '/adddiary',
                                          extra: {
                                            'initialDate': selectedDate,
                                            'isEditMode': true,
                                            'journalId': game.journalId,
                                          },
                                        );
                                      },

                                      child:  Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.gray500),
                                          color: AppColors.gray50,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${game.gameDate.month}월 ${game.gameDate.day}일 (${_getWeekday(game.gameDate)})',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Pretendard-Black'),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('@${stadiumNameMap[game.stadiumSC] ?? game.stadiumSC}',
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, fontFamily: 'Pretendard-Black')),

                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // 점수 영역
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 29,
                                                      height: 29,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: result == '승리'
                                                              ? AppColors.win
                                                              : result == '패배'
                                                              ? AppColors.lose
                                                              : AppColors.gray600,
                                                          width: 1,
                                                        ),
                                                        color: Colors.transparent,
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Transform.translate(
                                                        offset: const Offset(0, -2),
                                                        child: Text(
                                                          '${game.ourScore}',
                                                          style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xFF000000),
                                                            fontFamily: 'MBC1961GulimOTF',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      ':',
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: 'MBC1961GulimOTF',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${game.theirScore}',
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xFF000000),
                                                        fontFamily: 'MBC1961GulimOTF',
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // 승/패/무 + 상대팀
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      result,
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w400,
                                                        color: result == '승리'
                                                            ? AppColors.win
                                                            : result == '패배'
                                                            ? AppColors.lose
                                                            : AppColors.gray600,
                                                        fontFamily: 'MBC1961GulimOTF',
                                                      ),
                                                    ),
                                                    Text('vs  ${teamNameMap[game.opponentTeamSC] ?? game.opponentTeamSC}',
                                                      style: const TextStyle(
                                                        fontFamily: 'Pretendard-Black',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                      .toList(),
                                ),
                              ),
                            ],

                          ),
                        ),
                      ),
                    ],
                  ),

                  // 모아보기 화면

                  Column(
                    children: [
                      // 필터 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterButton(
                              '승리',
                              selectedFilterCollection,
                                  (value) {
                                setState(() {
                                  selectedFilterCollection = value;
                                  page = 0;
                                  journalList.clear();
                                  hasMore = true;
                                });
                                loadMoreSummary();

                              },
                            ),
                            _buildFilterButton(
                              '패배',
                              selectedFilterCollection,
                                  (value) {
                                setState(() {
                                  selectedFilterCollection = value;
                                  page = 0;
                                  journalList.clear();
                                  hasMore = true;
                                });
                                loadMoreSummary();

                              },
                            ),
                            _buildFilterButton(
                              '무승부',
                              selectedFilterCollection,
                                  (value) {
                                setState(() {
                                  selectedFilterCollection = value;
                                  page = 0;
                                  journalList.clear();
                                  hasMore = true;
                                });
                                loadMoreSummary();

                              },
                            ),

                          ],
                        ),
                      ),



                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16), // Figma처럼 좌우 여백 주기

                          child: GridView.builder(
                            controller: _scrollController,
                            itemCount: filteredGames.length,



                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2개씩 보여주기 (Figma처럼)
                              crossAxisSpacing: 22,
                              mainAxisSpacing: 22,
                              childAspectRatio: 0.75, // 카드 비율 (필요 시 조절)
                            ),
                            itemBuilder: (context, index) {
                              final game = filteredGames[index];
                              final imageUrl = game.mediaUrl;
                              final hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

                              final result = game.resultScore ?? '';
                              final shortResult = result == '무승부' ? '무' : result;



                              final imageWidget = hasImage
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  print('❌ 이미지 에러: $error');
                                  return const Icon(Icons.broken_image);
                                },
                              )
                                  : Image.asset(
                                emotionImageMap[game.emotion] ?? 'assets/images/smile.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );

                              return GestureDetector(
                                  onTap: () async {
                                    await analytics.logEvent(
                                      'click_diary_from_collection',
                                      properties: {
                                        'component': 'btn_click',
                                        'diary_id': game.journalId.toString(),
                                        'importance': 'Medium',
                                      },
                                    );

                                context.push(
                                  '/adddiary',
                                  extra: {
                                    'initialDate': game.gameDate,
                                    'isEditMode': true,
                                    'journalId': game.journalId,
                                  },
                                );
                              },
                              child : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: imageWidget,
                                  ),
                                  // ✅ 그라데이션 오버레이 추가
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 129),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        shortResult,
                                        style: const TextStyle(
                                          color: AppColors.gray50,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'MBC1961GulimOTF',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Positioned(
                                    top: 165,
                                    bottom: 19,
                                    left: 11,
                                    right: 8,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 5),
                                        Text(
                                          '${game.gameDate.month}/${game.gameDate.day}(${_getWeekday(game.gameDate)})',
                                          style: const TextStyle(
                                            color: AppColors.gray50,
                                            fontSize: 9,
                                            fontFamily: 'Pretendard_Black',
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          'vs  ${teamNameMap[game.opponentTeamSC] ?? game.opponentTeamSC}',
                                          style: const TextStyle(
                                            color: AppColors.gray50,
                                            fontSize: 9,
                                            fontFamily: 'Pretendard_Black',
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          '@${stadiumNameMap[game.stadiumSC] ?? game.stadiumSC}',
                                          style: const TextStyle(
                                            color: AppColors.gray50,
                                            fontSize: 9,
                                            fontFamily: 'Pretendard_Black',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              );
                            },

                          ),
                        ),
                      ),


                    ],
                  ),
                ],
              ),

            ),

          ],
        ),
      ),


      floatingActionButton: FloatingActionButton(



        onPressed: () async {

          await analytics.logEvent(
            'view_diary_write_popup',
            properties: {
              'component': 'page_view',
              'match_team': 'opponentTeam',
              'is_favorite_team_match': true,
              'importance': 'High',
            },
          );
          final dateToSend = selectedDate ?? DateTime.now();
          final scheduleData = await ApiService.fetchScheduleForDate(dateToSend);

          if (scheduleData == null) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('경기 없음'),
                content: const Text('해당 날짜에 경기 일정이 없습니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // ← context 안전하게 처리
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
            return; // 여기에 정확히 return 필요!
          }


          final confirmed = await _showGameConfirmationDialog(context, dateToSend, scheduleData);

          if (confirmed == true) {

            await analytics.logEvent(
              'click_diary_write_start',
              properties: {
                'component': 'btn_click',
                'importance': 'High',
              },
            );
            context.push(
              '/adddiary',
              extra: {
                'initialDate': dateToSend,
                'isEditMode': false,
                'journalId': null,
                'gameInfo': scheduleData, // optional: 전달하고 싶다면
              },
            );
          }
        },
        backgroundColor: AppColors.primary700,
        elevation: 6,
        shape: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(0), // 여백 줄여서 SVG 더 크게 보이게
          child: SvgPicture.asset(
            'assets/icons/add_diary.svg',
            width: 36,
            height: 36,
          ),
        ),
      ),


      );



  }
  Future<bool> _showGameConfirmationDialog(
      BuildContext context,
      DateTime selectedDate,
      Map<String, dynamic> schedule,
      ) async {
    final formattedDate =
        '${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}(${_getWeekday(selectedDate)})';

    final team1 = teamNameMap[schedule['supportTeamSC']] ?? schedule['supportTeamSC'];
    final team2 = teamNameMap[schedule['opponentSC']] ?? schedule['opponentSC'];
    final stadium = stadiumNameMap[schedule['stadiumSC']] ?? schedule['stadiumSC'];
    final gameTime = schedule['gameDate'].toString().split(' ')[1];

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(0),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 17),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('직관하신 경기가 맞는지 확인해주세요!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(formattedDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(team1, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 12),
                          const Text('VS',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.primary700)),
                          const SizedBox(width: 12),
                          Text(team2, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(gameTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('@ $stadium', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFA9A9A9)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF94C32C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('일지 작성하기',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }




  // 날짜 셀 커스텀 빌더
  Widget? _buildDayCell(DateTime date) {
    final Journal? game = journalList.firstWhereOrNull(
          (j) => DateUtils.isSameDay(j.gameDate, date),
    );


    if (game == null) {
      return null;
    }

    final result = getGameResult(game.ourScore, game.theirScore);

    if (selectedFilterCalendar != null && result != selectedFilterCalendar) {
      return null;
    }

    Color circleColor;
    if (result == '승리') {
      circleColor = AppColors.primary300;
    } else if (result == '패배') {
      circleColor = AppColors.red300;
    } else {
      circleColor = AppColors.gray300;
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  // 필터 버튼
  Widget _buildFilterButton(String label, String? selectedFilter, Function(String?) onFilterChanged) {
    final isSelected = selectedFilter == label;

    Color backgroundColor = AppColors.gray50;
    Color borderColor = AppColors.gray600;
    Color textColor = AppColors.gray700;

    if (isSelected) {
      if (label == '승리') {
        backgroundColor = AppColors.primary100;
        borderColor = AppColors.primary700;
        textColor = AppColors.primary700;
      } else if (label == '패배') {
        backgroundColor = AppColors.red100;
        borderColor = AppColors.red700;
        textColor = AppColors.red700;
      } else if (label == '무승부') {
        backgroundColor = AppColors.gray200;
        borderColor = AppColors.gray700;
        textColor = AppColors.gray700;
      }
    }

    return GestureDetector(
      onTap: () {
        onFilterChanged(isSelected ? null : label); // ✅ 콜백 사용하도록 수정
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 44),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: 'Pretendard',
            letterSpacing: -0.12,
            height: 1.5,
          ),
        ),
      ),
    );
  }



  // 탭바 버튼
  Widget _buildTabButton({required int index, required String label}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // ✅ Amplitude 이벤트 전송
        if (index == 0) {
          setState(() {
            _selectedIndex = index;
            selectedFilterCalendar = null; // ✅ 캘린더 필터 초기화
            loadCalendar(); // ✅ 다시 로드
          });
          analytics.logEvent('click_diary_calendar_tab', properties: {
            'component': 'btn_click',
            'category': 'Diary',
            'importance': 'High',
          });
        } else if (index == 1) {
          analytics.logEvent('click_diary_collection_tab', properties: {
            'component': 'btn_click',
            'category': 'Diary',
            'importance': 'High',
          });
        }

      },
      child: Container(
        width: 195,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary200 : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary700 : const Color(0xFFFAFAFA),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            letterSpacing: -0.26,
            height: 1.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary800 : AppColors.gray700,
          ),
        ),
      ),
    );
  }

  // 월 헤더
  Widget _buildMonthHeader() {
    final now = DateTime.now();
    final currentMonth = '${focusedDay.month}월';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            currentMonth,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 19,
              letterSpacing: -0.19,
              height: 1.444,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(width: 9),
          SvgPicture.asset(
            'assets/icons/month_move.svg',
            width: 6,
            height: 11,
          ),
        ],
      ),
    );
  }

  // 요일 표시용 함수
  String _getWeekday(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdays[date.weekday % 7];
  }
}


Future<DateTime?> showMonthPickerDialog(BuildContext context, DateTime initialDate) async {
  DateTime? selectedDate = initialDate;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('월 선택'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(12, (index) {
              final month = index + 1;
              return InkWell(
                onTap: () {
                  Navigator.pop(context, DateTime(initialDate.year, month, 1));
                },
                child: Center(child: Text('$month월')),
              );
            }),
          ),
        ),
      );
    },
  );

}

const Map<String, String> emotionImageMap = {
  '짜릿함': 'assets/images/electric.jpg',
  '감동': 'assets/images/touched.jpg',
  '흡족' : 'assets/images/smile.jpg',
  '아쉬움' : 'assets/images/ohmy.jpg',
  '답답함': 'assets/images/sad.jpg',
  '분노': 'assets/images/angry.jpg',
  // 필요한 만큼 추가
};

