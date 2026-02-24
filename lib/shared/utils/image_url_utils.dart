String? originalImageUrlFromThumb(String? url) {
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  final pathSegments = List<String>.from(uri.pathSegments);
  final thumbIndex = pathSegments.indexOf('thumb');
  if (thumbIndex < 0) return null;

  pathSegments.removeAt(thumbIndex);
  return uri.replace(pathSegments: pathSegments).toString();
}
