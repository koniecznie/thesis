import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _unit = 'szt.'; // Domyślna jednostka
  final CollectionReference _shoppingListCollection =
      FirebaseFirestore.instance.collection('shopping_list');
  final CollectionReference _pantryCollection =
      FirebaseFirestore.instance.collection('pantry');

  // Mapowanie wybranych produktów do przeniesienia
  Map<String, bool> _selectedItems = {};

  // Funkcja do dodawania pozycji na listę zakupów
  Future<void> _addShoppingItem(String name, int quantity, String unit) async {
    try {
      await _shoppingListCollection.add({
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produkt dodany do listy zakupów!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  // Funkcja do usuwania pozycji z listy zakupów
  Future<void> _deleteShoppingItem(String id) async {
    try {
      await _shoppingListCollection.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produkt usunięty z listy zakupów!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  // Funkcja do przenoszenia produktów do spiżarni
  Future<void> _moveToPantry(Map<String, dynamic> itemData, String id) async {
    try {
      // Dodajemy produkt do spiżarni z domyślną datą ważności, jeśli brak
      await _pantryCollection.add({
        'name': itemData['name'],
        'quantity': itemData['quantity'],
        'unit': itemData['unit'],
        'expirationDate': itemData.containsKey('expirationDate')
            ? itemData['expirationDate']
            : DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Usuwamy produkt z listy zakupów
      await _deleteShoppingItem(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produkt przeniesiony do spiżarni!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }


  // Dodanie nowej pozycji na listę zakupów (pop-up dialog)
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Dodaj produkt do listy zakupów',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nazwa produktu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Ilość',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: InputDecoration(
                    labelText: 'Jednostka',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['szt.', 'kg', 'l', 'g']
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _unit = value ?? 'szt.';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Anuluj'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final name = _nameController.text;
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                if (name.isNotEmpty && quantity > 0) {
                  _addShoppingItem(name, quantity, _unit);
                  _nameController.clear();
                  _quantityController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  // Widget do wyświetlania listy zakupów z checkboxami
  Widget _buildShoppingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _shoppingListCollection
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Błąd: ${snapshot.error}'));
        }
        final items = snapshot.data?.docs ?? [];
        return items.isEmpty
            ? Center(
                child: Text(
                  'Brak pozycji na liście zakupów.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final data = item.data() as Map<String, dynamic>;
                  final id = item.id;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Checkbox(
                        value: _selectedItems[id] ?? false,
                        onChanged: (checked) {
                          setState(() {
                            _selectedItems[id] = checked ?? false;
                          });
                        },
                      ),
                      title: Text(
                        data['name'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Ilość: ${data['quantity']} ${data['unit']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteShoppingItem(id),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista zakupów'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildShoppingList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Przykładowe dane do przeniesienia (możesz podać dynamicznie)
          final exampleData = {
            'name': 'Mąka',
            'quantity': 2,
            'unit': 'kg',
          };
          final documentId = 'exampleDocId'; // Przykładowe ID dokumentu

          _moveToPantry(exampleData, documentId);
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.check),
      ),

    );
  }
}
