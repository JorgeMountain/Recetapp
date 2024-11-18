import 'package:flutter/material.dart';
import 'package:recetapp/pages/food_home_page.dart';
import 'package:recetapp/pages/ingredients_list_page.dart';
import 'package:recetapp/pages/profile_page.dart';
import 'package:recetapp/pages/search_page.dart';
import 'package:recetapp/pages/social_page.dart';

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
    SocialPage(),          // Página social
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
      backgroundColor: Colors.black, // Fondo oscuro
      body: _widgetOptions[_selectedIndex], // Página seleccionada
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF181818), // Fondo oscuro
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), // Bordes redondeados
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
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
              icon: Icon(Icons.people),          // Ícono para Social
              label: 'Social',
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
          selectedItemColor: const Color(0xFFE6E6FA), // Lavanda para ítem seleccionado
          unselectedItemColor: Colors.white70,        // Gris para ítems no seleccionados
          backgroundColor: Colors.transparent,        // Fondo transparente para usar el diseño del contenedor
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0, // Sin sombra adicional
        ),
      ),
    );
  }
}
