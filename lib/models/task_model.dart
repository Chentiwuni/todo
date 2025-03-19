import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String category;

  @HiveField(3)
  String? note; 

  Task({required this.title, this.isCompleted = false, required this.category, this.note});
}
