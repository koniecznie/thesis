import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:image_picker/image_picker.dart'; // Dla zdjęć użytkownika

class ProfileCreatorScreen extends StatefulWidget {
  @override
  _ProfileCreatorScreenState createState() => _ProfileCreatorScreenState();
}

class _ProfileCreatorScreenState extends State<ProfileCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _age = 0;
  String _gender = 'Mężczyzna';
  String _goal = 'Redukcja masy ciała';
  List<String> _dietPreferences = [];
  List<String> _allergies = [];
  List<String> _dislikes = []; // Nowe pole: czego użytkownik nie lubi
  String? _avatarPath;

  // Preferencje użytkownika
  final List<String> goals = [
    'Redukcja masy ciała',
    'Utrzymanie wagi',
    'Budowa masy mięśniowej',
  ];
  final List<String> genders = ['Mężczyzna', 'Kobieta', 'Inne'];
  final List<String> dietOptions = ['Wegańska', 'Wegetariańska', 'Bezglutenowa', 'Niskokaloryczna'];
  final List<String> allergyOptions = ['Brak laktozy', 'Orzechy', 'Gluten', 'Miód'];

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatarPath = pickedImage.path;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Zapis do Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'name': _name,
        'age': _age,
        'gender': _gender,
        'goal': _goal,
        'dietPreferences': _dietPreferences,
        'allergies': _allergies,
        'dislikes': _dislikes,
        'avatarPath': _avatarPath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil został zapisany!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreator profilu'),
        backgroundColor: Colors.brown[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imię
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Imię',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Proszę podać imię' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              // Wiek
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Wiek',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Proszę podać wiek';
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) return 'Proszę podać poprawny wiek';
                  return null;
                },
                onSaved: (value) => _age = int.parse(value!),
              ),
              const SizedBox(height: 16),
              // Płeć
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Płeć',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _gender,
                items: genders
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 16),
              // Cel
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Cel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _goal,
                items: goals
                    .map((goal) => DropdownMenuItem(value: goal, child: Text(goal)))
                    .toList(),
                onChanged: (value) => setState(() => _goal = value!),
              ),
              const SizedBox(height: 16),
              // Preferencje żywieniowe
              const Text('Preferencje żywieniowe', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: dietOptions.map((diet) {
                  return FilterChip(
                    label: Text(diet),
                    selected: _dietPreferences.contains(diet),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _dietPreferences.add(diet)
                            : _dietPreferences.remove(diet);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Alergie
              const Text('Alergie', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: allergyOptions.map((allergy) {
                  return FilterChip(
                    label: Text(allergy),
                    selected: _allergies.contains(allergy),
                    onSelected: (selected) {
                      setState(() {
                        selected ? _allergies.add(allergy) : _allergies.remove(allergy);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Czego nie lubisz
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50, // Delikatny pomarańczowy kolor tła
                  border: Border.all(color: Colors.brown.shade200), // Obramowanie
                  borderRadius: BorderRadius.circular(12), // Zaokrąglone rogi
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tytuł sekcji
                    const Text(
                      'A teraz przyznaj, co zostaje na talerzu?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pole do wprowadzania tekstu
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Np. imbir, brokuły, oliwki...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        setState(() {
                          if (value.isNotEmpty) _dislikes.add(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Wyświetlanie listy dodanych elementów w formie Chipów
                    Wrap(
                      spacing: 10,
                      children: _dislikes.map((dislike) {
                        return Chip(
                          label: Text(dislike),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            setState(() => _dislikes.remove(dislike));
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Wgraj zdjęcie
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Nie wstydź się - pokaż nam jak wyglądasz 🤭 '),
                onPressed: _pickAvatar,
              ),
              if (_avatarPath != null) Image.file(File(_avatarPath!), height: 500),
              const SizedBox(height: 25),
              // Zapisz profil
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Zapisz profil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
