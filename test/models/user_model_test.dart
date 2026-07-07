import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: Change 'touristique_guid' if your Flutter project name is different in pubspec.yaml
import 'package:touristique_guid/models/user_model.dart'; 

void main() {
  group('UserModel Tests', () {
    test('toMap() convertit correctement', () {
      final user = UserModel(
        uid: 'test123',
        name: 'Ahmed Bennani',
        email: 'ahmed@example.com',
        photoURL: 'https://example.com/photo.jpg',
        createdAt: Timestamp.now(),
      );
      
      final map = user.toMap();
      
      expect(map['uid'], equals('test123'));
      expect(map['name'], equals('Ahmed Bennani'));
    });
    
    test('fromMap() reconstruit correctement', () {
      final map = {
        'uid': 'test456',
        'name': 'Fatima Zahra',
        'email': 'fatima@example.com',
      };
      
      final user = UserModel.fromMap(map);
      
      expect(user.uid, equals('test456'));
      expect(user.name, equals('Fatima Zahra'));
    });
  });
}