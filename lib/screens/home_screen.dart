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

  void _showAddCategoryDialog(BuildContext buildContext) {
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
  }

  void _deleteCategory(String category) {
    if (category != 'Personal') {
      var index = _categoryBox.values.toList().indexOf(category);
      if (index != -1) {
        _categoryBox.deleteAt(index);
        setState(() {
          if (_selectedCategory == category) _selectedCategory = 'Personal';
        });
      }
    }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do List")),
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
              title: const Text('Add Bucket'),
              onTap: () {
                _showAddCategoryDialog(context);
              },
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
                              onPressed: () => _deleteCategory(category),
                            ),
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
      body: Column(
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
                ValueListenableBuilder(
                  valueListenable: _categoryBox.listenable(),
                  builder: (context, Box<String> box, _) {
                    return DropdownButton<String>(
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: box.values.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _taskBox.listenable(),
              builder: (context, Box<Task> box, _) {
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final task = box.getAt(index);
                    if (task == null) return SizedBox.shrink();
                    return Card(
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text("Category: ${task.category}"),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => _toggleTaskCompletion(index),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.note != null && task.note!.isNotEmpty)
                              const Icon(Icons.note, color: Colors.blue), // Note icon
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                        onTap: () => _showTaskNoteEditor(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
