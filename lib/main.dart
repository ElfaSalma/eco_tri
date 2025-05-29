// main.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

void main() => runApp(EcoTriApp());

class EcoTriApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTri',
      theme: ThemeData(primarySwatch: Colors.green),
      home: EcoTriHomePage(),
    );
  }
}

class EcoTriHomePage extends StatefulWidget {
  @override
  _EcoTriHomePageState createState() => _EcoTriHomePageState();
}

class _EcoTriHomePageState extends State<EcoTriHomePage> {
  File? _image;
  String _label = '';
  String _message = '';

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      classifyImage(_image!);
    }
  }

  Future<void> classifyImage(File image) async {
    final result = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      threshold: 0.5,
    );

    if (result != null && result.isNotEmpty) {
      final label = result[0]['label'];
      setState(() {
        _label = label;
        _message = getEcoMessage(label);
      });
    }
  }

  String getEcoMessage(String label) {
    switch (label.toLowerCase()) {
      case 'plastique':
        return 'Veuillez vider les bouteilles en plastique avant de les jeter.';
      case 'verre':
        return 'Les bocaux et bouteilles en verre vont dans le conteneur à verre. Pas les miroirs !';
      case 'papier':
        return 'Pliez les cartons pour gagner de la place.';
      case 'déchets électroniques':
        return 'Apportez les batteries et téléphones usagés en déchetterie.';
      default:
        return 'Catégorie non reconnue. Veuillez réessayer avec une autre image.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EcoTri')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('Aucune image sélectionnée.')
                : Image.file(_image!, height: 200),
            SizedBox(height: 20),
            Text(
              'Catégorie : $_label',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _message,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Choisir une image'),
            ),
          ],
        ),
      ),
    );
  }
}
