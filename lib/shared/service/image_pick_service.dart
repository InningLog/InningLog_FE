import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImagePickService {
  final ImagePicker _picker;
  ImagePickService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<List<Uint8List>> pickMultiBytes({required int limit}) async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return [];

    final picked = files.take(limit);
    return Future.wait(picked.map((x) => x.readAsBytes()));
  }
}
