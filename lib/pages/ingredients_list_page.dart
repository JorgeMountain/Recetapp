import 'package:flutter/material.dart';

class IngredientsListPage extends StatefulWidget {
  const IngredientsListPage({super.key});

  @override
  State<IngredientsListPage> createState() => _IngredientsListPageState();
}

class _IngredientsListPageState extends State<IngredientsListPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tus ingredientes'),
      ),
    );
  }
}
