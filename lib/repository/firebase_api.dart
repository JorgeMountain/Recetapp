import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetapp/models/recipe.dart';

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


  Future<String> createRecipe(Recipe recipe, File image) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final db = FirebaseFirestore.instance;
      final doc = db.collection('recipes').doc();

      // Subir imagen al Firebase Storage
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://recetapp-401ea');
      final storageRef = storage.ref().child('recipes/${doc.id}.jpg');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      // Guardar receta en Firestore
      recipe.id = doc.id;
      recipe.imageUrl = imageUrl;

      await doc.set(recipe.toJson());
      return doc.id;
    } catch (e) {
      print('Error al crear receta: $e');
      return e.toString();
    }
  }

  Future<List<Recipe>> fetchRecipes() async {
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection('recipes').orderBy('timestamp', descending: true).get();

      return querySnapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error al cargar recetas: $e');
      return [];
    }
  }



  Future<String> updateProfilePicture(File? image) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw FirebaseException(
            plugin: 'FirebaseAuth', code: 'no-user', message: 'User not logged in');
      }

      if (image == null) {
        throw Exception('No se seleccionó una imagen');
      }

      // Referencia al almacenamiento en Firebase
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://recetapp-401ea');
      final profileImageRef = storage.ref().child('profileImages/$uid.jpg');

      // Subir la imagen a Firebase Storage
      await profileImageRef.putFile(image);

      // Obtener la URL de descarga de la imagen
      final profileImageUrl = await profileImageRef.getDownloadURL();

      // Guardar la URL de la foto de perfil en Firestore
      final db = FirebaseFirestore.instance;
      await db.collection('users').doc(uid).update({
        'profileImageUrl': profileImageUrl,
      });

      return profileImageUrl;
    } catch (e) {
      print("Error al actualizar la foto de perfil: $e");
      return "unknown-error";
    }
  }


  Future<String> updateBackgroundImage(File? image) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw FirebaseException(
            plugin: 'FirebaseAuth', code: 'no-user', message: 'User not logged in');
      }

      if (image == null) {
        throw Exception('No se seleccionó una imagen');
      }

      // Referencia al almacenamiento en Firebase
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://recetapp-401ea');
      final backgroundImageRef = storage.ref().child('backgroundImages/$uid.jpg');

      // Subir la imagen a Firebase Storage
      await backgroundImageRef.putFile(image);

      // Obtener la URL de descarga de la imagen
      final backgroundImageUrl = await backgroundImageRef.getDownloadURL();

      // Guardar la URL de la imagen de fondo en Firestore
      final db = FirebaseFirestore.instance;
      await db.collection('users').doc(uid).update({
        'backgroundImage': backgroundImageUrl,
      });

      return backgroundImageUrl;
    } catch (e) {
      print("Error al actualizar la imagen de fondo: $e");
      return "unknown-error";
    }
  }



}
