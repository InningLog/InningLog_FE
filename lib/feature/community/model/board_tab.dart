enum BoardTab { onlywan, free, news }

const Map<BoardTab, String> _boardTabPaths = {
  BoardTab.onlywan: 'onlywan',
  BoardTab.free: 'free',
  BoardTab.news: 'news',
};

String boardTabPath(BoardTab tab) => _boardTabPaths[tab]!;

BoardTab boardTabFromPath(String value) {
  for (final entry in _boardTabPaths.entries) {
    if (entry.value == value) return entry.key;
  }
  return BoardTab.free;
}
