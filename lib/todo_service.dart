import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch todos for the current user
  Future<List<Map<String, dynamic>>> fetchTodos() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final userId = user.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'todoText': doc['todoText'],
                'isDone': doc['isDone'],
                'userId': doc['userId'],
              })
          .toList();
    } catch (e) {
      print("Error fetching todos: $e");
      return [];
    }
  }

  // Add a new todo
  Future<void> addTodo(String todoText) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final userId = user.uid;
      await FirebaseFirestore.instance.collection('todos').add({
        'todoText': todoText,
        'isDone': false,
        'userId': userId,
      });
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  // Update the status of a todo
  Future<void> updateTodoStatus(String todoText, bool isDone) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;
      String userId = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('todoText', isEqualTo: todoText)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update({'isDone': isDone});
        print('Todo updated successfully');
      }
    } catch (e) {
      print("Error updating todo: $e");
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String todoText) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      String userId = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('todoText', isEqualTo: todoText)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.delete();
        print('Todo deleted successfully');
      }
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }
}
