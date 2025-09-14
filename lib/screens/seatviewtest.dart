import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart'; // parseSvgPathData 사용

class Seatviewtest extends StatefulWidget {
  const Seatviewtest({super.key});

  @override
  State<Seatviewtest> createState() => _SeatviewtestState();
}

class _SeatviewtestState extends State<Seatviewtest> {
  final TransformationController _tc = TransformationController();
  String? _activeId;
  final List<_SeatRegion> _regions = [];
  Size _canvasSize = const Size(2000, 2000); // SVG viewBox와 동일

  @override
  void initState() {
    super.initState();
    _loadSvg();
    // 첫 프레임 후 자동 zoom-to-fit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitToScreen();
    });
  }

  Future<void> _loadSvg() async {
    final svgStr = await rootBundle.loadString('assets/svg/jamsil.svg');
    final doc = xml.XmlDocument.parse(svgStr);

    // viewBox 읽어서 canvasSize 설정
    final svgEl = doc.findAllElements('svg').first;
    final vb = svgEl.getAttribute('viewBox');
    if (vb != null) {
      final nums = vb.split(RegExp(r'[ ,]+')).map(double.parse).toList();
      if (nums.length == 4) _canvasSize = Size(nums[2], nums[3]);
    }

    _regions.clear();

    for (final p in doc.findAllElements('path')) {
      // path 자체 속성
      String? id = p.getAttribute('id');
      String? section = p.getAttribute('data-section');
      String? zone = p.getAttribute('data-zone');

      // 부모 <g>에서 상속
      final parent = p.parent;
      if (parent is xml.XmlElement) {
        id ??= parent.getAttribute('id');
        section ??= parent.getAttribute('data-section');
        zone ??= parent.getAttribute('data-zone');
      }

      final dAttr = p.getAttribute('d');
      if (id == null || dAttr == null || dAttr.trim().isEmpty) continue;

      final geom = parseSvgPathData(dAttr);

      _regions.add(_SeatRegion(
        id: id,
        section: section,
        zone: zone,
        path: geom,
      ));

      debugPrint('✅ loaded: id=$id, section=$section, zone=$zone');
    }

    debugPrint('총 로딩된 path 개수: ${_regions.length}');
    setState(() {});
  }

  void _fitToScreen() {
    final size = MediaQuery.of(context).size;
    final scale = math.min(
      size.width / _canvasSize.width,
      (size.height - kToolbarHeight) / _canvasSize.height,
    );
    _tc.value = Matrix4.identity()..scale(scale);
  }

  void _onTapUp(TapUpDetails d) {
    final inv = Matrix4.inverted(_tc.value);
    final world = MatrixUtils.transformPoint(inv, d.localPosition);
    final pt = Offset(world.dx, world.dy);

    _SeatRegion? hit;
    for (final r in _regions) {
      if (r.path.contains(pt)) hit = r;
    }

    if (hit != null) {
      setState(() => _activeId = hit!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hit!.id} 클릭됨!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVG 좌석도 테스트')),
      body: GestureDetector(
        onTapUp: _onTapUp,
        child: InteractiveViewer(
          transformationController: _tc,
          minScale: 0.1,
          maxScale: 8,
          constrained: false,
          child: SizedBox(
            width: _canvasSize.width,
            height: _canvasSize.height,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                // ✅ SVG
                SizedBox(
                  width: _canvasSize.width,
                  height: _canvasSize.height,
                  child: SvgPicture.asset(
                    'assets/svg/jamsil.svg',
                    alignment: Alignment.topLeft,
                  ),
                ),
                // ✅ Overlay Painter
                SizedBox(
                  width: _canvasSize.width,
                  height: _canvasSize.height,
                  child: CustomPaint(
                    painter: _SeatPainter(_regions, _activeId),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatRegion {
  final String id;
  final String? section;
  final String? zone;
  final Path path;
  _SeatRegion({required this.id, this.section, this.zone, required this.path});
}

class _SeatPainter extends CustomPainter {
  final List<_SeatRegion> regions;
  final String? activeId;
  _SeatPainter(this.regions, this.activeId);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF4CAF50);
    final activeFill = Paint()..color = const Color(0x8032CD32);

    for (final r in regions) {
      if (r.id == activeId) canvas.drawPath(r.path, activeFill);
      canvas.drawPath(r.path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SeatPainter old) =>
      old.activeId != activeId || old.regions != regions;
}
