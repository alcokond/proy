import 'package:cloud_firestore/cloud_firestore.dart';

class Denuncia {
  String id;
  String name;
  String category;
  String image;
  List guias = [];
  Timestamp createdAt;
  Timestamp updatedAt;

  Denuncia();

  Denuncia.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    category = data['category'];
    image = data['image'];
    guias = data['guias'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image': image,
      'guias': guias,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
