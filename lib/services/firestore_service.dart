import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // 📄 Tasks
  Stream<List<Task>> getTasks(String category) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTask(Task task) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> updateTask(Task task) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String taskId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // 🗂️ Categories
  Stream<List<String>> getCategories() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> addCategory(String categoryName) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .doc(categoryName)
        .set({});
  }

  Future<void> deleteCategory(String categoryName) async {
    final tasks = await _db
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .where('category', isEqualTo: categoryName)
        .get();

    for (var doc in tasks.docs) {
      await doc.reference.delete();
    }

    await _db
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .doc(categoryName)
        .delete();
  }
}
