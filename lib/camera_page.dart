// camera_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:page_transition/page_transition.dart';
import 'result_page.dart';

class DesktopCameraPage extends StatefulWidget {
  const DesktopCameraPage({Key? key}) : super(key: key);

  @override
  _DesktopCameraPageState createState() => _DesktopCameraPageState();
}

class _DesktopCameraPageState extends State<DesktopCameraPage> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isProcessing = false;

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

  Future<String> _performOCR(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    String extractedText = recognizedText.text;
    return extractedText;
  }

  void _captureAndProcessImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();

      // Perform OCR
      String recognizedText = await _performOCR(image.path);

      // Navigasi ke halaman hasil OCR dengan transisi
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: ResultPage(recognizedText: recognizedText),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
      // Tampilkan pesan error jika terjadi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil gambar')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Desktop Camera')),
        body: const Center(
          child: SpinKitFadingCircle(
            color: Colors.blue,
            size: 50.0,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Desktop Camera')),
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitCircle(
                  color: Colors.white,
                  size: 80.0,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _captureAndProcessImage,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
