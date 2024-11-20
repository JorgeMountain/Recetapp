import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../repository/firebase_api.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  File? _image;

  Future<void> _uploadProfilePicture() async {
    if (_image == null) {
      _showMessage("Por favor, selecciona una imagen.");
      return;
    }

    try {
      final result = await _firebaseApi.updateProfilePicture(_image!);
      if (result.isNotEmpty) {
        _showMessage("Foto de perfil actualizada correctamente.");
        setState(() {}); // Update UI if needed
      } else {
        _showMessage("Error al actualizar la foto de perfil.");
      }
    } catch (e) {
      _showMessage("Ocurrió un error: $e");
    }
  }

  Future<void> _pickImage(bool fromCamera) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedImage == null) return;

      setState(() {
        _image = File(pickedImage.path);
      });
    } on PlatformException catch (e) {
      _showMessage("Error al seleccionar la imagen: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actualizar Foto de Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the profile picture
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(
                  _image!,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galería"),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Cámara"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProfilePicture,
              child: const Text("Actualizar Foto"),
            ),
          ],
        ),
      ),
    );
  }
}
