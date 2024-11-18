import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart' as UserApp;

class FirebaseApi {
  // Crear un usuario en Firebase Auth
  Future<String?> createUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid; // Retornar el UID del usuario creado
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      return e.code; // Retorna el código de error
    } on FirebaseException catch (e) {
      print("FirebaseException: ${e.code}");
      return e.code; // Retorna el código de error
    }
  }

  // Iniciar sesión en Firebase Auth
  Future<String?> signInUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid; // Retornamos el UID si el inicio es exitoso
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      return e.code; // Retorna el código de error
    } on FirebaseException catch (e) {
      print("FirebaseException: ${e.code}");
      return e.code; // Retorna el código de error
    }
  }

  // Crear el usuario en Firestore con sus datos iniciales
  Future<String> createUserInDB(UserApp.User user) async {
    try {
      var db = FirebaseFirestore.instance;
      await db.collection('users').doc(user.uid).set(user.toJson());
      return user.uid;
    } on FirebaseException catch (e) {
      print("FirebaseException: ${e.code}");
      return e.code;
    }
  }

  // Subir imágenes al Storage y retornar la URL de descarga
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadImage(File image, {String? folder}) async {
    try {
      // Crea una referencia única para la imagen
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final folderPath = folder ?? 'uploads';
      final imageRef = _storage.ref('$folderPath/$timestamp.jpg');

      // Sube la imagen
      final uploadTask = await imageRef.putFile(image);

      // Obtiene la URL pública
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.message}');
      rethrow;
    }
  }

  // Actualizar un campo específico del usuario en Firestore
  Future<void> updateProfileField(String field, String value) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("Usuario no autenticado");
      }

      final userDoc = FirebaseFirestore.instance.collection("users").doc(userId);
      await userDoc.update({field: value});
    } catch (e) {
      print("Error al actualizar Firestore: $e");
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("Usuario no autenticado");
      }

      final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      return userDoc.data();
    } catch (e) {
      print("Error al obtener datos del usuario: $e");
      return null;
    }
  }

  Future<File?> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      print("Ruta del archivo seleccionado: ${image.path}");
      return File(image.path); // Retornar el archivo
    } else {
      print("No se seleccionó ninguna imagen.");
      return null;
    }
  }

  Future<void> uploadSelectedImage(String folderName) async {
    final image = await pickImage();
    if (image != null) {
      // Aquí iría la lógica para subir la imagen a Firebase
    }
  }

}
