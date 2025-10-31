import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/app_colors.dart';

// 🔔 더미 데이터 모델 (API 연동 전)
class AlarmItem {
  final String title;       // 예: 뉴스 제목 / 게시글 제목
  final String preview;     // 본문 미리보기 (최대 3줄)
  final DateTime time;      // "MM/dd HH:mm"
  final bool highlight;     // 교차 하이라이트 배경

  // ➕ 나의 활동 전용 메타
  final String? boardName;  // 오른쪽에 표시할 게시판/팀 이름
  final ImageProvider? rightThumb; // 선택: 원형 썸네일 (예: 팀 아이콘)

  AlarmItem({
    required this.title,
    required this.preview,
    required this.time,
    required this.highlight,
    this.boardName,
    this.rightThumb,
  });
}


class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with TickerProviderStateMixin {
  late final TabController _tab;

  // ✅ 오늘의 이닝: 소식 O 버전(우측 시안)
  final List<AlarmItem> _todayInning = [];

// ✅ 나의 활동: 소식 O (오른쪽에 보드명/팀명 표시)
  final List<AlarmItem> _myActivities = [
    AlarmItem(
      title: '게시글 제목',
      preview: '새로운 댓글이 달렸어요: 어쩌구 저쩌구 내용',
      time: DateTime(2025, 10, 1, 18, 34),
      highlight: false,
      boardName: '엘지트윈스',
    ),
    AlarmItem(
      title: '게시글 제목',
      preview: '게시글 내용 어쩌구 저쩌구\n롤롤라락\n배가 너무 고프다',
      time: DateTime(2025, 10, 1, 18, 34),
      highlight: true,
      boardName: '두산 베어스 🐻',
      // rightThumb: AssetImage('assets/images/club_doosan.png'), // 있으면 써도 됨
    ),
    AlarmItem(
      title: '게시글 제목',
      preview: '게시글 내용 어쩌구 저쩌구\n롤롤라락\n배가 너무 고프다',
      time: DateTime(2025, 10, 1, 18, 34),
      highlight: false,
      boardName: 'KBO',
    ),
    AlarmItem(
      title: '진짜 궁금해서 묻는 건데',
      preview: '이승엽 감독으로 오겠다 하면\n받아줄 거임?',
      time: DateTime(2025, 10, 1, 18, 34),
      highlight: true,
      boardName: '삼성 라이온즈 🦁',
    ),
    // ...원하면 더 추가
  ];


  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50, // 피그마 배경 톤
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary50,
        centerTitle: true,
        leadingWidth: 49.5,
        leading: IconButton(
          splashRadius: 22,
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/icons/back_but.svg', // ← 요구한 아이콘
            width:11,
          ),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF272727),
            letterSpacing: -0.19,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: AppColors.primary50,
            child: Column(
              children: [
                // 탭바
                TabBar(
                  controller: _tab,
                  labelPadding: const EdgeInsets.symmetric(vertical: 1.5),
                  indicatorPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFF272727),
                  unselectedLabelColor: AppColors.gray700,
                  labelStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.15,
                  ),
                  // 얇은 하단 인디케이터 (피그마 느낌)
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 1.5, color: AppColors.gray800),
                  ),
                  tabs: const [
                    Tab(text: '오늘의 이닝'),
                    Tab(text: '나의 활동'),
                  ],
                ),
                // 구분선
                Container(height: 0.5, color: const Color(0xFFD3D3D3)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _NotificationListView(items: _todayInning),
          _NotificationListView(items: _myActivities),
        ],
      ),
    );
  }
}

/// 알림 리스트 + 빈 상태 처리
class _NotificationListView extends StatelessWidget {
  final List<AlarmItem> items;

  const _NotificationListView({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      // 🔕 소식 X (좌측 시안)
      return Container(
        color: Colors.white,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/alarm_bori.svg', // ← 요구한 캐릭터
                width: 60,
              ),
              const SizedBox(height: 24),
              const Text(
                '새로운 소식이 없어요!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray600,
                  letterSpacing: -0.16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🔔 소식 O (우측 시안) — 상단 얇은 Divider 포함
    return Column(
      children: [
        Container(height: 0, color: AppColors.primary50),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Container(height: 1, color: AppColors.primary50),
            itemBuilder: (context, i) {
              final it = items[i];
              return Container(
                color: it.highlight
                    ?  AppColors.primary100 // 은은한 하이라이트(피그마 톤 유사)
                    : Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _NotificationTile(item: it),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 각 알림 카드(제목/미리보기/시간)
class _NotificationTile extends StatelessWidget {
  final AlarmItem item;
  const _NotificationTile({required this.item});

  String _fmt(DateTime t) {
    final mm = t.month.toString().padLeft(2, '0');
    final dd = t.day.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final min = t.minute.toString().padLeft(2, '0');
    return '$mm/$dd $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    // 본문(제목/미리보기/시간)
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF272727),
            letterSpacing: -0.14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.preview,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4E4E4E),
            height: 1.28,
            letterSpacing: -0.14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _fmt(item.time),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFA9A9A9),
            letterSpacing: -0.14,
          ),
        ),
      ],
    );

    // 오른쪽 메타(썸네일 + 보드명) — boardName이 없으면 비표시
    final rightMeta = (item.boardName == null && item.rightThumb == null)
        ? const SizedBox.shrink()
        : Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (item.rightThumb != null) ...[
          CircleAvatar(
            radius: 16, // 피그마 느낌의 작은 원형 썸네일
            backgroundImage: item.rightThumb,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 6),
        ],
        if (item.boardName != null)
          Text(
            item.boardName!,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
              letterSpacing: -0.14,
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 왼쪽 텍스트 영역
        Expanded(child: leftColumn),
        // 오른쪽 메타(있을 때만 공간 차지)
        if (!(item.boardName == null && item.rightThumb == null)) ...[
          const SizedBox(width: 16),
          rightMeta,
        ],
      ],
    );
  }
}
