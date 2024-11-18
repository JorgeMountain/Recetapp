import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'food_preferences_page.dart'; // Nueva página de preferencias alimentarias
import '../repository/firebase_api.dart'; // Importa FirebaseApi para el registro

enum Genre { male, female }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repPassword = TextEditingController();
  bool _passwordVisible = false;
  bool _repPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  String buttonMsg = "Seleccionar Fecha de Nacimiento";
  DateTime _birthDate = DateTime.now();
  Genre? _selectedGenre = Genre.male; // Género seleccionado

  final FirebaseApi _firebaseApi = FirebaseApi(); // Instancia de FirebaseApi

  // Decoración de los campos de entrada
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE6E6FA), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );
  }

  void _showSelectedDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
      helpText: "Selecciona tu Fecha de Nacimiento",
    );
    if (newDate != null) {
      setState(() {
        _birthDate = newDate;
        buttonMsg = "Fecha de Nacimiento: ${_dateConverter(_birthDate)}";
      });
    }
  }

  String _dateConverter(DateTime newDate) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(newDate);
  }


  void _createUserInDB(User user) async {
    var result = await _firebaseApi.createUserInDB(user);

    if (result == 'network-request-failed') {
      _showMessage('Revise su conexión a internet');
    } else {
      _showMessage('Usuario creado con éxito');
      Navigator.pop(context);
    }
  }


  // Lógica para registrar el usuario con FirebaseApi
  void _createUser() async {
    String? result = await _firebaseApi.createUser(_email.text, _password.text);

    if (result == 'email-already-in-use') {
      _showMessage("Este correo ya está en uso.");
    } else if (result == 'weak-password') {
      _showMessage("La contraseña es demasiado débil.");
    } else if (result == 'invalid-email') {
      _showMessage("El correo es inválido.");
    } else if (result != null) {
      // Navegar a la página de preferencias con los datos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FoodPreferencesPage(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            birthDate: _birthDate.toString(),
            genre: _selectedGenre == Genre.male ? "Masculino" : "Femenino",
            uid: result, // Pasamos el UID generado
          ),
        ),
      );
    } else {
      _showMessage("Error desconocido al crear el usuario.");
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Este correo ya está en uso.';
      case 'invalid-email':
        return 'El correo es inválido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'network-request-failed':
        return 'Revise su conexión a internet.';
      default:
        return 'Error desconocido: $errorCode';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onNextButtonClicked() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_password.text == _repPassword.text) {
        _createUser(); // Registra al usuario usando FirebaseApi
      } else {
        _showMessage("Las contraseñas no coinciden.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
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
                    'Crear tu Cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Nombre de usuario"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _email,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Correo electrónico"),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      } else if (!value.isValidEmail()) {
                        return 'Este correo no es válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _password,
                    obscureText: !_passwordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Contraseña").copyWith(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      } else if (!value.isPasswordValid()) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _repPassword,
                    obscureText: !_repPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Repite tu contraseña").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _repPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _repPasswordVisible = !_repPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      } else if (value != _password.text) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // Selector de género
                  const Text(
                    "Seleccione su género:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            "Masculino",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                          leading: Radio<Genre>(
                            value: Genre.male,
                            groupValue: _selectedGenre,
                            activeColor: const Color(0xFFE6E6FA),
                            onChanged: (Genre? value) {
                              setState(() {
                                _selectedGenre = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            "Femenino",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                          leading: Radio<Genre>(
                            value: Genre.female,
                            groupValue: _selectedGenre,
                            activeColor: const Color(0xFFE6E6FA),
                            onChanged: (Genre? value) {
                              setState(() {
                                _selectedGenre = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Botón para la selección de la fecha de nacimiento
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6FA),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 8,
                    ),
                    child: Text(buttonMsg, style: const TextStyle(color: Colors.black, fontSize: 16.0)),
                    onPressed: _showSelectedDate,
                  ),

                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6FA),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                    onPressed: _onNextButtonClicked, // Llama a la función para registrar
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      // Navegar a iniciar sesión
                    },
                    child: const Text(
                      '¿Ya tienes una cuenta? Inicia sesión',
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

extension on String {
  bool isValidEmail() {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension on String {
  bool isPasswordValid() {
    return length >= 6;
  }
}
