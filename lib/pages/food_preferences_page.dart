import 'package:flutter/material.dart';
import 'package:recetapp/pages/navigation_bar_page.dart';
import '../models/user.dart';
import '../repository/firebase_api.dart';
import 'login_page.dart';

class FoodPreferencesPage extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final String password;
  final String birthDate;
  final String genre;

  const FoodPreferencesPage({
    Key? key,
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.genre,
  }) : super(key: key);

  @override
  _FoodPreferencesPageState createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  bool _ketoDiet = false;
  bool _vegetarian = false;
  bool _vegan = false;
  bool _glutenFree = false;
  bool _carnivoreDiet = false;
  bool _mediterraneanDiet = false;
  bool _noRestrictions = false;

  bool _petsRecipes = false;
  bool _kidsRecipes = false;

  // Método para manejar la lógica de selección de "Sin restricciones"
  void _onNoRestrictionsChanged(bool? value) {
    setState(() {
      _noRestrictions = value ?? false;

      if (_noRestrictions) {
        // Desactivar todas las demás opciones
        _ketoDiet = false;
        _vegetarian = false;
        _vegan = false;
        _glutenFree = false;
        _carnivoreDiet = false;
        _mediterraneanDiet = false;
      }
    });
  }

  void _onCreateAccount() async {
    final newUser = User(
      widget.uid, // UID generado en RegisterPage
      widget.name,
      widget.email,
      widget.password,
      widget.birthDate,
      widget.genre,
      _ketoDiet,
      _vegetarian,
      _vegan,
      _glutenFree,
      _carnivoreDiet,
      _mediterraneanDiet,
      _noRestrictions,
      _petsRecipes,
      _kidsRecipes,
    );

    // Guardar usuario en Firestore
    final result = await FirebaseApi().createUserInDB(newUser);

    if (result == widget.uid) {
      // Navegar a la siguiente página (NavigationBarPage, por ejemplo)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NavigationBarPage(),
        ),
      );
    } else {
      // Mostrar un mensaje de error si ocurre un problema
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el usuario: $result')),
      );
    }
  }

  // Método para deshabilitar las demás opciones si "Sin restricciones" está activado
  bool _isOptionDisabled() {
    return _noRestrictions;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black, // Fondo negro
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Preferencias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8, // Título minimalista
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF333333)], // Fondo degradado de negro
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),

              // Título: Preferencias alimentarias
              const Text(
                'Preferencias alimentarias',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),

              // CheckboxListTiles para las preferencias alimentarias
              CheckboxListTile(
                title: const Text('🥑 Dietas Keto', style: TextStyle(color: Colors.white70)),
                value: _ketoDiet,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _isOptionDisabled() ? null : (bool? value) {
                  setState(() {
                    _ketoDiet = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🥩 Dieta Carnívora', style: TextStyle(color: Colors.white70)),
                value: _carnivoreDiet,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _isOptionDisabled() ? null : (bool? value) {
                  setState(() {
                    _carnivoreDiet = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🍅 Dieta Mediterránea', style: TextStyle(color: Colors.white70)),
                value: _mediterraneanDiet,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _isOptionDisabled() ? null : (bool? value) {
                  setState(() {
                    _mediterraneanDiet = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🥦 Vegetariano', style: TextStyle(color: Colors.white70)),
                value: _vegetarian,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _isOptionDisabled() ? null : (bool? value) {
                  setState(() {
                    _vegetarian = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🌱 Vegano', style: TextStyle(color: Colors.white70)),
                value: _vegan,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _isOptionDisabled() ? null : (bool? value) {
                  setState(() {
                    _vegan = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🌾 Sin gluten', style: TextStyle(color: Colors.white70)),
                value: _glutenFree,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _isOptionDisabled() ? null : (bool? value) {
                  setState(() {
                    _glutenFree = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🚫 Sin restricciones alimentarias', style: TextStyle(color: Colors.white70)),
                value: _noRestrictions,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: _onNoRestrictionsChanged,
              ),

              const SizedBox(height: 20.0),

              // Título: Otras preferencias
              const Text(
                'Otras preferencias',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),

              // Preferencias de recetas para mascotas y niños
              CheckboxListTile(
                title: const Text('🐶 Recetas para mascotas', style: TextStyle(color: Colors.white70)),
                value: _petsRecipes,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: (bool? value) {
                  setState(() {
                    _petsRecipes = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('👶 Recetas para niños', style: TextStyle(color: Colors.white70)),
                value: _kidsRecipes,
                activeColor: const Color(0xFFE6E6FA),
                onChanged: (bool? value) {
                  setState(() {
                    _kidsRecipes = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20.0),

              // Botón de creación de cuenta
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6E6FA), // Botón lavanda
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Botón redondeado
                    ),
                    shadowColor: Colors.black.withOpacity(0.5), // Sombra suave
                    elevation: 8,
                  ),
                  onPressed: _onCreateAccount,
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(fontSize: 18.0, color: Colors.black), // Texto negro
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
