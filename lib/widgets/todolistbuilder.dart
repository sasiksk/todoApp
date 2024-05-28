import 'package:flutter/material.dart';
import 'package:todolist/model/to_do_list.dart';
import 'package:todolist/widgets/main_card.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class ToDoListWidget extends StatefulWidget {
  const ToDoListWidget({
    Key? key,
    required this.regList,
    required this.onUpdate,
  }) : super(key: key);

  final void Function() onUpdate;
  final List<ToDoList> regList;

  @override
  State<ToDoListWidget> createState() => _ToDoListWidgetState();
}

class _ToDoListWidgetState extends State<ToDoListWidget> {
  ToDoList? _dismissedItem;
  int? _remindex;
  bool _deleteScheduled = false;
  bool _undoPressed = false;
  // Flag to track if undo action is pressed

  void _deleteItemFromDB(int id) async {
    try {
      final dbPath = await sql.getDatabasesPath();
      final db = await sql.openDatabase(path.join(dbPath, 'todo1.db'));

      // Delete the item from the database if undo is not pressed
      if (!_undoPressed) {
        await db.delete('todolist', where: 'tid = ?', whereArgs: [id]);
        print('Item deleted from database');
      }
    } catch (error) {
      print('Error deleting item from database: $error');
      // Handle error if deletion from database fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.regList.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(widget.regList[index]),
            background: Container(color: Colors.greenAccent),
            onDismissed: (direction) async {
              try {
                final int id = widget.regList[index].tid;

                setState(() {
                  _dismissedItem = widget.regList.removeAt(index);
                  _remindex = index;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      closeIconColor: Colors.blue[50],
                      showCloseIcon: true,
                      action: SnackBarAction(
                        backgroundColor: Colors.black12,
                        label: 'Undo ',
                        onPressed: () {
                          setState(() {
                            widget.regList.insert(_remindex!, _dismissedItem!);
                            _dismissedItem = null;
                            _remindex = null;
                            _undoPressed = true; // Set undo flag
                          });
                        },
                      ),
                      content: const Text('Deleted Successfully '),
                    ),
                  );
                });

                _deleteScheduled = true;
                Future.delayed(const Duration(seconds: 2), () {
                  if (_deleteScheduled && !_undoPressed) {
                    // Delete only if not undone
                    _deleteItemFromDB(id);
                    setState(() {
                      _deleteScheduled = false;
                    });
                  }
                  // Reset undo flag
                  _undoPressed = false;
                });
              } catch (error) {
                print('Error deleting item: $error');
              }
            },
            child:
                todocard(l1: widget.regList[index], onUpdate: widget.onUpdate),
          );
        },
      ),
    );
  }
}
