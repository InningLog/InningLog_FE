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
