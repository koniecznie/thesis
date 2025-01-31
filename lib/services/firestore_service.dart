import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Dodanie danych do kolekcji 'users'
  void addData() {
    firestore.collection('users').add({
      'name': 'Julia',
      'age': 25,
      'email': 'julia@example.com',
    }).then((value) {
      print('User added: ${value.id}');
    }).catchError((error) {
      print('Failed to add user: $error');
    });
  }

  // Odczytanie danych z kolekcji 'users'
  void fetchData() {
    firestore.collection('users').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print('User: ${doc['name']}, Age: ${doc['age']}, Email: ${doc['email']}');
      });
    }).catchError((error) {
      print('Failed to fetch data: $error');
    });
  }
}
