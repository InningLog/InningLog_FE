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
  'INC': '랜더스필드',
  'DAE': '한화생명 볼파크',
  'DAU': '라이온즈 파크',
  'SUW': '위즈파크',
  'SAJ': '사직 야구장',
  'GWJ': '챔피언스 월드',
  'CHW': 'NC 파크',
};


class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  int _selectedIndex = 0;

  String? selectedFilterCalendar;    // 캘린더 화면용 필터
  String? selectedFilterCollection;  // 모아보기 화면용 필터
  DateTime? selectedDate; //날짜 선택
  DateTime focusedDay = DateTime.now(); // ✅ 현재 보고 있는 달



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
      final result = await fetchJournalCalendar(resultScore: selectedFilterCalendar);
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
    final newList = await fetchJournalSummary(
      page: page,
      resultScore: selectedFilterCollection,
    );

    setState(() {
      if (newList.length < 10) hasMore = false;
      journalList.addAll(newList);
      page++;
      isLoadingMore = false;
    });
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
                                    setState(() {
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
                                    return Container(
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
                            itemCount: journalList.where((game) {
                              if (selectedFilterCollection == null) {
                                return true; // 전체 보여주기
                              }
                              final result = getGameResult(game.ourScore, game.theirScore);
                              return result == selectedFilterCollection;
                            }).length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2개씩 보여주기 (Figma처럼)
                              crossAxisSpacing: 22,
                              mainAxisSpacing: 22,
                              childAspectRatio: 0.75, // 카드 비율 (필요 시 조절)
                            ),
                            itemBuilder: (context, index) {
                              final filteredGames = journalList.where((game) {
                                if (selectedFilterCollection == null) {
                                  return true;
                                }
                                final result = getGameResult(game.ourScore, game.theirScore);
                                return result == selectedFilterCollection;
                              }).toList();
                              final game = filteredGames[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    // 카드 둥근 모서리
                                    child:Image.network(
                                      game.mediaUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                                    ),


                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 129),//자동패딩 8
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _shortenResult(getGameResult(game.ourScore, game.theirScore)),
                                        style: TextStyle(
                                          color: AppColors.gray50,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'MBC1961GulimOTF',
                                        ),
                                      ),

                                    ),
                                  ),
                                  Positioned(
                                    top: 165,
                                    bottom: 19,
                                    left: 11,
                                    right: 8,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 5),

                                        Text(

                                          '${game.gameDate.month}/${game.gameDate.day}(${_getWeekday(game.gameDate)})',
                                          style: TextStyle(
                                            color: AppColors.gray50,
                                            fontSize: 9,
                                            fontFamily: 'Pretendard_Black',
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,

                                          ),
                                        ),
                                        Text(
                                          'vs  ${teamNameMap[game.opponentTeamSC] ?? game.opponentTeamSC}',
                                          style: TextStyle(
                                            color: AppColors.gray50,
                                            fontSize: 9,
                                            fontFamily: 'Pretendard_Black',
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          '@${stadiumNameMap[game.stadiumSC] ?? game.stadiumSC}',
                                          style: TextStyle(
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
        onPressed: () {
          final dateToSend = selectedDate ?? DateTime.now();
          context.push('/adddiary', extra: dateToSend);
        },

        backgroundColor: AppColors.primary700,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          'assets/icons/add_diary.svg',
          width: 56,
          height: 56,
          fit: BoxFit.scaleDown,
        ),
      ),


    );

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
        onFilterChanged(isSelected ? null : label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 44),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
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
