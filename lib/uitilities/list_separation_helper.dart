import 'package:todolist/model/to_do_list.dart';

class ListSeparationHelper {
  static void separateLists({
    required List<ToDoList> regList,
    required List<ToDoList> overdueList,
    required List<ToDoList> todayList,
    required List<ToDoList> tomorrowList,
    required List<ToDoList> thisWeekList,
    required List<ToDoList> thisMonthList,
    required List<ToDoList> beyondThisMonthList,
    required List<ToDoList> noDueList,
    required List<ToDoList> completedList, // Added completed list
  }) {
    overdueList.clear();
    todayList.clear();
    tomorrowList.clear();
    thisWeekList.clear();
    thisMonthList.clear();
    beyondThisMonthList.clear();
    noDueList.clear();
    completedList.clear(); // Clear completed list

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime endOfWeek =
        today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    if (endOfWeek.month != today.month) {
      endOfWeek = lastDayOfMonth;
    }

    DateTime startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    for (var item in regList) {
      if (item.date != null) {
        DateTime itemDate =
            DateTime(item.date!.year, item.date!.month, item.date!.day);

        if (itemDate.isBefore(today)) {
          overdueList.add(item);
        } else if (itemDate.isAtSameMomentAs(today)) {
          todayList.add(item);
        } else if (itemDate.isAtSameMomentAs(tomorrow)) {
          tomorrowList.add(item);
        } else if (itemDate.isAfter(tomorrow) &&
            itemDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          thisWeekList.add(item);
        } else if (itemDate.isAfter(endOfWeek) &&
            itemDate.isBefore(startOfNextMonth)) {
          thisMonthList.add(item);
        } else if (itemDate.isAtSameMomentAs(startOfNextMonth) ||
            itemDate.isAfter(startOfNextMonth)) {
          beyondThisMonthList.add(item);
        }
      } else {
        noDueList.add(item);
      }

      // Check for completed items and add to completed list
      if (item.status == 'Completed') {
        completedList.add(item);
      }
    }
  }
}
