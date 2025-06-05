import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app_colors.dart';
import '../widgets/common_header.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  int _selectedIndex = 0;

  //상단 탭바
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

              ), //승/패/무 필터 버튼

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMonthHeader(),
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
      //탭바 디자인 요소
      child: Container(
        //전체 컨테이너
        width: 195,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          //배경색
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

          //탭바 텍스트 요소
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            letterSpacing: -0.26,
            height: 1.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ?AppColors.primary800 : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
      //승패무 버튼 디자인
      Widget _buildFilterButton(String label) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 44), // 8px 44px 비율
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:  AppColors.gray600,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
              fontFamily: 'Pretendard',
              letterSpacing: -0.12,
              height: 1.5,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF272727),
                  ),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/Home_black.svg',
                  width: 6,
                  height: 11
                ),

              ],
            ),
          );
        }
