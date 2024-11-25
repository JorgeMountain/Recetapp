import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _portionsController = TextEditingController();
  final _timeController = TextEditingController();

  List<String> ingredients = [''];
  List<String> steps = [''];
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate() &&
        _selectedImage != null &&
        ingredients.isNotEmpty &&
        steps.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Subir imagen a Firebase Storage
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('posts/${DateTime.now().toIso8601String()}.jpg');
        await imageRef.putFile(_selectedImage!);
        final imageUrl = await imageRef.getDownloadURL();

        // Guardar datos en Firestore
        await FirebaseFirestore.instance.collection('posts').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'ingredients': ingredients.where((ingredient) => ingredient.isNotEmpty).toList(),
          'steps': steps.where((step) => step.isNotEmpty).toList(),
          'portions': _portionsController.text,
          'time': _timeController.text,
          'image': imageUrl,
          'likes': 0,
          'isSaved': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Limpiar campos
        _titleController.clear();
        _descriptionController.clear();
        _portionsController.clear();
        _timeController.clear();
        ingredients = [''];
        steps = [''];
        _selectedImage = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta publicada con éxito.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar receta: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF1C1C1C),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_titleController, 'Título de la receta'),
                        const SizedBox(height: 10),
                        _buildTextField(_descriptionController, 'Descripción'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_portionsController, 'Porciones')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(_timeController, 'Tiempo (min)')),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Ingredientes dinámicos
                        const Text(
                          'Ingredientes:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        _buildDynamicList(
                          context: context,
                          items: ingredients,
                          placeholder: 'Nuevo ingrediente',
                          onAdd: () => setState(() => ingredients.add('')),
                          onRemove: (index) => setState(() => ingredients.removeAt(index)),
                          onChange: (index, value) => setState(() => ingredients[index] = value),
                        ),

                        // Pasos dinámicos
                        const SizedBox(height: 10),
                        const Text(
                          'Pasos:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        _buildDynamicList(
                          context: context,
                          items: steps,
                          placeholder: 'Nuevo paso',
                          onAdd: () => setState(() => steps.add('')),
                          onRemove: (index) => setState(() => steps.removeAt(index)),
                          onChange: (index, value) => setState(() => steps[index] = value),
                        ),

                        // Imagen de la receta
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _selectedImage == null
                                ? const Icon(Icons.add_a_photo, color: Colors.white)
                                : Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6FA),
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Publicar', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? 'Por favor ingresa $label' : null,
    );
  }

  Widget _buildDynamicList({
    required BuildContext context,
    required List<String> items,
    required String placeholder,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Function(int, String) onChange,
  }) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => onChange(i, value),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(i),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF181818)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: Column(
        children: [
          GestureDetector(
            onTap: _showCreatePostDialog,
            child: Card(
              color: const Color(0xFF1C1C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Agregar Receta',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Aquí irían las publicaciones (puedes reutilizar el sistema de tarjetas)
        ],
      ),
    );
  }
}
