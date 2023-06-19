import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CallBackImge = void Function(Uint8List);
typedef CallBackError = void Function(String);

class Foto extends StatefulWidget {
  final CallBackImge cbImg;
  final CallBackError cbErr;
  const Foto({super.key, required this.cbImg, required this.cbErr});

  @override
  State<StatefulWidget> createState() {
    return _Foto();
  }
}

class _Foto extends State<Foto> {
  CameraController? controller;
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final firstCamera = cameras.first;
      controller = CameraController(firstCamera, ResolutionPreset.low);

      await controller!.initialize();

      controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } else {
      controller = null;
    }
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: FutureBuilder<void>(
        future: initCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            if (controller != null) {
              return CameraPreview(controller!);
            } else {
              return const Center(child: Text("No camera"));
            }
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (controller != null) {
              try {
                final ifile = await controller!.takePicture();
                final idata = await ifile.readAsBytes();
                widget.cbImg(idata);
              } catch (e) {
                widget.cbErr(e.toString());
              }
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: const Icon(Icons.camera_alt)),
    );
  }
}
