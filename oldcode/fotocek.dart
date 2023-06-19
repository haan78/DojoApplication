import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> fixExifRotation(Uint8List imageBytes) async {
  final originalImage = img.decodeImage(imageBytes);

  final height = originalImage!.height;
  final width = originalImage.width;
  final exifData = await readExifFromBytes(imageBytes);
  final imgOr = exifData['Image Orientation']!;
  print([height, width, imgOr.printable]);
  if (height < width) {
    img.Image fixedImage;
    if (imgOr.printable.contains('Horizontal')) {
      print("Dondur +90");
      fixedImage = img.copyRotate(originalImage, angle: 90);
    } else if (imgOr.printable.contains('180')) {
      print("Dondur -90");
      fixedImage = img.copyRotate(originalImage, angle: -90);
    } else {
      print("Dondur +90 2");
      fixedImage = img.copyRotate(originalImage, angle: -90);
    }
    return img.encodeJpg(fixedImage, quality: 100);
  } else {
    print("Dondur 0");
    return imageBytes;
  }
}

Future<Uint8List?> fotoCek() async {
  final imgpicker = ImagePicker();
  final imgfile = await imgpicker.pickImage(source: ImageSource.camera, imageQuality: 30);
  if (imgfile != null) {
    return await fixExifRotation(await imgfile.readAsBytes());
  } else {
    return null;
  }
}

Future<XFile?> fotoFile() async {
  final imgpicker = ImagePicker();
  return await imgpicker.pickImage(source: ImageSource.camera, imageQuality: 30);
}
