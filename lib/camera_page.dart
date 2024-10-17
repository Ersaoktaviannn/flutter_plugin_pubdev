import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class DesktopCameraPage extends StatefulWidget {
  const DesktopCameraPage({Key? key}) : super(key: key);

  @override
  _DesktopCameraPageState createState() => _DesktopCameraPageState();
}

class _DesktopCameraPageState extends State<DesktopCameraPage> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Desktop Camera')),
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: CameraPreview(_controller!),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await _controller!.takePicture();
            if (!mounted) return;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Captured Image'),
                content: Image.network(image.path),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          } catch (e) {
            print('Error taking picture: $e');
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
