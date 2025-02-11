import 'dart:typed_data';

class Product {
  final int id;
  final String designation;
  final int prix;
  final Uint8List photo;
  final String marque;
  final String categorie;

  Product({
    required this.id,
    required this.designation,
    required this.prix,
    required this.photo,
    required this.marque,
    required this.categorie,
  });
}


