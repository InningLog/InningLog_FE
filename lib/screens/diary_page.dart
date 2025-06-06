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
  String? selectedFilter; // 선택된 버튼 저장 (처음에는 null → 선택 없음)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '직관 기록'),

            //캘린더,모아보기 탭바
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

            //승/패/무 필터 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterButton('승리'),
                  _buildFilterButton('패배'),
                  _buildFilterButton('무승부'),
                ],
              ),
            ),

            // 월 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  _buildMonthHeader(),
                  const SizedBox(height: 28.5),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary200,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary700,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard',
                      ),
                      todayTextStyle: TextStyle(
                        color: AppColors.primary800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    headerVisible: false, // 너는 위에 "5월 ⌄" 따로 구현했으니 header 숨기면 됨
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildFilterButton(String label) {
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
        backgroundColor = AppColors.gray200; // 나중에 무승부 색 변경 가능
        borderColor = AppColors.gray700;
        textColor = AppColors.gray700;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedFilter == label) {
            // 이미 선택된 버튼을 다시 누르면 해제
            selectedFilter = null;
          } else {
            // 새로운 버튼 선택
            selectedFilter = label;
          }
        });
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
