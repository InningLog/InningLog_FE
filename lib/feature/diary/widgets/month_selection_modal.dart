import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../shared/theme/app_colors.dart';

class MonthSelectionModal extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final void Function(int year, int month) onConfirm;

  const MonthSelectionModal({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onConfirm,
  });

  @override
  State<MonthSelectionModal> createState() => _MonthSelectionModalState();
}

class _MonthSelectionModalState extends State<MonthSelectionModal> {
  late int _currentYear;
  int? _selectedYear;
  int? _selectedMonth;

  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialYear;
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  bool _isFuture(int year, int month) {
    return year > _today.year || (year == _today.year && month > _today.month);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildYearHeader(),
              const Divider(
                thickness: 0.5,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 12),
              _buildMonthGrid(),
              const SizedBox(height: 12),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearHeader() {
    final canGoNext = _currentYear < _today.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => setState(() => _currentYear--),
          icon: SvgPicture.asset(
            'assets/icons/month_left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.gray500, BlendMode.srcIn),
          ),
        ),
        Text(
          '$_currentYear',
          style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray850,
            letterSpacing: -0.16,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _currentYear--),
          icon: SvgPicture.asset(
            'assets/icons/month_right.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.gray500, BlendMode.srcIn),
          ),
        ),

      ],
    );
  }



  Widget _buildMonthGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final future = _isFuture(_currentYear, month);
        final isSelected =
            _selectedYear == _currentYear && _selectedMonth == month;

        return GestureDetector(
          onTap: future
              ? null
              : () {
                  setState(() {
                    _selectedYear = _currentYear;
                    _selectedMonth = month;
                  });
                },
          child: Container(

            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary200
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),

            ),
            alignment: Alignment.center,
            child: Text(
              '$month월',
              style: TextStyle(
                fontSize: 15,
                letterSpacing: -0.15,
                fontWeight:
                    isSelected ? FontWeight.w500 : FontWeight.w500,
                color: future
                    ? AppColors.gray500
                     : isSelected
                        ? AppColors.gray850
                        : AppColors.gray850,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
              shape: const StadiumBorder(),
              side: const BorderSide(color:  AppColors.gray600,width: 0.5),

            ),
            child: const Text('취소',
                style: TextStyle(color: AppColors.gray700,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.14,
                fontFamily: 'Pretendard',
                fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (_selectedYear != null && _selectedMonth != null)
                ? () {
                    widget.onConfirm(_selectedYear!, _selectedMonth!);
                    Navigator.pop(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary700,
              disabledBackgroundColor:
              AppColors.primary700,
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text('확인',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.14,
                    fontFamily: 'Pretendard',
                    fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
