import 'package:flutter/material.dart';

import 'package:todolist/model/to_do_list.dart';
import 'package:todolist/screen/LoadingScreen.dart';

import 'package:todolist/screen/new_to_do2.dart';
import 'package:todolist/widgets/todolistbuilder.dart';
import 'package:todolist/widgets/Drawer.dart';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:todolist/data/databasehelper.dart';
import 'package:todolist/uitilities/list_separation_helper.dart';
import 'package:todolist/widgets/text.dart';

class Homescreen2 extends StatefulWidget {
  const Homescreen2({Key? key, required this.onClosePressed}) : super(key: key);
  final VoidCallback onClosePressed;
  @override
  State<Homescreen2> createState() {
    return _homeScreenState();
  }
}

// ignore: camel_case_types
class _homeScreenState extends State<Homescreen2> {
  String _selectedListType = 'Full List';
  List<ToDoList> _regList = [];
  final TextEditingController _quickadd = TextEditingController();
  bool _isLoading = true;
  List<ToDoList> _overdueList = [];
  List<ToDoList> _todayList = [];
  List<ToDoList> _tomorrowList = [];
  List<ToDoList> _thisWeekList = [];
  List<ToDoList> _thisMonthList = [];
  List<ToDoList> _beyondThisMonthList = [];
  List<ToDoList> _noDueList = [];
  List<ToDoList> _CompletedList = [];

  @override
  void initState() {
    _isLoading = true;
    _loadData();
    super.initState();
    // NotificationHelper.scheduleDailyNotification(_todayList.cast<String>());
  }

  Future<void> _loadData() async {
    _isLoading = true;
    try {
      final db = await DatabaseHelper.getDatabase();

      List<Map<String, dynamic>> list = await db.query(
        'todolist',
        where: 'tid >= ?',
        whereArgs: [1],
        orderBy: 'date ASC',
      );

      _regList = list
          .map((item) => ToDoList(
                tid: item['tid'],
                catid: item['catid'],
                tododetails: item['tododetails'],
                date:
                    item['date'] != null ? DateTime.parse(item['date']) : null,
                time:
                    item['time'] != null ? DateTime.parse(item['time']) : null,
                alarm: item['alarm'] == 1 ? true : false,
                status: item['status'],
              ))
          .toList();

      ListSeparationHelper.separateLists(
        regList: _regList,
        overdueList: _overdueList,
        todayList: _todayList,
        tomorrowList: _tomorrowList,
        thisWeekList: _thisWeekList,
        thisMonthList: _thisMonthList,
        beyondThisMonthList: _beyondThisMonthList,
        noDueList: _noDueList,
        completedList: _CompletedList,
      );

      setState(() {
        _isLoading = false; // Set loading state to false after data is loaded
      });
    } catch (error) {
      print('Error loading data: $error');
      setState(() {
        _isLoading =
            false; // Set loading state to false even if there's an error
      });
    }
  }

  void _quickAdd() async {
    try {
      final String quickAddText = _quickadd.text.trim();

      if (quickAddText.isNotEmpty) {
        final db = await DatabaseHelper.getDatabase();

        await db.insert(
          'todolist',
          {
            'catid': 1,
            'catname': 'Default',
            'tododetails': quickAddText,
            'date': null,
            'time': null,
            'alarm': false,
            'status': 'Not Completed',
          },
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
        );

        _quickadd.clear();

        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quick Add: $quickAddText'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during quick add: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.teal.shade400,
        drawer: CustomDrawer(
          selectedListType: _selectedListType,
          onItemTap: (type) {
            setState(() {
              _selectedListType = type;
            });
          },
        ),
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _loadData();
                });
              },
              icon: const Icon(Icons.replay_outlined),
            ),
            IconButton(
              onPressed: widget.onClosePressed,
              icon: const Icon(Icons.close_outlined),
            ),
          ],
          title: const Text('TodoList App'),
        ),
        body: _isLoading
            ? const LoadingScreen()
            : Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    if (_selectedListType == 'Full List') ...[
                      TextFormat().formatText('Full List'),
                      ToDoListWidget(
                        regList: _regList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'Overdue') ...[
                      TextFormat().formatText('Over Due'),
                      ToDoListWidget(
                        regList: _overdueList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'Today') ...[
                      TextFormat().formatText('Todays To do'),
                      ToDoListWidget(
                        regList: _todayList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'Tomorrow') ...[
                      TextFormat().formatText('Tommorows To do'),
                      ToDoListWidget(
                        regList: _tomorrowList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'This Week') ...[
                      TextFormat().formatText('This Week to do'),
                      ToDoListWidget(
                        regList: _thisWeekList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'This Month') ...[
                      TextFormat().formatText('This Month to do '),
                      ToDoListWidget(
                        regList: _thisMonthList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'Beyond This Month') ...[
                      TextFormat().formatText('Beyond This Month to do'),
                      ToDoListWidget(
                        regList: _beyondThisMonthList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'No Due') ...[
                      TextFormat().formatText('No Due'),
                      ToDoListWidget(
                        regList: _noDueList,
                        onUpdate: _loadData,
                      ),
                    ] else if (_selectedListType == 'Completed') ...[
                      TextFormat().formatText('Completed'),
                      ToDoListWidget(
                        regList: _CompletedList,
                        onUpdate: _loadData,
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black12, // Use app bar color
                          borderRadius: BorderRadius.circular(
                              10), // Set border radius here
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _quickadd,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: 'Quick Add',
                                  border:
                                      InputBorder.none, // Remove default border
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _quickAdd,
                              icon: const Icon(Icons.send_outlined),
                            ),
                            FloatingActionButton.small(
                              backgroundColor: Colors.teal,
                              shape: const CircleBorder(
                                  side: BorderSide(width: 0)),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => const NewToDo2(),
                                ))
                                    .then((value) {
                                  if (value != null && value == true) {
                                    _isLoading = true;
                                    setState(() {
                                      initState();
                                    });
                                  }
                                });
                              },
                              heroTag: 'fb2',
                              child: const Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}
