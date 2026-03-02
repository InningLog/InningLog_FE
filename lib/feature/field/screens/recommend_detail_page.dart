import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/theme/app_colors.dart';

class RecommendDetailPage extends StatelessWidget {
  final String stadiumName;
  final String bannerAsset;
  final String title; // ✅ 추가
  final List<String> seatImages;

  const RecommendDetailPage({
    super.key,
    required this.stadiumName,
    required this.bannerAsset,
    required this.title, // ✅ 추가
    required this.seatImages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 6),
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
                  const SizedBox(width: 6),
                  Text(
                    stadiumName,
                    style: const TextStyle(
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
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ✅ 배너(글씨 오버레이 포함)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: SizedBox(
                  height: 177,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        bannerAsset,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.25, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15,
                        bottom: 17,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard',
                            letterSpacing: -0.22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  itemCount: seatImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 273 / 364,
                  ),
                  itemBuilder: (context, index) {
                    return _SeatCard(assetPath: seatImages[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatCard extends StatelessWidget {
  final String assetPath;
  const _SeatCard({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: AppColors.gray100,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}