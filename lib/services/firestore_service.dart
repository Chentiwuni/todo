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
      .orderBy('position') // 🔥 this enables ordering
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList());
}

  Future<void> ensureDefaultCategory() async {
  final docRef = _db
      .collection('users')
      .doc(_uid)
      .collection('categories')
      .doc('Personal');

  final doc = await docRef.get();
  if (!doc.exists) {
    await docRef.set({});
  }
}


Future<void> addTask(Task task) {
  final taskData = task.toMap();
  taskData['reminderSent'] = false; // Add this flag to track notification

  return _db
      .collection('users')
      .doc(_uid)
      .collection('tasks')
      .add(taskData);
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
