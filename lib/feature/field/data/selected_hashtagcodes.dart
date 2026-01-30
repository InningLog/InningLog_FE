final Map<String, String> tagCodeMap = {
  '#일어남': 'CHEERING_STANDING',
  '#일어날_사람은_일어남': 'CHEERING_MOSTLY_STANDING',
  '#앉아서': 'CHEERING_SEATED',
  '#강함': 'SUN_STRONG',
  '#있다가_그늘짐': 'SUN_MOVES_TO_SHADE',
  '#햇빛_없음': 'SUN_NONE',
  '#있음': 'ROOF_EXISTS',
  '#없음': 'ROOF_NONE',
  '#그물': 'VIEW_OBSTRUCT_NET',
  '#아크릴_가림막': 'VIEW_OBSTRUCT_ACRYLIC',
  '#시야방해_없음': 'VIEW_NO_OBSTRUCTION',
  '#아주_넓음': 'SEAT_SPACE_VERY_WIDE',
  '#넓음': 'SEAT_SPACE_WIDE',
  '#보통': 'SEAT_SPACE_NORMAL',
  '#좁음': 'SEAT_SPACE_NARROW',
};
List<String> getSelectedHashtagCodes(
    Map<String, List<String>> selectedTags,
    ) {
  return selectedTags.values
      .expand((tags) => tags)
      .map((tag) => tagCodeMap[tag])
      .whereType<String>()
      .toList();
}
