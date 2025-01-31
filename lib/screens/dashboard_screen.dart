import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'recipes_by_pantry_screen.dart'; // Import ekranu przepisów

class DashboardScreen extends StatelessWidget {
  Future<List<String>> fetchPantryIngredients() async {
    final pantrySnapshot =
        await FirebaseFirestore.instance.collection('pantry').get();
    return pantrySnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  void openRecipesByPantry(BuildContext context) async {
    final ingredients = await fetchPantryIngredients();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipesByPantryScreen(
          pantryIngredients: ingredients,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFFFFF), // Białe tło
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nagłówek
                const Text(
                  'Dawaj, dawaj, bo przepisy uciekają',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Siatka opcji
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Przycisk do Spiżarni
                    _buildDashboardCard(
                      context: context,
                      title: 'Spiżarnia',
                      routeName: '/pantry',
                      illustrationPath: 'assets/pantry_illustration.png',
                    ),
                    // Przycisk do Listy Zakupów
                    _buildDashboardCard(
                      context: context,
                      title: 'Lista Zakupów',
                      routeName: '/shopping-list',
                      illustrationPath: 'assets/shopping_list_illustration.png',
                    ),
                    // Przycisk do Profilu
                    _buildDashboardCard(
                      context: context,
                      title: 'Profil',
                      routeName: '/profile',
                      illustrationPath: 'assets/profile_illustration.png',
                    ),
                    // Przycisk do Przepisów
                    _buildDashboardCard(
                      context: context,
                      title: 'Przepisy',
                      routeName: '/recipes',
                      illustrationPath: 'assets/recipes_illustration.png',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Stopka
                Text(
                  '©2024 Bąbel Company',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funkcja do budowania kart na Dashboard
  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String routeName,
    required String illustrationPath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Ilustracja
            Image.asset(
              illustrationPath,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            // Tytuł
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
