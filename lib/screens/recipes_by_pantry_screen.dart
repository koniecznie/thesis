// lib/screens/recipes_by_pantry_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipesByPantryScreen extends StatefulWidget {
  final List<String> pantryIngredients; // Składniki z spiżarni

  RecipesByPantryScreen({required this.pantryIngredients});

  @override
  _RecipesByPantryScreenState createState() => _RecipesByPantryScreenState();
}

class _RecipesByPantryScreenState extends State<RecipesByPantryScreen> {
  final String apiKey = 'f2d464cac0c84828ba5b99a96ab214e8'; // Wstaw swój klucz API Spoonacular
  List recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipesByIngredients();
  }

  Future<void> fetchRecipesByIngredients() async {
    final ingredients = widget.pantryIngredients.join(',');
    final url =
        'https://api.spoonacular.com/recipes/findByIngredients?apiKey=$apiKey&ingredients=$ingredients&number=10';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          recipes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Przepisy z Twojej spiżarni'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
          ? const Center(child: Text('Nie znaleziono przepisów'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsScreen(
                    recipeId: recipe['id'],
                  ),
                ),
              );
            },
            child: _buildRecipeCard(recipe),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(dynamic recipe) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              recipe['image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              recipe['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailsScreen extends StatelessWidget {
  final int recipeId;

  const RecipeDetailsScreen({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły przepisu'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Szczegóły przepisu o ID: $recipeId'),
      ),
    );
  }
}
