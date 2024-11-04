import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase para la autenticación
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_bar_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  // Mostrar un mensaje emergente
  void _showMessage(String msg) {
    setState(() {
      final snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  // Guardar la sesión del usuario localmente
  Future<void> _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isUserLogged", true);
  }

  // Iniciar sesión en Firebase
  Future<void> _onLoginButtonClicked() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Intentar iniciar sesión con Firebase
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );
        _showMessage('Bienvenido');
        _saveSession(); // Guardar la sesión

        // Navegar a la página principal (NavigationBarPage) y eliminar todas las pantallas anteriores
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBarPage()),
              (Route<dynamic> route) => false, // Esto elimina todas las rutas anteriores
        );
      } catch (e) {
        _showMessage('Correo o contraseña incorrectos.'); // Mostrar error
      }
    }
  }

  // Estilos de los campos de entrada
  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.white),
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE6E6FA), width: 2.0), // Lavanda
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40.0),
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Campo de correo electrónico
                  TextFormField(
                    controller: _email,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Correo electrónico", Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      } else if (!value.isValidEmail()) {
                        return 'Ingrese un correo válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de contraseña
                  TextFormField(
                    controller: _password,
                    obscureText: !_passwordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Contraseña", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // Botón de iniciar sesión
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6FA), // Lavanda
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 8,
                    ),
                    onPressed: _onLoginButtonClicked,
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Botón para ir a la página de registro
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6FA), // Lavanda
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Opción de "¿Olvidaste tu contraseña?"
                  GestureDetector(
                    onTap: () {
                      // Aquí iría la lógica para recuperar la contraseña
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extensión para validar el correo electrónico
extension on String {
  bool isValidEmail() {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(this);
  }
}
