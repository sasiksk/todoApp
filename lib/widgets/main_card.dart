import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/data/databasehelper.dart';
import 'package:todolist/model/to_do_list.dart';
import 'package:todolist/screen/UpdateScreen.dart';

class todocard extends StatefulWidget {
  const todocard({
    Key? key,
    required this.l1,
    required this.onUpdate, // Add this line
  }) : super(key: key);

  final ToDoList l1;
  final void Function() onUpdate; // Add this line

  @override
  State<todocard> createState() => _TodoCardState();
}

class _TodoCardState extends State<todocard> {
  bool _isChecked = false;

  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 100), // Set a maximum height
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Animation duration
        decoration: BoxDecoration(
          color: _isChecked ? Colors.grey.shade200 : Colors.white, // Card color
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 90,
          child: Card(
            color: Colors.teal.shade100,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                            _showUpdateStatusDialog();
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    toTitleCase(widget.l1.tododetails),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: _isChecked
                                        ? const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.red,
                                            fontSize: 16)
                                        : const TextStyle(
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 2, 1, 41),
                                            fontWeight: FontWeight.w100),
                                  ),
                                ),
                                Text(
                                  'Due: ${widget.l1.date != null ? DateFormat('MMM dd, yyyy').format(widget.l1.date!) : 'No due date'}',
                                  overflow: TextOverflow.ellipsis,
                                  style: _isChecked
                                      ? const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.red,
                                        )
                                      : const TextStyle(
                                          color: Color.fromARGB(255, 2, 1, 41)),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => UpdateToDo(
                                          existingToDo: widget.l1,
                                        ),
                                      ),
                                    )
                                        .then((_) {
                                      widget
                                          .onUpdate(); // Call the callback after update
                                    });
                                  },
                                  icon:
                                      const Icon(Icons.drag_indicator_rounded),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Status: ${widget.l1.status}',
                        style: TextStyle(
                          color: widget.l1.status == 'Completed'
                              ? Colors.green
                              : Colors.black,
                          decoration: _isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(_isChecked ? 'Mark as Not Completed' : 'Mark as Completed'),
          content: const Text('Do you want to update the status?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _updateStatus();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isChecked = !_isChecked; // Toggle the checkbox back
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus() async {
    await DatabaseHelper.updateToDoStatus(widget.l1.tid, _isChecked);
    widget.onUpdate(); // Call the callback after updating status
    if (_isChecked) {
      // If status is completed, turn off the notification
    }
  }
}
