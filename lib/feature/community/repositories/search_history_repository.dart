import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryRepository {
  static const _prefsKey = 'community_search_history';
  static const maxHistory = 15;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> save(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, history);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
