import 'package:flutter/material.dart';
import 'package:recetapp/pages/food_home_page.dart';
import 'package:recetapp/pages/ingredients_list_page.dart';
import 'package:recetapp/pages/profile_page.dart';
import 'package:recetapp/pages/search_page.dart';
import 'package:recetapp/pages/social_page.dart'; // Nueva página Social

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Ahora 4 tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF333333), // Fondo oscuro
          title: const Text(
            'Food App',
            style: TextStyle(color: Colors.white), // Texto blanco
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE6E6FA), // Color de la pestaña activa (Lavanda)
            indicatorWeight: 3.0,
            labelColor: Color(0xFFE6E6FA), // Color del texto de la pestaña activa
            unselectedLabelColor: Colors.white70, // Color del texto de pestañas inactivas
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Inicio'), // FoodHomePage
              Tab(icon: Icon(Icons.search), text: 'Buscar'),          // SearchPage
              Tab(icon: Icon(Icons.people), text: 'Social'),          // Nueva pestaña Social
              Tab(icon: Icon(Icons.list), text: 'Ingredientes'),      // IngredientsListPage
              Tab(icon: Icon(Icons.person), text: 'Perfil'),          // ProfilePage
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FoodHomePage(),        // Página principal de comidas
            SearchPage(),          // Página de búsqueda
            SocialPage(),          // Nueva página Social
            IngredientsListPage(), // Página de lista de ingredientes
            ProfilePage(),         // Página de perfil
          ],
        ),
      ),
    );
  }
}
