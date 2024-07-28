import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini_ai/global_variabel.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController promptController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  String answer = '';
  XFile? image;

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //HEADER
      appBar: AppBar(
        title: const Text('Gemini AI'),
        centerTitle: true,
      ),

      //BODY
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          TextField(
            controller: promptController,
            decoration: const InputDecoration(
              hintText: 'Masukan Text Anda',
              border: OutlineInputBorder(),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: (image == null) ? Colors.amber.withOpacity(0.2) : null,
              image: (image != null)
                  ? DecorationImage(image: FileImage(File(image!.path)))
                  : null,
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  final pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      image = pickedImage;
                    });
                  }
                } catch (e) {
                  print('Error picking image: $e');
                }
              },
              child: const Text("Pick Image")),
          ElevatedButton(
              onPressed: () {
                GenerativeModel model = GenerativeModel(
                  model: 'gemini-1.5-flash-latest',
                  apiKey: API_KEY,
                );

                //HANYA TEXT BIASA TANPA FOTO

                // model.generateContent(
                //     [Content.text(promptController.text)]).then((value) {
                //   setState(() {
                //     answer = value.text.toString();
                //   });
                // });

                //MENGGUNAKAN TEXT DAN FOTO

                model.generateContent([
                  Content.multi([
                    TextPart(promptController.text),
                    if (image != null)
                      DataPart(
                        'image/jpeg',
                        File(image!.path).readAsBytesSync(),
                      )
                  ])
                ]).then((value) {
                  setState(() {
                    answer = value.text.toString();
                  });
                });
              },
              child: const Text("Send")),
          Text(answer)
        ],
      ),
    );
  }
}
