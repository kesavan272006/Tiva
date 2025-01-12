import 'package:flutter/material.dart';
import '../model/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String, bool) onToDoChanged;
  final Function(String) onDeleteItem;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
      child: Card(
        color: Colors.deepPurple,
        margin: EdgeInsets.symmetric(vertical: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          onTap: () {
            onToDoChanged(todo.id, todo.isDone);
          },
          leading: Icon(
            todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: todo.isDone ? Colors.green : Colors.red,
            size: 30,
          ),
          title: Text(
            todo.todoText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              onDeleteItem(todo.id);
            },
            color: Colors.red,
            icon: Icon(Icons.delete, size: 30),
          ),
        ),
      ),
    );
  }
}
