import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../main.dart';
import '../../../shared/service/home_view.dart';
import '../../../shared/widgets/common_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_detail.dart';
import '../../../shared/service/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:inninglog/app_scope.dart';





const Map<String, String> teamNameMap = {
  'LG': 'LG',
  'OB': '두산',
  'SK': 'SSG',
  'HH': '한화',
  'SS': '삼성',
  'KT': 'KT',
  'LT': '롯데',
  'HT': 'KIA',
  'NC': 'NC',
  'WO': '키움',
};


const Map<String, String> stadiumNameMap = {
  'JAM': '잠실 야구장',
  'GOC': '고척 스카이돔',
  'ICN': '랜더스필드',
  'DJN': '한화생명 볼파크',
  'DAE': '라이온즈 파크',
  'SUW': '위즈파크',
  'BUS': '사직 야구장',
  'GWJ': '챔피언스 월드',
  'CHW': 'NC 파크',
};




class HomePage extends StatefulWidget {
  const HomePage({super.key});




// //연동 -> api_service.dart에서 API 불러오기
//   static Future<HomeData?> fetchHomeData() async {
//     final url = Uri.parse('https://api.inninglog.shop/home/view');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final jsonBody = json.decode(response.body);
//       return HomeData.fromJson(jsonBody['data']);
//     } else {
//       print('API 오류: ${response.statusCode}');
//       return null;
//     }
//   }






  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeData? homeData;
  String nickName = '유저';
  String teamShortCode = 'LG';
  int? myWeaningRate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scope = context.read<AppScope>();
      final token = await scope.tokenStorage.readAccessToken();

      await fetchData(accessToken: token);
      await fetchMyWeaningRate(accessToken: token);
    });
  }

  Future<void> fetchData({String? accessToken}) async {
    final result = await ApiService.fetchHomeDataRaw(accessToken: accessToken);

    if (!mounted) return;

    if (result.statusCode == 200 && result.data != null) {
      final data = result.data!;
      setState(() {
        homeData = data;
        nickName = data.nickName;
        teamShortCode = data.supportTeamSC;
        myWeaningRate = data.myWeaningRate; // ✅ home 응답에 승률도 있으니 같이 세팅
      });
      if (data.myTeamSchedule.isNotEmpty) {
        saveScheduleListToPrefs(data.myTeamSchedule);
      }
      return;
    }

    // ✅ 서버가 "등록되지 않은 팀"이라고 하면 온보딩/팀선택으로
    if (result.statusCode == 404 && result.message.contains('등록되지 않은 팀')) {
      // 예: 응원팀 선택 페이지로
      context.go('/onboarding6'); // 너희 라우트에 맞게
      return;
    }

    print('🏠 홈 데이터 실패: ${result.statusCode} ${result.message}');
  }



  Future<void> fetchMyWeaningRate({String? accessToken}) async {
    void log(Object? m) => print('[fetchMyWeaningRate] $m');
    if (!mounted) return;

    try {
      final scope = context.read<AppScope>();
      final token = accessToken ?? await scope.tokenStorage.readAccessToken();

      if (token == null || token.isEmpty) {
        log('❌ 토큰 없음');
        if (!mounted) return;
        setState(() => myWeaningRate = 0);
        return;
      }

      final url = Uri.parse('https://api.inninglog.shop/report/main');
      final headers = {
        'Accept': 'application/json, */*',
        'Authorization': 'Bearer $token',
      };

      log('→ GET $url');
      final res = await http.get(url, headers: headers).timeout(
          const Duration(seconds: 15));
      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      final decoded = jsonDecode(res.body);
      final body = decoded is Map<String, dynamic> ? decoded : null;

      num _toNum(dynamic v) {
        if (v is num) return v;
        if (v is String) return num.tryParse(v) ?? 0;
        return 0;
      }

      if (res.statusCode == 200) {
        final data = body?['data'];
        if (data is Map<String, dynamic>) {
          final rate = _toNum(
            data['myWeaningRate'] ??
                data['winningRateHalPoongRi'] ??
                data['halPoongRi'] ??
                0,
          ).toInt();

          if (!mounted) return;
          setState(() => myWeaningRate = rate);
          return;
        }
      }

      // 에러면 0 처리
      if (!mounted) return;
      setState(() => myWeaningRate = 0);
    } catch (e, st) {
      print('[fetchMyWeaningRate] 🚨 예외: $e\n$st');
      if (!mounted) return;
      setState(() => myWeaningRate = 0);
    }
  }


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

  DateTime currentDate = DateTime.now();


  //우리 예매처 바로가기 링크 모음
  Future<void> openTicketUrl(String teamCode) async {
    final Map<String, String> ticketUrls = {
      'OB': 'https://ticket.interpark.com/Contents/Sports/GoodsInfo?SportsCode=07001&TeamCode=PB004',
      // 두산
      'WO': 'https://ticket.interpark.com/Contents/Sports/GoodsInfo?SportsCode=07001&TeamCode=PB003',
      // 키움
      'LG': 'https://www.ticketlink.co.kr/sports/137/59',
      'HT': 'https://www.ticketlink.co.kr/sports/137/58',
      'SS': 'https://www.ticketlink.co.kr/sports/137/57',
      'KT': 'https://www.ticketlink.co.kr/sports/137/62',
      'SK': 'https://www.ticketlink.co.kr/sports/137/476',
      'HH': 'https://www.ticketlink.co.kr/sports/137/63',
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
    AmplitudeFlutter.getInstance().logEvent(
      'click_home_team_schedule',
      eventProperties: {
        'component': 'btn_click',
        'direction': 'prev',
        'importance': 'Medium',
      },
    );
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    AmplitudeFlutter.getInstance().logEvent(
      'click_home_team_schedule',
      eventProperties: {
        'component': 'btn_click',
        'direction': 'next',
        'importance': 'Medium',
      },
    );
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

    //오늘 날짜 기준 경기 찾기
    MyTeamSchedule? todaySchedule;


    try {
      todaySchedule = homeData?.myTeamSchedule.firstWhere(
            (s) {
          final gameDate = DateTime.parse(s.gameDateTime.split(' ')[0]);
          return gameDate.year == currentDate.year &&
              gameDate.month == currentDate.month &&
              gameDate.day == currentDate.day;
        },
      );
      if (todaySchedule != null) {
        saveScheduleToPrefs(todaySchedule!);
      }
    } catch (e) {
      todaySchedule = null;
    }


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
                    '$nickName님의 직관 승률',
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
                child: myWeaningRate != null
                    ? Column(
                  children: [
                    const SizedBox(height: 12),
                    Image.asset(
                      getImageForRate(myWeaningRate! / 1000),
                      width: 88,
                      height: 88,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (myWeaningRate! / 1000).toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: teamColor,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        await AmplitudeFlutter.getInstance().logEvent(
                          'view_home_report',
                          eventProperties: {
                            'category': 'Custom',
                            'action': 'page_view',
                            'report_period': 'recent_1days',
                            'report_count': 1, // 또는 실제 값으로 대체
                          },
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeDetailPage(
                                  teamShortCode: teamShortCode, // ✅ 이거 넘겨주기
                                ),
                          ),
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
                )
                    : const Center(
                  child: CircularProgressIndicator(),
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


              Container(
                width: 360,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 날짜 & 이동 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _goToPreviousDay,
                          icon: SvgPicture.asset(
                              'assets/icons/month_left.svg', width: 20,
                              height: 27),
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
                          icon: SvgPicture.asset(
                              'assets/icons/month_right.svg', width: 20,
                              height: 27),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 👇 여기부터 경기 여부 분기
                    if (todaySchedule == null)

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 19),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 🐻 Bori sleepy 이미지 (왼쪽)
                            Image.asset(
                              'assets/images/bori_sleepy.jpg',
                              width: 72,
                              height: 60,
                            ),
                            const SizedBox(width: 13),

                            // 📝 "경기가 없습니다" 텍스트 (오른쪽)
                            const Text(
                              '오늘은 경기가 없어요!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'omyu pretty',
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                teamNameMap[todaySchedule!.myTeam] ??
                                    todaySchedule!.myTeam,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w800),
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
                                teamNameMap[todaySchedule!.opponentTeam] ??
                                    todaySchedule!.opponentTeam,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            todaySchedule!.gameDateTime.contains(' ')
                                ? todaySchedule!.gameDateTime.split(' ')[1]
                                : '',
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '@ ${stadiumNameMap[todaySchedule!.stadium] ??
                                todaySchedule!.stadium}',
                            style: const TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                  ],
                ),
              ),


              const SizedBox(height: 21),
              SizedBox(
                width: 360,
                height: 57,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await AmplitudeFlutter.getInstance().logEvent(
                        'click_home_ticket_button',
                        eventProperties: {
                          'component': 'btn_click',
                          'ticket_provider': _getTicketProviderName,
                          'importance': 'Low',
                        },
                      );

                      openTicketUrl(
                          teamShortCode); // 이 변수는 현재 'LG' 같은 코드로 정의돼 있음

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

  void saveScheduleToPrefs(MyTeamSchedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final gameDate = DateTime.parse(schedule.gameDateTime);
    final key = DateFormat('yyyy-MM-dd').format(gameDate);
    await prefs.setString('schedule_$key', jsonEncode(schedule.toJson()));
  }

  void saveScheduleListToPrefs(List<MyTeamSchedule> scheduleList) async {
    final prefs = await SharedPreferences.getInstance();
    for (final schedule in scheduleList) {
      final gameDate = DateTime.parse(schedule.gameDateTime);
      final key = 'schedule_${DateFormat('yyyy-MM-dd').format(gameDate)}';
      await prefs.setString(key, jsonEncode(schedule.toJson()));
    }
  }


  String getImageForRate(double rate) {
    if (rate <= 0.3) return 'assets/images/bori30.jpg';
    if (rate <= 0.5) return 'assets/images/bori50.jpg';
    if (rate <= 0.7) return 'assets/images/bori70.jpg';
    return 'assets/images/bori100.jpg';
  }

  String _getTicketProviderName(String url) {
    if (url.contains('ticket.interpark.com')) return '인터파크';
    if (url.contains('ticketlink.co.kr')) return '티켓링크';
    if (url.contains('ncdinos.com')) return 'NC 다이노스';
    if (url.contains('giantsclub.com')) return '롯데 자이언츠';
    return '기타';
  }
}