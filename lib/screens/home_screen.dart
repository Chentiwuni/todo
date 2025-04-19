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

  void _reorderTasks(List<Task> tasks, int oldIndex, int newIndex) async {
  if (newIndex > oldIndex) newIndex -= 1;

  final movedTask = tasks.removeAt(oldIndex);
  tasks.insert(newIndex, movedTask);

  for (int i = 0; i < tasks.length; i++) {
    tasks[i].position = i;
    await _firestoreService.updateTask(tasks[i]);
  }
}


  void _toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    _firestoreService.updateTask(task);
  }

  void _confirmDeleteTask(Task task) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Task'),
      content: Text("Are you sure you want to delete '${task.title}'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            _firestoreService.deleteTask(task.id);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void _confirmDeleteCategory(String categoryName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Category'),
      content: Text(
        "Deleting '$categoryName' will remove all tasks under it. Are you sure?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            _firestoreService.deleteCategory(categoryName);
            if (_selectedCategory == categoryName) {
              setState(() => _selectedCategory = 'Personal');
            }
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}


  void _editTask(Task task) {
    final titleController = TextEditingController(text: task.title);
    final noteController = TextEditingController(text: task.note);
    DateTime? selectedDate = task.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Task", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Task Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Note"),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Due Date: ${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'None'}"),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    onPressed: () {
                      task.title = titleController.text.trim();
                      task.note = noteController.text.trim().isEmpty ? null : noteController.text.trim();
                      task.dueDate = selectedDate;
                      _firestoreService.updateTask(task);
                      Navigator.pop(context);
                    },
                    child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildTaskList(String category) {
  return StreamBuilder<List<Task>>(
    stream: _firestoreService.getTasks(category),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

      final tasks = snapshot.data!;
      final uncompleted = tasks.where((t) => !t.isCompleted).toList();
      final completed = tasks.where((t) => t.isCompleted).toList();

      return ListView(
        children: [
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              if (oldIndex >= uncompleted.length || newIndex > uncompleted.length) return;
              _reorderTasks(uncompleted, oldIndex, newIndex);
            },
            children: [
              for (var task in uncompleted)
                Card(
                  key: ValueKey(task.id),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text("Due: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : 'None'}"),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => _toggleTaskCompletion(task),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.note != null && task.note!.trim().isNotEmpty)
                          const Icon(Icons.note, color: Colors.blue),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteTask(task),
                        ),
                      ],
                    ),
                    onTap: () => _editTask(task),
                  ),
                ),
            ],
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Completed Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var task in completed)
            ListTile(
              title: Text(
                task.title,
                style: const TextStyle(decoration: TextDecoration.lineThrough),
              ),
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
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (FirebaseAuth.instance.currentUser!.email ?? '').split('@')[0],
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                          onPressed: () => _confirmDeleteCategory(cat),
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
        title: Text(
          _selectedCategory,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent, // Nice highlight color
            letterSpacing: 1.2,
          ),
        ),
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
