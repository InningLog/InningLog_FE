//아래 우리팀 경기 일정 관련 부분

class MyTeamSchedule {
  final String myTeam;
  final String opponentTeam;
  final String stadium;
  final String gameDateTime;

  MyTeamSchedule({
    required this.myTeam,
    required this.opponentTeam,
    required this.stadium,
    required this.gameDateTime, required gameId,
  });

  Map<String, dynamic> toJson() {
    return {
      'myTeam': myTeam,
      'opponentTeam': opponentTeam,
      'stadium': stadium,
      'gameDateTime': gameDateTime,
    };
  }





  factory MyTeamSchedule.fromJson(Map<String, dynamic> json) {
    return MyTeamSchedule(
      myTeam: json['myTeam'],
      opponentTeam: json['opponentTeam'],
      stadium: json['stadium'],
      gameDateTime: json['gameDateTime'], gameId: null,
    );
  }
}

class HomeData {
  final String nickName;
  final String supportTeamSC;
  final int myWeaningRate;
  final List<MyTeamSchedule> myTeamSchedule;

  HomeData({
    required this.nickName,
    required this.supportTeamSC,
    required this.myWeaningRate,
    required this.myTeamSchedule,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      nickName: json['nickName'],
      supportTeamSC: json['supportTeamSC'],
      myWeaningRate: json['myWeaningRate'],
      myTeamSchedule: (json['myTeamSchedule'] as List)
          .map((e) => MyTeamSchedule.fromJson(e))
          .toList(),
    );
  }
}

class GameInfoResponse {
  final String gameId;
  final String gameDate;
  final String supportTeamSC;
  final String opponentTeamSC;
  final String stadiumSC;

  GameInfoResponse({
    required this.gameId,
    required this.gameDate,
    required this.supportTeamSC,
    required this.opponentTeamSC,
    required this.stadiumSC,
  });

  factory GameInfoResponse.fromJson(Map<String, dynamic> json) {
    return GameInfoResponse(
      gameId: json['gameId'],
      gameDate: json['gameDate'],
      supportTeamSC: json['supportTeamSC'],
      opponentTeamSC: json['opponentTeamSC'],
      stadiumSC: json['stadiumSC'],
    );
  }
}

class Journal {
  final int journalId;
  final int ourScore;
  final int theirScore;
  final String resultScore;
  final DateTime gameDate;
  final String supportTeamSC;
  final String opponentTeamSC;
  final String stadiumSC;
  final String mediaUrl;
  final String reviewText;
  final String emotion;


  Journal({
    required this.journalId,
    required this.ourScore,
    required this.theirScore,
    required this.resultScore,
    required this.gameDate,
    required this.supportTeamSC,
    required this.opponentTeamSC,
    required this.stadiumSC,
    required this.mediaUrl,
    required this.reviewText,
    required this.emotion,

  });


  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      journalId: json['journalId'] ?? 0,
      ourScore: json['ourScore'] ?? 0,
      theirScore: json['theirScore'] ?? 0,
      resultScore: json['resultScore'] ?? '정보 없음',
      gameDate: DateTime.tryParse(json['gameDate'] ?? '') ?? DateTime.now(),
      supportTeamSC: json['supportTeamSC'] ?? '팀 정보 없음',
      opponentTeamSC: json['opponentTeamSC'] ?? '팀 정보 없음',
      stadiumSC: json['stadiumSC'] ?? '구장 정보 없음',
      mediaUrl: json['media_url'] ?? '',
      reviewText: json['review_text'] ?? '',
      emotion: json['emotion'] ?? '감정 없음',
    );
  }

}

class GameInfo {
  final String gameId;
  final String gameDate;
  final String supportTeamSC;
  final String opponentTeamSC;
  final String stadiumSC;

  GameInfo({
    required this.gameId,
    required this.gameDate,
    required this.supportTeamSC,
    required this.opponentTeamSC,
    required this.stadiumSC,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      gameId: json['gameId'],
      gameDate: json['gameDate'],
      supportTeamSC: json['supportTeamSC'],
      opponentTeamSC: json['opponentTeamSC'],
      stadiumSC: json['stadiumSC'],
    );
  }
  // models/home_view.dart
  factory GameInfo.fromJournalContentJson(Map<String, dynamic> json) {
    return GameInfo(
      gameId: json['gameId'],
      gameDate: json['gameDate'],
      supportTeamSC: json['supportTeamSC'],
      opponentTeamSC: json['opponentTeamSC'],
      stadiumSC: json['stadiumSC'],
    );
  }

}
class JournalDetail {
  final int journalId;
  final String gameDate;
  final String supportTeamSC;
  final String opponentTeamSC;
  final int ourScore;
  final int theirScore;
  final String stadiumSC;
  final String emotion;
  final String mediaUrl;
  final String reviewText;

  JournalDetail({
    required this.journalId,
    required this.gameDate,
    required this.supportTeamSC,
    required this.opponentTeamSC,
    required this.ourScore,
    required this.theirScore,
    required this.stadiumSC,
    required this.emotion,
    required this.mediaUrl,
    required this.reviewText,
  });

  factory JournalDetail.fromJson(Map<String, dynamic> json) {
    return JournalDetail(
      journalId: json['journalId'],
      gameDate: json['gameDate'],
      supportTeamSC: json['supportTeamSC'],
      opponentTeamSC: json['opponentTeamSC'],
      ourScore: json['ourScore'],
      theirScore: json['theirScore'],
      stadiumSC: json['stadiumSC'],
      emotion: json['emotion'],
      mediaUrl: json['media_url'] ?? '',
      reviewText: json['review_text'] ?? '',
    );
  }
}



class SeatView {
  final int seatViewId;
  final String viewMediaUrl;

  SeatView({
    required this.seatViewId,
    required this.viewMediaUrl,
  });

  factory SeatView.fromJson(Map<String, dynamic> json) {
    return SeatView(
      seatViewId: json['seatViewId'],
      viewMediaUrl: json['viewMediaUrl'],
    );
  }
}

class SeatViewDetail {
  final int seatViewId;
  final String viewMediaUrl;
  final SeatInfo? seatInfo;
  final List<EmotionTag>? emotionTags;

  SeatViewDetail({
    required this.seatViewId,
    required this.viewMediaUrl,
    this.seatInfo,
    this.emotionTags,
  });

  factory SeatViewDetail.fromJson(Map<String, dynamic> json) {
    return SeatViewDetail(
      seatViewId: json['seatViewId'],
      viewMediaUrl: json['viewMediaUrl'],
      seatInfo: json['seatInfo'] != null ? SeatInfo.fromJson(json['seatInfo']) : null,
      emotionTags: (json['emotionTags'] as List<dynamic>?)
          ?.map((e) => EmotionTag.fromJson(e))
          .toList(),
    );
  }
}


class SeatInfo {
  final String zoneName;
  final String zoneShortCode;
  final String section;
  final String seatRow;
  final String stadiumName;

  SeatInfo({
    required this.zoneName,
    required this.zoneShortCode,
    required this.section,
    required this.seatRow,
    required this.stadiumName,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    return SeatInfo(
      zoneName: json['zoneName'],
      zoneShortCode: json['zoneShortCode'],
      section: json['section'],
      seatRow: json['seatRow'],
      stadiumName: json['stadiumName'],
    );
  }
}

class EmotionTag {
  final String code;
  final String label;

  EmotionTag({required this.code, required this.label});

  factory EmotionTag.fromJson(Map<String, dynamic> json) {
    return EmotionTag(
      code: json['code'],
      label: json['label'],
    );
  }
}


