import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'tasks';

  Future<void> addTask(Task task) async {
    await _firestore.collection(collection).doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection(collection).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  Future<List<Task>> fetchAllTasks() async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }
}
