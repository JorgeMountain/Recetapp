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


  Future<String> updateProfilePicture(File? image) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw FirebaseException(
            plugin: 'FirebaseAuth', code: 'no-user', message: 'User not logged in');
      }
        print('aaaaaaaaaa');
      // Referencia al almacenamiento en Firebase
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://recetapp-401ea');
      print('bbbbbbbb');

      final profileImageRef = storage.ref().child('profileImage').child('$uid.jpg');
      print('cc');
      print(profileImageRef);
      // Subir la imagen a Firebase Storage
      await profileImageRef.putFile(image!);
      print('dd');
      // Obtener la URL de descarga de la imagen
      final profileImageUrl = await profileImageRef.getDownloadURL();
      print('ee');
      // Guardar la URL de la foto de perfil en Firestore
      final db = FirebaseFirestore.instance;
      print('fff');
      await db.collection('users').doc(uid).update({
        'profileImageUrl': profileImageUrl,
      });
      print('gg');
      await profileImageRef.delete().catchError((_) {
        // Ignorar si no existe una imagen previa
      });

      return profileImageUrl;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    } catch (e) {
      print("Exception $e");
      return "unknown-error";
    }

  }

}
