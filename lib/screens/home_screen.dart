import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   final TextEditingController _taskController = TextEditingController();

  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final Box<String> _categoryBox = Hive.box<String>('categories');

  String _selectedCategory = 'Personal';
  
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final task = Task(title: _taskController.text, category: _selectedCategory);
      _taskBox.add(task);
      _taskController.clear();
      setState(() {});
    }
  }

  void _toggleTaskCompletion(int index) {
    final task = _taskBox.getAt(index);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      _taskBox.putAt(index, task);
      setState(() {});
    }
  }

  void _deleteTask(int index) {
    _taskBox.deleteAt(index);
    setState(() {});
  }

  void _showTaskNoteEditor(int index) {
  final task = _taskBox.getAt(index);
  if (task == null) return;

  TextEditingController noteController = TextEditingController(text: task.note);

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit Note for '${task.title}'", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Task Note"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    task.note = noteController.text;
                    _taskBox.putAt(index, task);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text("Save"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    task.note = null;
                    _taskBox.putAt(index, task);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text("Delete Note", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  List<Task> _getFilteredTasks() {
    List<Task> tasks = _taskBox.values.where((task) => task.category == _selectedCategory).toList();

    List<Task> uncompletedTasks = tasks.where((task) => !task.isCompleted).toList();
    List<Task> completedTasks = tasks.where((task) => task.isCompleted).toList();

    return [...uncompletedTasks, ...completedTasks]; // Uncompleted first, completed last
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    List<Task> tasks = _getFilteredTasks();

    // Ignore completed tasks, only reorder uncompleted ones
    int uncompletedCount = tasks.where((task) => !task.isCompleted).length;
    if (oldIndex >= uncompletedCount || newIndex >= uncompletedCount) return;

    Task movedTask = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, movedTask);

    // Save reordered tasks back to Hive
    for (int i = 0; i < tasks.length; i++) {
      _taskBox.putAt(i, tasks[i]);
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(" $_selectedCategory", style: const TextStyle(
        color: Colors.green, fontWeight: FontWeight.bold,
      ),
      ),),),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(width: 10),
                  Text("Ibrahim", style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Bucket"),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: () {
                  TextEditingController categoryController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Add New Category"),
                        content: TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(hintText: "Enter category name"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              String newCategory = categoryController.text.trim();
                              if (newCategory.isNotEmpty && !_categoryBox.values.contains(newCategory)) {
                                _categoryBox.add(newCategory);
                                setState(() {});
                              }
                              Navigator.pop(context);
                            },
                            child: const Text("Add"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _categoryBox.listenable(),
              builder: (context, Box<String> box, _) {
                return Column(
                  children: box.values.map((category) {
                    return ListTile(
                      title: Text(category),
                      trailing: category == 'Personal'
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (_selectedCategory == category) {
                                  setState(() {
                                    _selectedCategory = 'Personal';
                                  });
                                }
                                int index = box.values.toList().indexOf(category);
                                if (index != -1) {
                                  box.deleteAt(index);
                                  setState(() {});
                                }
                              },
                            ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                );
              },
            ),
             const Divider(),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {}, 
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          final tasks = _getFilteredTasks();
          final uncompletedTasks = tasks.where((task) => !task.isCompleted).toList();
          final completedTasks = tasks.where((task) => task.isCompleted).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(labelText: "New Task"),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTask,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        onReorder: _reorderTasks,
                        itemCount: uncompletedTasks.length,
                        itemBuilder: (context, index) {
                          final task = uncompletedTasks[index];

                          return Card(
                            key: ValueKey(task.title),
                            child: ListTile(
                              title: Text(task.title),
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) => _toggleTaskCompletion(_taskBox.values.toList().indexOf(task)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (task.note != null && task.note!.isNotEmpty)
                                    const Icon(Icons.note, color: Colors.blue),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteTask(_taskBox.values.toList().indexOf(task)),
                                  ),
                                ],
                              ),
                              onTap: () => _showTaskNoteEditor(_taskBox.values.toList().indexOf(task)),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    const Text("Completed Tasks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          final task = completedTasks[index];

                          return Card(
                            child: ListTile(
                              title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
