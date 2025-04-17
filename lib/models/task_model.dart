import 'package:cloud_firestore/cloud_firestore.dart';


class Task {
  String id;
  String title;
  bool isCompleted;
  String category;
  String? note;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.category,
    this.note,
    this.dueDate,
  });

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? 'Personal',
      note: map['note'],
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
      'note': note,
      'dueDate': dueDate,
    };
  }
}
