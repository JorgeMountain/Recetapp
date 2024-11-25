class Recipe {
  String id;
  String title;
  String description;
  List<String> ingredients;
  List<String> steps;
  String portions;
  String time;
  String imageUrl;
  String userId; // Campo para almacenar el ID del usuario

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.portions,
    required this.time,
    required this.imageUrl,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'portions': portions,
      'time': time,
      'image': imageUrl,
      'userId': userId, // Incluye el userId en el JSON
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      portions: json['portions'],
      time: json['time'],
      imageUrl: json['image'],
      userId: json['userId'], // Recupera el userId del JSON
    );
  }
}
