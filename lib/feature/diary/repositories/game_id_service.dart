import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/service/home_view.dart';
import '../repositories/add_diary_repository.dart';

class GameIdService {
  final AddDiaryRepository repo;
  GameIdService(this.repo);

  Future<GameInfoResponse?> getGameInfo({
    required DateTime date,
    required String myTeam,
    required String opponentTeam,
  }) async {
    final formattedDate = DateFormat('yyyyMMdd').format(date);
    final gameId1 = '${formattedDate}${opponentTeam}${myTeam}0';
    final gameId2 = '${formattedDate}${myTeam}${opponentTeam}0';

    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) return null;

    for (final gameId in [gameId1, gameId2]) {
      final data = await repo.getJournalContents(gameId: gameId, memberId: memberId);
      if (data != null) return GameInfoResponse.fromJson(data);
    }
    return null;
  }
}
