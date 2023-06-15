import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> fixExifRotation(Uint8List imageBytes) async {
  final originalImage = img.decodeImage(imageBytes);

  final height = originalImage!.height;
  final width = originalImage.width;

  if (height < width) {
    final exifData = await readExifFromBytes(imageBytes);
    img.Image fixedImage;
    final imgOr = exifData['Image Orientation']!;
    //print([height, width, imgOr.printable]);
    if (imgOr.printable.contains('Horizontal')) {
      fixedImage = img.copyRotate(originalImage, angle: 90);
    } else if (imgOr.printable.contains('180')) {
      fixedImage = img.copyRotate(originalImage, angle: -90);
    } else {
      fixedImage = img.copyRotate(originalImage, angle: -90);
    }
    return img.encodeJpg(fixedImage, quality: 40);
  } else {
    return imageBytes;
  }
}

Future<Uint8List?> fotoCek() async {
  final imgpicker = ImagePicker();
  final imgfile = await imgpicker.pickImage(source: ImageSource.camera, imageQuality: 30);
  if (imgfile != null) {
    return fixExifRotation(await imgfile.readAsBytes());
  } else {
    return null;
  }
}
