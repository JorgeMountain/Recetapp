import 'package:flutter/material.dart';
import 'package:recetapp/pages/food_home_page.dart';
import 'package:recetapp/pages/ingredients_list_page.dart';
import 'package:recetapp/pages/profile_page.dart';
import 'package:recetapp/pages/saved_page.dart';
import 'package:recetapp/pages/search_page.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FoodHomePage(),        // Página principal de comidas
    SearchPage(),          // Página de búsqueda
    SavedPage(),           // Página de recetas guardadas
    IngredientsListPage(), // Página de lista de ingredientes
    ProfilePage(),         // Página de perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818), // Fondo oscuro
        title: const Text('Food App', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), // Ícono de comida
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),          // Ícono de búsqueda
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),        // Ícono de recetas guardadas
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),            // Ícono de lista de ingredientes
            label: 'Ingredientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),          // Ícono de perfil
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFDBC8EC), // Lavanda para el ítem seleccionado
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF181818), // Fondo oscuro
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
