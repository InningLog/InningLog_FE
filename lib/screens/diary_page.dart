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

  //연동 후 삭제할거
  final Map<DateTime, String> gameResults = {
    DateTime.utc(2025, 6, 6): '승리',
    DateTime.utc(2025, 6, 11): '무승부',
    DateTime.utc(2025, 6, 13): '승리',
    DateTime.utc(2025, 6, 14): '패배',
    DateTime.utc(2025, 6, 23): '승리',
    DateTime.utc(2025, 6, 25): '패배',
  };

  //상단탭바
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
                  // 캘린더 화면 전체 구성
                  Column(
                    children: [
                      // 승리 패배 무승부 버튼
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
                      // 월 헤더 -> 현재 월 나오게
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TableCalendar(
                            locale: 'ko_KR',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: DateTime.now(),
                            daysOfWeekHeight: 27.5,
                            calendarStyle: CalendarStyle(
                              todayDecoration: const BoxDecoration(),
                              todayTextStyle: const TextStyle(),
                              defaultTextStyle: const TextStyle(
                                color: Color(0xFF333333),
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                              defaultBuilder: (context, date, focusedDay) {
                                return _buildDayCell(date);
                              },
                              todayBuilder: (context, date, focusedDay) {
                                return _buildDayCell(date);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),



                  // 모아보기 화면 전체 구성
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
                      // 모아보기 화면 내용
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Text(
                              '모아보기 화면',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
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
    );
  }

  // 날짜 셀 커스텀 빌더
  Widget? _buildDayCell(DateTime date) {
    final result = gameResults[DateTime.utc(date.year, date.month, date.day)];

    // 필터가 선택됐으면 → 해당 결과만 표시
    if (selectedFilterCalendar != null && result != selectedFilterCalendar) {
      return null;
    }

    // 결과가 없으면 기본 표시
    if (result == null) {
      return null;
    }

    // 색상 지정
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

  // 상단 탭바 버튼
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

  // 승/패/무 필터 버튼 (파라미터로 필터 상태 받도록 수정)
  Widget _buildFilterButton(String label, String? selectedFilter, Function(String?) onFilterChanged) {
    final isSelected = selectedFilter == label;

    // 버튼별 색 지정
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
}
