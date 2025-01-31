import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantryScreen extends StatefulWidget {
  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final CollectionReference _pantryCollection =
  FirebaseFirestore.instance.collection('pantry');

  // Funkcja do dodania produktu do Firestore
  Future<void> _addPantryItem(
      String name, int quantity, String unit, DateTime expirationDate) async {
    try {
      await _pantryCollection.add({
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'expirationDate': expirationDate.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produkt dodany do spiżarni!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  // Funkcja do pobierania danych z Firestore
  Stream<QuerySnapshot> _getPantryItems() {
    return _pantryCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // Funkcja do usuwania produktu
  Future<void> _deletePantryItem(String id) async {
    try {
      await _pantryCollection.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produkt usunięty!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  // Dodanie nowego produktu (pop-up dialog)
  void _showAddItemDialog() {
    DateTime _selectedDate = DateTime.now();
    String _unit = 'szt.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Dodaj produkt',
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
                  items: ['kg', 'szt.', 'l', 'g']
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
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Text(
                    'Data ważności: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
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
                backgroundColor: Colors.brown[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final name = _nameController.text;
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                if (name.isNotEmpty && quantity > 0) {
                  _addPantryItem(name, quantity, _unit, _selectedDate);
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

  // Widget do wyświetlania danych
  Widget _buildPantryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPantryItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Błąd: ${snapshot.error}'));
        }

        final items = snapshot.data?.docs ?? [];
        print('Dane z Firestore: ${snapshot.data?.docs}'); // Debug danych

        return items.isEmpty
            ? Center(
          child: Text(
            'Brak produktów w spiżarni.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final data = item.data() as Map<String, dynamic>;

            final name = data['name'] ?? 'Brak nazwy';
            final quantity = data['quantity'] ?? 0;
            final unit = data['unit'] ?? 'szt.';
            final expirationDate = data['expirationDate'] != null
                ? DateTime.parse(data['expirationDate'])
                : DateTime.now().add(const Duration(days: 7));

            // Debugowanie braków pól
            if (!data.containsKey('name')) print('Brak pola name w dokumencie: ${item.id}');
            if (!data.containsKey('quantity')) print('Brak pola quantity w dokumencie: ${item.id}');
            if (!data.containsKey('unit')) print('Brak pola unit w dokumencie: ${item.id}');
            if (!data.containsKey('expirationDate')) print('Brak pola expirationDate w dokumencie: ${item.id}');

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.brown.shade100,
                  child: Icon(Icons.kitchen, color: Colors.brown),
                ),
                title: Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Ilość: $quantity $unit\n'
                      'Data ważności: ${expirationDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePantryItem(item.id),
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
        title: Text('Spiżarnia'),
        backgroundColor: Colors.brown,
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
            colors: [Colors.brown.shade100, Colors.brown.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildPantryList(),
      ),
    );
  }
}
