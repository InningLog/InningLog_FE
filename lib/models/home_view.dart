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
    required this.gameDateTime,
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
      gameDateTime: json['gameDateTime'],
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
  final String? emotion;



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
      stadiumSC: json['stadiumSC'] ?? '구장 정보 없음', mediaUrl: '',
      reviewText: json['review_text'] ?? '',
      emotion: json['emotion'] ?? '',
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

class SeatViewDetail {
  final int seatViewId;
  final String viewMediaUrl;
  final String stadiumName;
  final String zoneName;
  final String section;
  final String seatRow;
  final List<String> emotionTags;

  SeatViewDetail({
    required this.seatViewId,
    required this.viewMediaUrl,
    required this.stadiumName,
    required this.zoneName,
    required this.section,
    required this.seatRow,
    required this.emotionTags,
  });

  factory SeatViewDetail.fromJson(Map<String, dynamic> json) {
    final seatInfo = json['seatInfo'];
    final tags = (json['emotionTags'] as List)
        .map<String>((tag) => tag['label'] as String)
        .toList();

    return SeatViewDetail(
      seatViewId: json['seatViewId'],
      viewMediaUrl: json['viewMediaUrl'],
      stadiumName: seatInfo['stadiumName'],
      zoneName: seatInfo['zoneName'],
      section: seatInfo['section'],
      seatRow: seatInfo['seatRow'],
      emotionTags: tags,
    );
  }
}

class SeatViewSimple {
  final int seatViewId;
  final String viewMediaUrl;

  SeatViewSimple({
    required this.seatViewId,
    required this.viewMediaUrl,
  });

  factory SeatViewSimple.fromJson(Map<String, dynamic> json) {
    return SeatViewSimple(
      seatViewId: json['seatViewId'],
      viewMediaUrl: json['viewMediaUrl'],
    );
  }
}

class SeatViewSummary {
  final int seatViewId;
  final String viewMediaUrl;

  SeatViewSummary({
    required this.seatViewId,
    required this.viewMediaUrl,
  });

  factory SeatViewSummary.fromJson(Map<String, dynamic> json) {
    return SeatViewSummary(
      seatViewId: json['seatViewId'],
      viewMediaUrl: json['viewMediaUrl'],
    );
  }
}
