import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildDefaultUploadBox() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: _CameraIcon(),
    ),
  );
}

class _CameraIcon extends StatelessWidget {
  const _CameraIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/icons/camera_icon.svg",
      width: 28.3,
      height: 28.3,
    );
  }
}