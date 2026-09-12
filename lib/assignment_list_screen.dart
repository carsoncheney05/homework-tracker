import 'package:flutter/material.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  
  final List<Map<String, dynamic>> _assignments = [];


void _showAddAssignmentDialog() {
  String newAssignmentTitle = '';
  showDialog(
    context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Add Assignment'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter Assignment Title"),
          onChanged: (value) {
            newAssignmentTitle = value;
          },
        ),
        actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (newAssignmentTitle.trim().isNotEmpty) {
              setState(() {
                _assignments.add({
                  'title': newAssignmentTitle.trim(),
                  'completed': false,
                });
              });
            }
            Navigator.pop(context); //close dialog
          },
          child: const Text('Add'),
        ),
      ],
      );
    },
  );
}

void editAssignment(int index) {
  final TextEditingController textController = TextEditingController(
    text: _assignments[index]['title']
  );
  showDialog(
    context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Edit Assignment Title'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter Edited Assignment Name"),
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                setState(() {
                  _assignments[index]['title'] = textController.text.trim();
                  });
              } 
              Navigator.pop(context);
            },
            child: const Text('Save'),)
    ]);
  });
}

void _toggleCompleted(int index, bool? value) {
  setState(() {
    _assignments[index]['completed'] = value ?? false;
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Assignments')),
    body: ListView.builder(
      itemCount: _assignments.length,
      itemBuilder: (context, index) { 
        return ListTile(
          title: Row(
            children: [
              Checkbox(
                value: _assignments[index]['completed'],
                onChanged: (value) => _toggleCompleted(index, value),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () => editAssignment(index),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _assignments[index]['title'],
                  style: TextStyle(decoration: _assignments[index]['completed']
                      ? TextDecoration.lineThrough
                      : null,)
                ))
            ]
          )
        ); }
        ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddAssignmentDialog,
      child: const Icon(Icons.add),
      ),
    );
}
}