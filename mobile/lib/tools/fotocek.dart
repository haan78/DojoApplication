import 'package:image_picker/image_picker.dart';

Future<XFile?> fotoFile() async {
  final imgpicker = ImagePicker();
  return await imgpicker.pickImage(source: ImageSource.camera, imageQuality: 30);
}
