import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class JamsilMap extends StatefulWidget {
  const JamsilMap({
    Key? key,
    required this.onSectionSelected,
  }) : super(key: key);

  // 🔥 FieldSearchPage에서 넘겨준 콜백
  final ValueChanged<String> onSectionSelected;

  @override
  State<JamsilMap> createState() => _JamsilMapState();
}


class _JamsilMapState extends State<JamsilMap> {
  final String assetPath = 'assets/jamsil.svg';

  // id -> Path (SVG 좌표계 기준)
  final Map<String, Path> _areas = {};
  bool _loading = true;

  // SVG viewBox 사이즈 (파일에서 가져온 값: 0 0 1279 1279)
  final double svgWidth = 1279;
  final double svgHeight = 1279;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    final svgString = await rootBundle.loadString(assetPath);
    final doc = XmlDocument.parse(svgString);

    // g 태그 순회하며 JS= 로 시작하는 id만 버튼으로 사용
    for (final g in doc.findAllElements('g')) {
      final id = g.getAttribute('id');
      if (id == null) continue;
      if (!id.startsWith('JS=')) continue;

      final paths = g.findAllElements('path');
      if (paths.isEmpty) continue;

      final Path combined = Path();
      for (final p in paths) {
        final d = p.getAttribute('d');
        if (d == null) continue;
        final parsed = parseSvgPathData(d);
        combined.addPath(parsed, Offset.zero);
      }

      if (!combined.getBounds().isEmpty) {
        _areas[id] = combined;
      }
    }

    setState(() {
      _loading = false;
    });
  }

  void _onTapDown(BuildContext context, TapDownDetails details, Size size) {
    if (_loading) return;

    final local = details.localPosition;

    // 화면 사이즈 -> SVG 좌표로 변환 (비율 유지)
    final scale = _calcScale(size);
    final dx = (size.width - svgWidth * scale) / 2;
    final dy = (size.height - svgHeight * scale) / 2;

    final svgX = (local.dx - dx) / scale;
    final svgY = (local.dy - dy) / scale;
    final point = Offset(svgX, svgY);

    String? hitId;

    _areas.forEach((id, path) {
      if (hitId != null) return;
      if (path.contains(point)) {
        hitId = id;
      }
    });

    if (hitId != null) {
      _onAreaTap(hitId!);
    }
  }

  double _calcScale(Size size) {
    final sx = size.width / svgWidth;
    final sy = size.height / svgHeight;
    // viewBox 비율 유지하려면 min 사용
    return sx < sy ? sx : sy;
  }

  void _onAreaTap(String id) {
    debugPrint('Tapped: $id');

    if (!id.startsWith('JS=')) return;
    final section = id.substring(3); // "113"

    // 숫자만 쓰고 싶다면 안전 체크(선택)
    if (int.tryParse(section) == null) return;

    widget.onSectionSelected(section); // ✅ FieldSearchPage로 전달!
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _onTapDown(context, d, size),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: svgWidth,
              height: svgHeight,
              child: SvgPicture.asset(assetPath),
            ),
          ),
        );
      },
    );
  }
}