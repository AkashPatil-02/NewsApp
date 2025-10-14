import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class UserDatabase {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://newsapp-c9665-default-rtdb.asia-southeast1.firebasedatabase.app/',
  );

  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _db.ref().child(path);
    await ref.set(data);
  }

  Future<DataSnapshot?> read({required String path}) async {
    final DatabaseReference ref = _db.ref().child(path);
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  Future<void> delete({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _db.ref().child(path);
    await ref.remove();
  }

  Future<void> saveNews({required String path, required List data}) async {
    final DatabaseReference ref = _db.ref().child(path);
    await ref.set(data);
  }
}
