import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final List<Map<String, dynamic>> _posts = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _createPost() {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      setState(() {
        _posts.insert(0, {
          "title": _titleController.text,
          "description": _descriptionController.text,
          "image": _selectedImage,
          "likes": 0,
          "isSaved": false,
        });
        _titleController.clear();
        _descriptionController.clear();
        _selectedImage = null;
      });
      Navigator.pop(context);
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Crear Publicación",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Título",
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? "Ingrese un título" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? "Ingrese una descripción" : null,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
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
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6E6FA)),
                child: const Text("Publicar", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        title: const Text("Social", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreatePostDialog,
          ),
        ],
      ),
      body: _posts.isEmpty
          ? const Center(
        child: Text(
          "No hay publicaciones aún.",
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post, index);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    return Card(
      color: const Color(0xFF1C1C1C),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la publicación
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.file(
              post["image"],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la publicación
                Text(
                  post["title"],
                  style: const TextStyle(
                    color: Color(0xFFE6E6FA), // Color lavanda
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                // Descripción de la publicación
                Text(
                  post["description"],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Botones de "like" y guardar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: post["likes"] > 0 ? Colors.red : Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              post["likes"]++;
                            });
                          },
                        ),
                        Text(
                          "${post["likes"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        post["isSaved"] ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          post["isSaved"] = !post["isSaved"];
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
