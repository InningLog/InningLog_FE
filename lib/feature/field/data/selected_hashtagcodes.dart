final Map<String, String> tagCodeMap = {
  '#일어남': 'CHEERING_STANDING',
  '#일어날_사람은_일어남': 'CHEERING_MOSTLY_STANDING',
  '#앉아서': 'CHEERING_SEATED',
  '#강함': 'SUN_STRONG',
  '#있다가_그늘짐': 'SUN_MOVES_TO_SHADE',
  '#없음': 'SUN_NONE', // 햇빛 - 없음
  '#있음': 'ROOF_EXISTS', // 지붕 - 있음
  '#없음_지붕': 'ROOF_NONE', // 구분 위해 이름 바꿈
  '#그물': 'VIEW_OBSTRUCT_NET',
  '#아크릴_가림막': 'VIEW_OBSTRUCT_ACRYLIC',
  '#없음_시야방해': 'VIEW_NO_OBSTRUCTION', // 구분 위해 이름 바꿈
  '#아주_넓음': 'SEAT_SPACE_VERY_WIDE',
  '#넓음': 'SEAT_SPACE_WIDE',
  '#보통': 'SEAT_SPACE_NORMAL',
  '#좁음': 'SEAT_SPACE_NARROW',
};
List<String> getSelectedHashtagCodes(Map<String, String> selectedTags) {
  return selectedTags.values
      .map((tag) => tagCodeMap[tag] ?? '')
      .where((code) => code.isNotEmpty)
      .toList();
}