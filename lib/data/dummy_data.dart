import 'package:todolist/model/Category.dart';
import 'package:todolist/model/to_do_list.dart';

const availcat = [
  Category(id: 1, title: 'Work'),
  Category(id: 2, title: 'Home'),
  Category(id: 3, title: 'Others'),
  Category(id: 4, title: 'Default'),
];

DateTime getDate(DateTime now) {
  return DateTime(now.year, now.month, now.day);
}

DateTime getTime(DateTime now) {
  return DateTime(now.hour, now.minute, now.second);
}

List<ToDoList> todolistdata = [
  ToDoList(
    tid: 1,
    catid: 1,
    tododetails: 'Want to finish class log book',
    date: getDate(DateTime.now()),
    time: getTime(DateTime.now()),
    alarm: true,
    status: 'Not Completed',
  ),
  ToDoList(
    tid: 2,
    catid: 1,
    tododetails: 'Want to contact Refinment',
    date: getDate(DateTime.now()),
    time: getTime(DateTime.now()),
    alarm: false,
    status: 'Not Completed',
  ),
  ToDoList(
    tid: 2,
    catid: 2,
    tododetails: 'Want to Renew Star Health',
    date: getDate(DateTime.now().add(const Duration(days: 1))),
    time: getTime(DateTime.now().add(const Duration(days: 1))),
    alarm: true,
    status: 'Not Completed',
  ),
];
