import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app_colors.dart';
import '../widgets/common_header.dart';
import 'package:table_calendar/table_calendar.dart';

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


  // 경기 데이터 샘플
  final List<Map<String, dynamic>> gameList = [
    {
      'date': DateTime.utc(2025, 6, 6),
      'homeScore': 6,
      'awayScore': 4,
      'opponent': 'NC 다이노스',
      'location': '삼성 종합운동장',
    },
    {
      'date': DateTime.utc(2025, 6, 12),
      'homeScore': 3,
      'awayScore': 3,
      'opponent': '키움 히어로즈',
      'location': '고척 스카이돔',
    },
    {
      'date': DateTime.utc(2025, 6, 13),
      'homeScore': 2,
      'awayScore': 1,
      'opponent': '두산 베어스',
      'location': '잠실 야구장',
    },
    {
      'date': DateTime.utc(2025, 6, 14),
      'homeScore': 0,
      'awayScore': 5,
      'opponent': '롯데 자이언츠',
      'location': '사직 야구장',
    },
  ];

  // 승/패/무 판단 함수
  String getGameResult(int homeScore, int awayScore) {
    if (homeScore > awayScore) {
      return '승리';
    } else if (homeScore == awayScore) {
      return '무승부';
    } else {
      return '패배';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                });
                              },
                            ),
                            _buildFilterButton(
                              '패배',
                              selectedFilterCalendar,
                                  (value) {
                                setState(() {
                                  selectedFilterCalendar = value;
                                });
                              },
                            ),
                            _buildFilterButton(
                              '무승부',
                              selectedFilterCalendar,
                                  (value) {
                                setState(() {
                                  selectedFilterCalendar = value;
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
                                    _buildMonthHeader(),
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
                                  focusedDay: DateTime.now(),
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
                                      final game = gameList.firstWhere(
                                            (g) => DateTime.utc(g['date'].year, g['date'].month, g['date'].day) ==
                                            DateTime.utc(date.year, date.month, date.day),
                                        orElse: () => {},


                                      );

                                      // 기본 색
                                      Color borderColor = AppColors.gray900;

                                      if (game['homeScore'] != null && game['awayScore'] != null) {
                                        final result = getGameResult(game['homeScore'], game['awayScore']);
                                        if (result == '승리') {
                                          borderColor = Color(0xFFAFD956);
                                        } else if (result == '패배') {
                                          borderColor = Color(0xFFE48F89);
                                        } else if (result == '무승부') {
                                          borderColor = AppColors.gray700;
                                        }else
                                          borderColor = AppColors.gray900;
                                      }

                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (game['homeScore'] != null && game['awayScore'] != null)
                                            _buildDayCell(date)
                                          else
                                          // 경기 없는 날은 그냥 날짜 숫자만 표시
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

                                          // 추가 테두리 원
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
                                      selectedDate = selectedDay; //날짜 선택 가능
                                    });
                                  },

                                ),

                              ),

                              // 하단 경기 기록
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(
                                  children: gameList
                                      .where((game) {
                                    final result = getGameResult(game['homeScore'], game['awayScore']);
                                    // 승패무 필터
                                    if (selectedFilterCalendar != null && result != selectedFilterCalendar) {
                                      return false;
                                    }
                                    // 날짜 필터 적용
                                    if (selectedDate != null) {
                                      final gameDate = DateTime.utc(game['date'].year, game['date'].month, game['date'].day);
                                      final selected = DateTime.utc(selectedDate!.year, selectedDate!.month, selectedDate!.day);
                                      if (gameDate != selected) {
                                        return false;
                                      }
                                    }

                                    return true;
                                  })

                                      .map((game) {
                                    final result = getGameResult(game['homeScore'], game['awayScore']);
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
                                            '${game['date'].month}월 ${game['date'].day}일 (${_getWeekday(game['date'])})',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Pretendard-Black'),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('@${game['location']}',
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
                                                        '${game['homeScore']}',
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
                                                    '${game['awayScore']}',
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
                                                  Text('vs ${game['opponent']}',
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

                  // 모아보기 화면 (기존 그대로 유지 — 필요시 동일하게 구성하면 됨)
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
                                });
                              },
                            ),
                            _buildFilterButton(
                              '패배',
                              selectedFilterCollection,
                                  (value) {
                                setState(() {
                                  selectedFilterCollection = value;
                                });
                              },
                            ),
                            _buildFilterButton(
                              '무승부',
                              selectedFilterCollection,
                                  (value) {
                                setState(() {
                                  selectedFilterCollection = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // 모아보기 화면 내용 (여기에 원하면 동일하게 구성 가능)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 날짜 셀 커스텀 빌더
  Widget? _buildDayCell(DateTime date) {
    final game = gameList.firstWhere(
          (g) => DateTime.utc(g['date'].year, g['date'].month, g['date'].day) == DateTime.utc(date.year, date.month, date.day),
      orElse: () => {},
    );

    if (game.isEmpty) {
      return null;
    }

    final result = getGameResult(game['homeScore'], game['awayScore']);

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
    final currentMonth = '${now.month}월';

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
