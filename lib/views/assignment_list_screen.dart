import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  
  final AssignmentPresenter _presenter = AssignmentPresenter();
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
      textController.dispose();
      super.dispose();
  }


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
                _presenter.addAssignment(newAssignmentTitle.trim());
                });
            }
            Navigator.pop(context); }, //close dialog
          
          child: const Text('Add'),) ]);});
          }


void _showEditAssignment(int index) {
  textController.text = _presenter.assignments[index].title;

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
                  _presenter.assignments[index].title = textController.text.trim();
                  });
              } 
              Navigator.pop(context);
            },
            child: const Text('Save'),)
    ]);
  });
}

@override
Widget build(BuildContext context) {
  final assignments = _presenter.assignments;

  return Scaffold(
    appBar: AppBar(title: const Text('Assignments')),
    body: ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return ListTile(
          title: Row(
            children: [
              Checkbox(
                value: assignment.isCompleted,
                onChanged: (value) {setState(() {_presenter.toggleCompleted(index); });
              }),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () => _showEditAssignment(index),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  assignment.title,
                  style: TextStyle(decoration: assignment.isCompleted
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
}}