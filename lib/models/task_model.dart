import 'package:cloud_firestore/cloud_firestore.dart';



<<<<<<< HEAD
class Task {
  String id;
  String title;
  bool isCompleted;
  String category;
  String? note;
=======
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  String category;

  @HiveField(4)
  String? note;

  @HiveField(5)
>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.category,
    this.note,
    this.dueDate,
  });

<<<<<<< HEAD
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
=======
  Map<String, dynamic> toMap() {
    return {
      'id': id,
>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
      'note': note,
<<<<<<< HEAD
      'dueDate': dueDate,
    };
  }
=======
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'],
      note: map['note'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424
}
