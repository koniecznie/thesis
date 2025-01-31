import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_chef/screens/dashboard_screen.dart';
import 'package:smart_chef/screens/login_screen.dart';
import 'package:smart_chef/screens/pantry_screen.dart';
import 'package:smart_chef/screens/profile_creator_screen.dart';
import 'package:smart_chef/screens/profile_screen.dart';
import 'package:smart_chef/screens/recipes_by_pantry_screen.dart';
import 'package:smart_chef/screens/recipes_screen.dart';
import 'package:smart_chef/screens/register_screen.dart';
import 'package:smart_chef/screens/shopping_list_screen.dart';
import 'package:smart_chef/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Chef',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/profile': (context) => ProfileScreen(),
        '/profile-creator': (context) => ProfileCreatorScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/pantry': (context) => PantryScreen(),
        '/shopping-list': (context) => ShoppingListScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/recipes': (context) => RecipesScreen(),
        '/recipes-by-pantry': (context) => RecipesByPantryScreen(
              pantryIngredients: [], // W przyszłości dynamicznie podajemy składniki
            ),
      },
    );
  }
}
