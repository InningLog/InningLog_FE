import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/home_view.dart';
import '../widgets/common_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_detail.dart';
import '../service/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});



//연동 -> api_service.dart에서 API 불러오기
  static Future<HomeData?> fetchHomeData() async {
    final url = Uri.parse('https://api.inninglog.shop/home/view');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return HomeData.fromJson(jsonBody['data']);
    } else {
      print('API 오류: ${response.statusCode}');
      return null;
    }
  }






  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime currentDate = DateTime.now();

  //HomePage에서 상태 변수 추가
  HomeData? homeData;


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final data = await ApiService.fetchHomeData();
    setState(() {
      homeData = data;
    });
  }

  // 유저 정보 더미 데이터
  final String nickname = '망곰 14';
  final double winningRateHalPoongRi = 0.932;
  final String teamShortCode = 'LG';

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

  //우리 예매처 바로가기 링크 모음
  Future<void> openTicketUrl(String teamCode) async {
    final Map<String, String> ticketUrls = {
      'OB': 'https://ticket.interpark.com/Contents/Sports/GoodsInfo?SportsCode=07001&TeamCode=PB004', // 두산
      'WO': 'https://ticket.interpark.com/Contents/Sports/GoodsInfo?SportsCode=07001&TeamCode=PB003', // 키움
      'LG': 'https://www.ticketlink.co.kr/sports/137/59',
      'HT': 'https://www.ticketlink.co.kr/sports/137/58',
      'SS': 'https://www.ticketlink.co.kr/sports/137/57',
      'KT': 'https://www.ticketlink.co.kr/sports/137/62',
      'SK': 'https://www.ticketlink.co.kr/sports/137/476',
      'HH': 'https://www.ticketlink.co.kr/sports/137/476',
      'NC': 'https://www.ncdinos.com/auth/ticket.do',
      'LT': 'https://ticket.giantsclub.com/loginForm.do',
    };

    final url = ticketUrls[teamCode];
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // 예외 처리
      print('URL을 열 수 없습니다');
    }
  }

  void _goToPreviousDay() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
    });
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    if (isToday) return 'Today';
    return DateFormat('MM.dd(E)', 'ko').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final Color teamColor = teamColors[teamShortCode] ?? AppColors.primary800;

    final schedule = homeData?.myTeamSchedule.first;




    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            const CommonHeader(title: '홈'),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$nickname님의 직관 승률',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 271,
              width: 360,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray400),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Image.asset(
                    getImageForRate(winningRateHalPoongRi),
                    width: 88,
                    height: 88,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    winningRateHalPoongRi.toStringAsFixed(3),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: teamColor,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeDetailPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFFF9FCF1),
                      minimumSize: const Size.fromHeight(40),
                      fixedSize: const Size(301, 53),
                    ),
                    child: const Text(
                      '나의 직관 리포트',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 26),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '우리팀 경기 일정',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),


            schedule == null
                ? const SizedBox(
              height: 148,
              child: Center(child: CircularProgressIndicator()),
            )
                : Container(
              width: 360,
              height: 148,
              padding: const EdgeInsets.only(left: 19, right: 19),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _goToPreviousDay,
                        icon: SvgPicture.asset('assets/icons/month_left.svg', width: 20, height: 27),
                      ),
                      Text(
                        _formatDate(currentDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      IconButton(
                        onPressed: _goToNextDay,
                        icon: SvgPicture.asset('assets/icons/month_right.svg', width: 20, height: 27),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        schedule.myTeam,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 66),
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary700,
                        ),
                      ),
                      const SizedBox(width: 66),
                      Text(
                        schedule.opponentTeam,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    schedule.gameDateTime.split(' ')[1],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '@ ${schedule.stadium}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 21),
            SizedBox(
              width: 360,
              height: 57,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:0),
                child: ElevatedButton(
                  onPressed: () {
                    openTicketUrl(teamShortCode); // 이 변수는 현재 'LG' 같은 코드로 정의돼 있음
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: AppColors.gray400),

                    padding: const EdgeInsets.symmetric(vertical: 14),

                  ),
                  child: const Text(
                    '우리팀 예매처 바로가기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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
    );
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
