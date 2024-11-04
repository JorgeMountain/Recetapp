import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  Future<String?> createUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      // Si la creación de usuario es exitosa, retornamos el UID
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      return e.code; // Retorna el código de error
    } on FirebaseException catch (e) {
      print("FirebaseException: ${e.code}");
      return e.code; // Retorna el código de error
    }
  }

  Future<String?> signInUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid; // Retornamos el UID si el inicio es exitoso
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException ${e.code}");
      return e.code; // Retorna el código de error
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code; // Retorna el código de error
    }
  }
}
