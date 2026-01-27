import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class EmptySeatState extends StatelessWidget {
  final VoidCallback? onCreateReview;

  const EmptySeatState({
    super.key,
    this.onCreateReview,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/bori_sleepy.jpg',
              width: 72.7,
              height: 60.5,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              '아직 등록된 좌석 후기가 없어요.\n첫번째로 좌석 후기를 작성해주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.375,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
                fontFamily: 'omyu pretty',
                letterSpacing: -0.16,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: 152,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary600, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: onCreateReview,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Text(
                    '좌석 후기 작성하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary700,
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
