import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/widgets/onlywan/diary_list.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class OnlyWanTab extends StatelessWidget {
  final bool isActive;

  const OnlyWanTab({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final items = <DiaryItemModel>[
      const DiaryItemModel(
        journalId: '1',
        nickName: '닉네임 몇 자까지 되더라',
        content: '본문 보여지는 건 공백 포함 최대 32자 / 33부턴 ... (...포함 총 36)',
        createdAt: '3분전',
        likeCount: 2,
        likedByMe: true,
        commentCount: 22,
        scrapCount: 2,
        scrapedByMe: false,
        thumbImageUrl: null,
      ),
      const DiaryItemModel(
        journalId: '2',
        nickName: '오직완 유저',
        content: '오늘도 직관 가는 사람 있나요?!!',
        createdAt: '10분전',
        likeCount: 8,
        likedByMe: false,
        commentCount: 3,
        scrapCount: 1,
        scrapedByMe: true,
        thumbImageUrl: null,
      ),
      const DiaryItemModel(
        journalId: '3',
        nickName: '야구는직관',
        content: '현장 응원 소리 미쳤다...',
        createdAt: '30분전',
        likeCount: 41,
        likedByMe: false,
        commentCount: 9,
        scrapCount: 6,
        scrapedByMe: false,
        thumbImageUrl: null,
      ),
    ];

    return Container(
      color: AppColors.primary50,
      child: FeedList(items: items),
    );
  }
}
