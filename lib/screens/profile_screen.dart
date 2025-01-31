import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tymczasowe dane użytkownika
    final String email = "example@domain.com";
    final String registrationDate = "2024-01-01";

    return Scaffold(
      appBar: AppBar(
        title: Text('Twój profil'),
        backgroundColor: Colors.brown[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard'); // Powrót do Dashboardu
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Obszar informacji użytkownika
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Adres e-mail
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Text(
                          email, // Tymczasowy e-mail
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Data rejestracji
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Text(
                          'Zarejestrowano: $registrationDate', // Tymczasowa data
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Przycisk edycji danych
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile-creator');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20.0), // Większe przyciski
                  minimumSize: Size(double.infinity, 60), // Pełna szerokość
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edytuj profil',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              // Przycisk wylogowania
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wylogowano')),
                  );
                  Navigator.pushReplacementNamed(context, '/login'); // Powrót do logowania
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 20.0), // Większe przyciski
                  minimumSize: Size(double.infinity, 60), // Pełna szerokość
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Wyloguj się',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
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
    );
  }
}
