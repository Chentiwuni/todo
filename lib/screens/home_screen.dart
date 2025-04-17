import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
<<<<<<< HEAD
import '../services/firestore_service.dart';
=======
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';

>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  final _taskController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final String _selectedCategory = 'Personal';
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
    firestoreService.deleteTask(task.id);
=======
final FirestoreService firestoreService = FirestoreService();
final uuid = Uuid();

   final TextEditingController taskController = TextEditingController();
  final Box<Task> taskBox = Hive.box<Task>('tasks');
  final Box<String> categoryBox = Hive.box<String>('categories');
  String selectedCategory = 'Personal';
  DateTime? selectedDueDate;

void addTask() {
  if (taskController.text.isNotEmpty) {
    final task = Task(
      id: uuid.v4(),
      title: taskController.text,
      category: selectedCategory,
      dueDate: selectedDueDate,
    );
    taskBox.add(task);
    firestoreService.addTask(task); // 🔄 sync to Firestore
    taskController.clear();
    selectedDueDate = null;
    setState(() {});
>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424
  }
}

void toggleTaskCompletion(int index) {
  final task = taskBox.getAt(index);
  if (task != null) {
    task.isCompleted = !task.isCompleted;
    taskBox.putAt(index, task);
    firestoreService.updateTask(task);
    setState(() {});
  }
}

void deleteTask(int index) {
  final task = taskBox.getAt(index);
  if (task != null) {
    firestoreService.deleteTask(task.id);
  }
  taskBox.deleteAt(index);
  setState(() {});
}

  void editTask(Task task) {
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
                    firestoreService.updateTask(task);
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
                    firestoreService.updateTask(task);
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

  Widget buildTaskList(String category) {
    return StreamBuilder<List<Task>>(
      stream: firestoreService.getTasks(category),
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
                  leading: Checkbox(value: task.isCompleted, onChanged: (_) => toggleTaskCompletion(task)),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteTask(task)),
                  onTap: () => editTask(task),
                ),
              ),
<<<<<<< HEAD
            const Divider(),
            const Text("Completed Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
            for (var task in completed)
              ListTile(
                title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
=======
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      task.note = noteController.text.trim().isEmpty ? null : noteController.text;
                      task.dueDate = selectedDate;
                      _taskBox.putAt(index, task);
                      _firestoreService.updateTask(task);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text("Save"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      task.note = null;
                      task.dueDate = null;
                      _taskBox.putAt(index, task);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text("Delete Note", style: TextStyle(color: Colors.white)),
                  ),
                ],
>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424
              ),
          ],
        );
      },
    );
  }

  Widget buildCategoryDrawer() {
    return Drawer(
      child: StreamBuilder<List<String>>(
        stream: firestoreService.getCategories(),
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
                              firestoreService.addCategory(controller.text.trim());
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
                  selected: selectedCategory == cat,
                  trailing: cat == 'Personal'
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => firestoreService.deleteCategory(cat),
                        ),
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                    });
                    Navigator.pop(context);
                  },
                ),
<<<<<<< HEAD
=======
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final usedIds = <String>{}; // ✅ Declare locally before list building

                          return ReorderableListView.builder(
                            onReorder: _reorderTasks,
                            itemCount: uncompletedTasks.length,
                            itemBuilder: (context, index) {
                              final task = uncompletedTasks[index];
                              bool isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now());

                              return Card(
                                key: usedIds.add(task.id) ? ValueKey(task.id) : UniqueKey(), // ✅ Unique key
                                color: isOverdue ? Colors.red.shade100 : null,
                                child: ListTile(
                                  title: Text(task.title),
                                  subtitle: Text("Due: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : 'No due date'}"),
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) => toggleTaskCompletion(taskBox.values.toList().indexOf(task)),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (task.note != null && task.note!.isNotEmpty)
                                        const Icon(Icons.note, color: Colors.blue),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => deleteTask(taskBox.values.toList().indexOf(task)),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showTaskEditor(taskBox.values.toList().indexOf(task)),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    const Text("Completed Tasks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    Expanded(child: ListView(children: completedTasks.map((task) => ListTile(title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough)))).toList())),
                  ],
                ),
              ),
>>>>>>> f03a1efa4bc8471927278780ec3e10633d272424
            ],
          )
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      drawer: buildCategoryDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(labelText: "New Task"),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: addTask),
              ],
            ),
          ),
          Expanded(child: buildTaskList(selectedCategory)),
        ],
      ),
    );
  }
}
