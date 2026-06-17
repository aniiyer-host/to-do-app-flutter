import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
  List toDoList = [];

  final _myBox = Hive.box('mybox');
  
  void createInitialData(){
    toDoList = [
      {
        "title": "Finish Work",
        "completed": false,
        "reminderTime": null,
        "notificationId": null,
      },
      {
        "title": "Do Exercise",
        "completed": false,
        "reminderTime": null,
        "notificationId": null,
      },
    ];
  }

  void loadData() {
    toDoList = _myBox.get("TODOLIST");
  }

  void updateDataBase(){
    _myBox.put("TODOLIST", toDoList);
  }
}