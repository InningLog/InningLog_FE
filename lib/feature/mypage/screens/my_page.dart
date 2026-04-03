import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/mypage/screens/profile_edit_screen.dart';
import 'package:inninglog/feature/mypage/screens/withdrawal_flow.dart';
import 'package:provider/provider.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/mypage/viewmodel/my_page_view_model.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import '../../../shared/theme/app_colors.dart';

/// 10개 팀
enum TeamKey { doosan, kia, lg, lotte, samsung, nc, hanwha, kt, ssg, kiwoom }

TeamKey _teamKeyFromCode(String code) {
  switch (code) {
    case 'OB':
      return TeamKey.doosan;
    case 'HT':
      return TeamKey.kia;
    case 'LG':
      return TeamKey.lg;
    case 'LT':
      return TeamKey.lotte;
    case 'SS':
      return TeamKey.samsung;
    case 'NC':
      return TeamKey.nc;
    case 'HH':
      return TeamKey.hanwha;
    case 'KT':
      return TeamKey.kt;
    case 'SK':
      return TeamKey.ssg;
    case 'WO':
      return TeamKey.kiwoom;
    default:
      return TeamKey.doosan;
  }
}

String _buildLevelText(int totalGameCount) {
  final String level;
  if (totalGameCount >= 31) {
    level = '레전드';
  } else if (totalGameCount >= 11) {
    level = '00러';
  } else if (totalGameCount >= 6) {
    level = '응원러';
  } else {
    level = '루키';
  }
  return '$level ! - 직관 ${totalGameCount}회';
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  MyPageViewModel? _vm;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final repo = Provider.of<AppScope>(context, listen: false).userRepository;
      _vm = MyPageViewModel(repo);
      _vm!.fetch();
    }
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vm == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _vm!,
      child: Consumer<MyPageViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final profile = vm.profile;
          final teamKey = profile != null
              ? _teamKeyFromCode(profile.teamShortCode)
              : TeamKey.doosan;
          final bgAsset = TeamBackground.assetOf(teamKey);
          final teamLabel = profile != null
              ? kboTeamLabelOf(profile.teamShortCode)
              : '';
          final nickname = profile?.nickname ?? '';
          final levelText =
              profile != null ? _buildLevelText(profile.totalGameCount) : '';

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                _MyHeader(
                  backgroundAsset: bgAsset,
                  teamLabel: teamLabel,
                  nickname: nickname,
                  levelText: levelText,
                  profileUrl: profile?.profileUrl,
                  onEditTap: profile == null
                      ? null
                      : () async {
                          final updated = await ProfileEditFlow.start(
                            context,
                            profile: profile,
                          );
                          if (updated) vm.refresh();
                        },
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.63,
                  minChildSize: 0.63,
                  maxChildSize: 0.92,
                  builder: (context, controller) {
                    return _MySheet(
                      scrollController: controller,
                      totalGameCount: profile?.totalGameCount ?? 0,
                      winCount: profile?.winCount ?? 0,
                      winRate: profile?.winRate ?? 0.0,
                      teamShortCode: profile?.teamShortCode ?? 'OB',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =======================
/// 팀별 배경 PNG 매핑
/// =======================
class TeamBackground {
  static String assetOf(TeamKey team) {
    switch (team) {
      case TeamKey.doosan:
        return 'assets/images/team_bg/doosan.png';
      case TeamKey.kia:
        return 'assets/images/team_bg/kia.png';
      case TeamKey.lg:
        return 'assets/images/team_bg/lg.png';
      case TeamKey.lotte:
        return 'assets/images/team_bg/lotte.png';
      case TeamKey.samsung:
        return 'assets/images/team_bg/samsung.png';
      case TeamKey.nc:
        return 'assets/images/team_bg/nc.png';
      case TeamKey.hanwha:
        return 'assets/images/team_bg/hanwha.png';
      case TeamKey.kt:
        return 'assets/images/team_bg/kt.png';
      case TeamKey.ssg:
        // ssg.png 미존재 → doosan.png fallback
        return 'assets/images/team_bg/doosan.png';
      case TeamKey.kiwoom:
        return 'assets/images/team_bg/kiwoom.png';
    }
  }
}

/// =======================
/// Header (배경 PNG 적용)
/// =======================
class _MyHeader extends StatelessWidget {
  final String backgroundAsset;
  final String teamLabel;
  final String nickname;
  final String levelText;
  final String? profileUrl;
  final VoidCallback? onEditTap;

  const _MyHeader({
    required this.backgroundAsset,
    required this.teamLabel,
    required this.nickname,
    required this.levelText,
    this.profileUrl,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasProfileUrl = profileUrl != null && profileUrl!.isNotEmpty;

    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundAsset),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.44),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7.91),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasProfileUrl ? null : AppColors.gray500,
                        image: hasProfileUrl
                            ? DecorationImage(
                                image: NetworkImage(profileUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasProfileUrl
                          ? null
                          : const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 19),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 팀 알약 + 편집 버튼
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.gray400, width: 0.7),
                            ),
                            child: Text(
                              teamLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray900,
                                letterSpacing: -0.12,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                          const SizedBox(width: 88),
                          GestureDetector(
                            onTap: onEditTap,
                            child: CustomPaint(
                              size: const Size(28, 28),
                              painter: _CutoutEditPainter(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        levelText,
                        style: const TextStyle(
                          color: AppColors.gray300,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.14,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================
/// Sheet
/// =======================
class _MySheet extends StatelessWidget {
  final ScrollController scrollController;
  final int totalGameCount;
  final int winCount;
  final double winRate;
  final String teamShortCode;

  const _MySheet({
    required this.scrollController,
    required this.totalGameCount,
    required this.winCount,
    required this.winRate,
    required this.teamShortCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.gray700,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.gray200),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이번 시즌 기록
                  Row(
                    children: [
                      const Text(
                        '이번 시즌 기록',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF272727),
                          letterSpacing: -0.18,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => context.go('/home_detail', extra: {'teamShortCode': teamShortCode}),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                          child: Text(
                            '나의 직관 리포트 바로가기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary700,
                              letterSpacing: -0.12,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              value: '$totalGameCount', label: '직관 게임')),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _StatCard(value: '$winCount', label: '승리한 직관')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              value: '${winRate.toStringAsFixed(1)}%',
                              label: '직관 승률')),
                    ],
                  ),

                  const SizedBox(height: 22),
                  const Text(
                    '앱 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF272727),
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.18,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray400,width: 0.6),
                    ),
                    child: Column(
                      children: [
                        _SettingTile(
                          iconAsset: 'assets/images/mypage_document.svg',
                          title: '서비스 이용 약관',
                        ),
                        Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.gray200),
                        _SettingTile(
                          iconAsset: 'assets/images/mypage_version.svg',
                          title: '앱 버전',
                        ),
                        Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.gray200),
                        _SettingTile(
                          iconAsset: 'assets/images/mypage_account.svg',
                          title: '회원 탈퇴',
                          onTap: () => WithdrawalFlow.start(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w900,
      color: Color(0xFF272727),
      letterSpacing: -0.26,
      fontFamily: 'MBC1961GulimOTF',
    );

    // 숫자 텍스트 width 측정
    final tp = TextPainter(
      text: TextSpan(text: value, style: valueStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // 텍스트 길이에 맞춘 바 너비 (여유 padding 조금)
    double barWidth = tp.size.width + 6;

    // 너무 짧거나/너무 길어지지 않게 clamp
    barWidth = barWidth.clamp(10.0, 70.0);

    return Container(
      height: 105,
      width: 112,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 숫자
          Text(value, style: valueStyle),

          const SizedBox(height: 2),

          // ✅ 숫자 길이에 따라 늘었다 줄었다 하는 바
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: barWidth,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF86B900),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 14),

          // 라벨
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.gray800,
              height: 1.0,
              letterSpacing: -0.12,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.iconAsset,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(iconAsset, width: 24, height: 24),
            const SizedBox(width:8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                    fontFamily: 'Pretendard',
                    letterSpacing: -0.14,
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

class _VersionBadge extends StatelessWidget {
  final String text;
  const _VersionBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6B6F76),
          height: 1.0,
        ),
      ),
    );
  }
}

/// 연필 아이콘을 cutout으로 뚫어 뒤 배경이 보이는 원형 버튼 Painter
class _CutoutEditPainter extends CustomPainter {
  const _CutoutEditPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    // 회색 원 그리기
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()..color = const Color(0xFFCCCCD7),
    );

    // 연필 글리프 모양만 cutout (dstOut: 아이콘 불투명 픽셀만 지움)
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.edit.codePoint),
        style: TextStyle(
          fontSize: 16,
          fontFamily: Icons.edit.fontFamily,
          package: Icons.edit.fontPackage,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      (size.width - tp.width) / 2,
      (size.height - tp.height) / 2,
    );

    canvas.saveLayer(Offset.zero & size, Paint()..blendMode = BlendMode.dstOut);
    tp.paint(canvas, offset);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CutoutEditPainter oldDelegate) => false;
}
