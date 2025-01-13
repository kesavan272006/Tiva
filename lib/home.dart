import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'todo_service.dart';  // Import the TodoService
import 'about.dart';  // Import the About Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoService _todoService = TodoService();
  List<Map<String, dynamic>> _todos = [];
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Load all Todos from Firestore
  Future<void> _loadTodos() async {
    List<Map<String, dynamic>> todos = await _todoService.fetchTodos();
    setState(() {
      _todos = todos;
    });
  }

  // Update Todo status
  Future<void> _updateTodoStatus(String todoText, bool isDone) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      String userId = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('todoText', isEqualTo: todoText)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update({'isDone': isDone});
        _loadTodos();  // Reload Todos after updating
      }
    } catch (e) {
      print("Error updating todo: $e");
    }
  }

  // Delete Todo item
  Future<void> _deleteTodoItem(String todoText) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      String userId = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('todoText', isEqualTo: todoText)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.delete();
        _loadTodos();  // Reload Todos after deleting
      }
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }

  // Add new Todo
  Future<void> _addNewTodo() async {
    final String todoText = _todoController.text.trim();
    if (todoText.isEmpty) return;

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }
      String userId = user.uid;

      await FirebaseFirestore.instance.collection('todos').add({
        'todoText': todoText,
        'isDone': false,
        'userId': userId,
        'createdAt': Timestamp.now(),
      });

      _todoController.clear();  // Clear input after adding
      _loadTodos();  // Reload Todos after adding
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Todos",
          style: TextStyle(color: Colors.pink),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.pink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const About()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.pink),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9C27B0),
              Color(0xFF6200EA),
              Color(0xFF304FFE),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _todos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _todos[index]['todoText'],
                            style: TextStyle(
                              decoration: _todos[index]['isDone']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: Colors.pink,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _todos[index]['isDone'],
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    _updateTodoStatus(
                                      _todos[index]['todoText'],
                                      value,
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.pink),
                                onPressed: () {
                                  _deleteTodoItem(_todos[index]['todoText']);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a new task...',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white30,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.pink, size: 30),
                    onPressed: _addNewTodo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
