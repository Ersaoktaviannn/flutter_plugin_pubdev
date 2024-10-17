// result_page.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ResultPage extends StatelessWidget {
  final String recognizedText;

  const ResultPage({Key? key, required this.recognizedText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil OCR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AutoSizeText(
          recognizedText.isNotEmpty
              ? recognizedText
              : 'Tidak ada teks yang dikenali.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
