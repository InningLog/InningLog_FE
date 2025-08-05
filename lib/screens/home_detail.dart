import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../analytics/AmplitudeFlutter.dart';
import '../app_colors.dart';
import '../main.dart';
import '../service/api_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';




class Player {
  final int playerId;
  final String playerName;
  final String playerType;
  final int totalHits;
  final int totalAtBats;
  final int totalEarned;
  final double totalInning;
  final double halPoongRi;

  Player({
    required this.playerId,
    required this.playerName,
    required this.playerType,
    required this.totalHits,
    required this.totalAtBats,
    required this.totalEarned,
    required this.totalInning,
    required this.halPoongRi,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['playerId'],
      playerName: json['playerName'],
      playerType: json['playerType'],
      totalHits: json['totalHits'],
      totalAtBats: json['totalAtBats'],
      totalEarned: json['totalEarned'],
      totalInning: json['totalInning']?.toDouble() ?? 0.0,
      halPoongRi: (json['halPoongRi'] ?? 0) / 1000,
    );
  }

}

class MyReportResponse {
  final int totalVisitedGames;
  final int winGames;
  final int loseGames;
  final int drawGames;
  final double winningRateHalPoongRi;
  final double teamWinRate;
  final List<Player> topBatters;
  final List<Player> topPitchers;
  final List<Player> bottomBatters;
  final List<Player> bottomPitchers;
  final String nickname;

  MyReportResponse({
    required this.totalVisitedGames,
    required this.winGames,
    required this.loseGames,
    required this.drawGames,
    required this.winningRateHalPoongRi,
    required this.teamWinRate,
    required this.topBatters,
    required this.topPitchers,
    required this.bottomBatters,
    required this.bottomPitchers,
    required this.nickname,
  });


  factory MyReportResponse.fromJson(Map<String, dynamic> json) {
    List<Player> parsePlayers(List<dynamic> list) =>
        list.map((item) => Player.fromJson(item)).toList();

    return MyReportResponse(
      totalVisitedGames: json['totalVisitedGames'],
      winGames: json['winGames'],
      loseGames: json['loseGames'],
      drawGames: json['drawGames'],
      winningRateHalPoongRi: json['myWeaningRate'] / 1000,
      teamWinRate: json['teamWinRate'].toDouble(),
      topBatters: parsePlayers(json['topBatters']),
      topPitchers: parsePlayers(json['topPitchers']),
      bottomBatters: parsePlayers(json['bottomBatters']),
      bottomPitchers: parsePlayers(json['bottomPitchers']),
      nickname : json['nickname'],

    );
  }

}



class HomeDetailPage extends StatefulWidget {

  final String teamShortCode;
  const HomeDetailPage({super.key,
    required this.teamShortCode, });


  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  MyReportResponse? report;

  final GlobalKey _captureKey = GlobalKey();



  @override
  void initState() {
    super.initState();
    loadReport(); // 🟡 페이지 들어오자마자 API 호출
  }



  Future<void> loadReport() async {

    final result = await ApiService.fetchMyReport(




    ); // 아까 만든 API 함수 호출
    setState(() {
      report = result;
      print('🔍 TopBatters: ${result?.topBatters.length}, TopPitchers: ${result?.topPitchers.length}');

    });

  }


  // 유저 정보 더미 데이터
  final String nickname = '유저';
  final String teamShortCode = 'NC';



  // 팀별 색상 정의
  final Map<String, Color> teamColors = {
    'WO': const Color(0xFF7E0022),
    'HT': const Color(0xFFE10822),
    'LG': const Color(0xFFC30136),
    'LT': const Color(0xFFD10F31),
    'SK': const Color(0xFFC81431),
    'SS': const Color(0xFF0064B2),
    'OB': const Color(0xFF010039),
    'NC': const Color(0xFF1F477A),
    'HH': const Color(0xFFFC4E00),
    'KT': const Color(0xFF000000),
  };





  @override
  Widget build(BuildContext context) {
    final Color teamColor =
        teamColors[widget.teamShortCode] ?? AppColors.primary800;


    final reportData = report!;

    final hasTopPlayers =
        reportData.topPitchers.isNotEmpty && reportData.topBatters.isNotEmpty;
    final hasBottomPlayers =
        reportData.bottomPitchers.isNotEmpty && reportData.bottomBatters.isNotEmpty;
    final myRate = reportData.winningRateHalPoongRi;
    final teamRate = reportData.teamWinRate;
    final diff = (myRate - teamRate).abs(); // 차이 절댓값
    final comparison = myRate > teamRate ? '높아요' : '낮아요';


    if (report == null) {
      // ⏳ 아직 데이터를 불러오는 중일 때
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }



    //전체 직관 횟수가 3회 미만인 경우
    if (reportData.totalVisitedGames < 1) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          'assets/icons/back_but.svg',
                          width: 10,
                          height: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 0),
                      const Text(
                        '홈',
                        style: TextStyle(
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
                    ],
                  ),
                ),
                const SizedBox(height: 121),
                Text(
                  '직관 기록이 부족해요!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 40),

                Image.asset(
                  'assets/images/bori_no_report.jpg',
                  width: 108,
                  height: 108,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text.rich(
                  TextSpan(
                    text: '직관 기록이 ',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                      color: Colors.black, // 기본 텍스트 색상
                    ),
                    children: [
                      TextSpan(
                        text: '1회',
                        style: TextStyle(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                        ),
                      ),
                      const TextSpan(
                        text: ' 이상 있어야\n리포트를 확인할 수 있어요!',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '현재:${reportData.totalVisitedGames}회' ,
                  style: TextStyle(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 3회 이상이면 기존 리포트 화면 반환
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ✅ 커스텀 상단 헤더
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/back_but.svg',
                      width: 10,
                      height: 20,
                    ),
                    onPressed: () async {
                      await  AmplitudeFlutter.getInstance().logEvent(
                        'click_home_report_back',
                        eventProperties: {
                          'component': 'btn_click',
                          'previous_page': 'home', // 필요 시 동적으로 바꾸기
                          'importance': 'Medium',
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(width: 0),
                  const Text(
                    '홈',
                    style: TextStyle(
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
                ],
              ),
            ),

            // ✅ 본문 시작
        Expanded(
          child: RepaintBoundary(
            key: _captureKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 타이틀
                    const Text(
                      '나의 직관 리포트',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 승률 박스
                    Container(
                      height: 176,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.primary50,
                        border: Border.all(color: AppColors.gray400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🧢 상단 타이틀
                          const Text(
                            '내가 직관 갔을 때 우리 팀 승률은?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🧱 이미지 + 텍스트 수평 배치
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 이미지 + 멘트
                              Column(
                                children: [
                                  Image.asset(
                                    getImageForRate(reportData.winningRateHalPoongRi),
                                    width: 51,
                                    height: 51,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    getCaptionForRate(reportData.winningRateHalPoongRi),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'omyu pretty',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),

                              // 승률 및 전적
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    reportData.winningRateHalPoongRi.toStringAsFixed(3),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: teamColor,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '2025 직관 횟수: ${reportData.totalVisitedGames}회',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  Text(
                                    '${reportData.winGames}승 ${reportData.loseGames}패 ${reportData.drawGames}무',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),



                    const SizedBox(height: 16),

                    /// 그래프 비교 박스
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        border: Border.all(color: AppColors.gray400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '내 직관 승률 vs 팀 전체 승률 비교',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBar(label: '내 직관 승률',
                            value: reportData.winningRateHalPoongRi,
                            color: AppColors.primary300,),
                          const SizedBox(height: 10),
                          _buildBar(label: '팀 승률',
                              value:reportData.teamWinRate,
                              color: AppColors.primary300),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              '${reportData.nickname}님의 직관 승률이 팀 승률보다 '
                                  '${(myRate - teamRate).abs().toStringAsFixed(3)}% $comparison.',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),



                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 선수 카드 박스
                    Row(
                      children: [
                        if (hasTopPlayers)
                          Expanded(
                            child: _buildPlayerCard('오이구 내 새끼 🥹', reportData.topPitchers.first, reportData.topBatters.first),
                          ),
                        if (hasBottomPlayers)
                          Expanded(
                            child: _buildPlayerCard('아이고 이 새끼 🤬', reportData.bottomPitchers.first, reportData.bottomBatters.first),
                          ),
                      ],
                    ),


                    const SizedBox(height: 24),

                    /// 공유 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: SizedBox(
                        height: 50,
                        width: 340,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
                          ),
                          onPressed: () async {
                            await  AmplitudeFlutter.getInstance().logEvent(
                              'click_home_report_share',
                              eventProperties: {
                                'component': 'btn_click',
                                'share_method': 'capture',
                                'importance': 'High',
                              },
                            );

                            _captureAndSave(); // 실제 공유 함수 실행
                          },
                          child: const Text(
                            '내 직관 리포트 공유하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ),



                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  //막대그래프 디자인 하는 부분
  Widget _buildBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 21),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔤 레이블
          Container(
            width: 66,
            child: Transform.translate(
              offset: const Offset(-6, 0),
              child: Text(

                label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          //프로그레스 바 디자인
          Container(
            alignment: Alignment.center,
            child: Container(
              height: 20,
              width: 200,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                border: Border.all(color: Color(0xFFA9A9A9)),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: value, // 퍼센트
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFAFD956),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          //수치
          Text(
            value.toStringAsFixed(3),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }


  /// 선수 카드
  Widget _buildPlayerCard(String title, Player pitcher,Player batter) {



    return Container(



      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:AppColors.primary50,
        border: Border.all(color: AppColors.gray400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🧢 카드 제목 (가운데 정렬)
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          const SizedBox(height: 11),

          // ⚾ 선수 정보
          Row(
            children: [
              Text('⚾ ', style: TextStyle(fontSize: 14)),
              Text(
                pitcher.playerName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(width : 4),
              Text(
                'ERA ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                  fontFamily: 'Pretendard',
                ),
              ),const SizedBox(width : 4),
              Text(
                '${pitcher.totalEarned.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 🧢 선수 정보 2
          Row(
            children: [
              const Text('🧢 ', style: TextStyle(fontSize: 14)),
              Text(
                batter.playerName, // 💡 const 제거해야 함
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ), const SizedBox(width : 4),
              const Text(
                'AVG ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                  fontFamily: 'Pretendard',
                ),
              ), const SizedBox(width : 4),
              Text(
                (batter.totalHits / batter.totalAtBats).toStringAsFixed(3), // 💡 타율 계산
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
  Future<void> _captureAndSave() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/my_report.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // 예시: 공유하기
      await Share.shareXFiles([XFile(filePath)], text: '나의 직관 리포트 📊');

    } catch (e) {
      print('❌ 캡쳐 실패: $e');
    }
  }


}

String getImageForRate(double rate) {
  if (rate <= 0.3) {
    return 'assets/images/bori30.jpg';
  } else if (rate <= 0.5) {
    return 'assets/images/bori50.jpg';
  } else if (rate <= 0.7) {
    return 'assets/images/bori70.jpg';
  } else {
    return 'assets/images/bori100.jpg';
  }
}

String getCaptionForRate(double rate) {
  if (rate <= 0.3) {
    return '패요의 요는\n요괴라면서요?';
  } else if (rate <= 0.5) {
    return '나도 패요가\n되고싶지 않아';
  } else if (rate <= 0.7) {
    return '나 없었으면\n어쩔 뻔?';
  } else {
    return '지는 게\n무슨 기분이지';
  }
}

