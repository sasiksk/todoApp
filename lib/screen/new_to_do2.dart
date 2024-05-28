import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist/data/databasehelper.dart';
import 'package:todolist/uitilities/notification_helper.dart';

List<String> _category = [];
String _selCat = 'Work';

class NewToDo2 extends StatefulWidget {
  const NewToDo2({super.key});

  @override
  State<NewToDo2> createState() => _NewToDoState();
}

class _NewToDoState extends State<NewToDo2> {
  bool _isChecked = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _todotext = TextEditingController();
  final TextEditingController _tododate = TextEditingController();
  final TextEditingController _todotime = TextEditingController();

  @override
  void initState() {
    super.initState();
    DatabaseHelper.getDatabase().then((db) {
      _loadCategories();
    });
    NotificationHelper.initializeNotifications();
  }

  @override
  void dispose() {
    _todotext.dispose();
    _tododate.dispose();
    _todotime.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> categories = await db.query('category');
    setState(() {
      _category =
          categories.map<String>((cat) => cat['catname'] as String).toList();
    });
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: no_leading_underscores_for_local_identifiers
        final TextEditingController _catname = TextEditingController();
        return AlertDialog(
          scrollable: true,
          title: const Text('Add New Category '),
          content: TextField(
            controller: _catname, // Controller to retrieve text input
            decoration: const InputDecoration(hintText: 'Enter New Category'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String newCategory = _catname.text;
                if (newCategory.isNotEmpty) {
                  try {
                    final db = await DatabaseHelper.getDatabase();
                    // Check if the category already exists
                    List<Map> existingCategory = await db.rawQuery(
                        "SELECT * FROM category WHERE catname = ?",
                        [newCategory]);
                    if (existingCategory.isEmpty) {
                      // Insert the new category if it doesn't exist
                      await db.rawInsert(
                          "INSERT INTO category (catname) VALUES (?)",
                          [newCategory]);
                      print('NEW CAT INSERTED SUCCESSFULLY');
                      _loadCategories();
                    } else {
                      print('Category already exists.');
                    }
                  } catch (e) {
                    print('Error inserting category: $e');
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 1000)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _tododate.text = DateFormat.yMMMd().format(_selectedDate!);
      });
    }
  }

  void _presentTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _todotime.text = _selectedTime!.format(context);
      });
    }
  }

  Future<void> _insertTodo() async {
    try {
      final db = await DatabaseHelper.getDatabase();
      List<Map<String, dynamic>> result = await db
          .rawQuery('SELECT catid FROM category WHERE catname = ?', [_selCat]);

      int catid = result.isNotEmpty ? result.first['catid'] : 0;

      DateTime? selectedDateTime;
      if (_selectedDate != null && _selectedTime != null) {
        selectedDateTime = DateTime(_selectedDate!.year, _selectedDate!.month,
            _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      }

      String? formattedDateTime;
      if (selectedDateTime != null) {
        formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);
      }

      await db.insert(
        'todolist',
        {
          'catid': catid,
          'catname': _selCat,
          'tododetails': _todotext.text,
          'date': formattedDateTime,
          'time': formattedDateTime,
          'alarm': _isChecked ? true : false,
          'status': 'Not Completed',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Todo inserted successfully');

      if (_isChecked && selectedDateTime != null) {
        await NotificationHelper.scheduleNotification(
            catid, _todotext.text, selectedDateTime);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: const Text('Task Added Sucessfully!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error inserting todo: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert Error'),
            content: const Text(
                'An error occurred while adding the todo. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New To-Do'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What do you want to do?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _todotext,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(width: 1),
                        gapPadding: BorderSide.strokeAlignCenter,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter To do Task ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Due Date',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tododate,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(width: 0.5),
                            ),
                          ),
                          readOnly: true,
                          onTap: _presentDatePicker,
                          validator: (value) {
                            if (_selectedDate != null &&
                                _selectedDate!.isBefore(DateTime.now()
                                    .subtract(const Duration(days: 1)))) {
                              return 'Please select a date today or in the future';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _presentDatePicker,
                        icon: const Icon(Icons.calendar_month),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                            _tododate.clear();
                          });
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _todotime,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(width: 0.5),
                            ),
                          ),
                          readOnly: true,
                          onTap: _presentTimePicker,
                          validator: (value) {
                            if (_selectedTime == null) {
                              return 'Please select a time ';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _presentTimePicker,
                        icon: const Icon(Icons.access_alarm_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedTime = null;
                            _todotime.clear();
                          });
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      const Text('Alarm'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Add to Category '),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(width: 1),
                            ),
                          ),
                          value: _selCat,
                          items: _category.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selCat = newValue!;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(
                          Icons.playlist_add_circle,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          shape: const CircleBorder(side: BorderSide(width: 0)),
          onPressed: () async {
            final _db = await DatabaseHelper.getDatabase();
            bool res = _formKey.currentState!.validate();
            if (res) {
              _insertTodo();
            }
          },
          heroTag: 'fb1',
          child: const Icon(
            Icons.check_circle_outline_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
