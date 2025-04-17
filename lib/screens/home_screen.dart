import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCategory = 'Personal';
  DateTime? _selectedDueDate;

  void _addTask() async {
    if (_taskController.text.isNotEmpty) {
      final task = Task(
        id: '', // Will be set by Firestore
        title: _taskController.text.trim(),
        category: _selectedCategory,
        dueDate: _selectedDueDate,
      );
      await _firestoreService.addTask(task);
      _taskController.clear();
      _selectedDueDate = null;
    }
  }

  void _toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    _firestoreService.updateTask(task);
  }

  void _deleteTask(Task task) {
    _firestoreService.deleteTask(task.id);
  }

  void _editTask(Task task) {
    final noteController = TextEditingController(text: task.note);
    DateTime? selectedDate = task.dueDate;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit '${task.title}'", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: "Note")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Due: ${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'None'}"),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    task.note = noteController.text;
                    task.dueDate = selectedDate;
                    _firestoreService.updateTask(task);
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    task.note = null;
                    task.dueDate = null;
                    _firestoreService.updateTask(task);
                    Navigator.pop(context);
                  },
                  child: const Text("Clear Note", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(String category) {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.getTasks(category),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final tasks = snapshot.data!;
        final uncompleted = tasks.where((t) => !t.isCompleted).toList()
          ..sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));
        final completed = tasks.where((t) => t.isCompleted).toList();

        return ListView(
          children: [
            for (var task in uncompleted)
              Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text("Due: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : 'None'}"),
                  leading: Checkbox(value: task.isCompleted, onChanged: (_) => _toggleTaskCompletion(task)),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTask(task)),
                  onTap: () => _editTask(task),
                ),
              ),
            const Divider(),
            const Text("Completed Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
            for (var task in completed)
              ListTile(
                title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryDrawer() {
    return Drawer(
      child: StreamBuilder<List<String>>(
        stream: _firestoreService.getCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? ['Personal'];
          return ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white, radius: 30, child: Icon(Icons.person)),
                    const SizedBox(width: 10),
                    Text(FirebaseAuth.instance.currentUser!.email ?? '', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Add Category"),
                onTap: () {
                  final controller = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("New Category"),
                      content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Category")),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        TextButton(
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              _firestoreService.addCategory(controller.text.trim());
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Add"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              for (var cat in categories)
                ListTile(
                  title: Text(cat),
                  selected: _selectedCategory == cat,
                  trailing: cat == 'Personal'
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _firestoreService.deleteCategory(cat),
                        ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      drawer: _buildCategoryDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(labelText: "New Task"),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addTask),
              ],
            ),
          ),
          Expanded(child: _buildTaskList(_selectedCategory)),
        ],
      ),
    );
  }
}
