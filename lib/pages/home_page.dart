import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import 'package:to_do_app/data/database.dart';
import 'package:to_do_app/util/dialog_box.dart';
import 'package:to_do_app/util/notification_service.dart';
import 'package:to_do_app/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDatabase db = ToDoDatabase();

  @override
  void initState() {
    super.initState();

    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    }
    else{
      db.loadData();
    }
  }

  final _controller = TextEditingController();
  
  void checkBoxChanged(bool? value, int index){
    setState(() {
      db.toDoList[index]["completed"] = !db.toDoList[index]["completed"];
    });
    db.updateDataBase();
  }

  void createNewTask(){
    showDialog(context: context,
      builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop(),
          );
      }
    );
  }

  void saveNewTask(){
    setState(() {
      db.toDoList.add({
        "id": DateTime.now().millisecondsSinceEpoch,
        "title": _controller.text,
        "completed": false,
        "reminderTime": null,
        "notificationId": null,
      });
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void deleteTask(int index){
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  Future<void> setReminder(int index) async {

  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );

  if (date == null) return;

  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time == null) return;

  final reminderDateTime = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  final notificationId =
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  await NotificationService.scheduleNotification(
    id: notificationId,
    title: db.toDoList[index]["title"],
    body: "Task Reminder",
    scheduledTime: reminderDateTime,
  );

  db.toDoList[index]["reminderTime"] =
      reminderDateTime.toIso8601String();

  db.toDoList[index]["notificationId"] =
      notificationId;

  db.updateDataBase();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Reminder set successfully!"),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text("To Do"),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications),
        //     onPressed: () async {
        //       await NotificationService.scheduleNotification(
        //       id: 1,
        //       title: "Test Reminder",
        //       body: "Notifications are working!",
        //       scheduledTime: DateTime.now().add(
        //       const Duration(seconds: 10),
        //       ),
        //      );
        //     },
        //   ),
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)
        ),
        child: Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return TodoTile(
            taskName: db.toDoList[index]["title"], 
            taskCompleted: db.toDoList[index]["completed"], 
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFuntion: (context) => deleteTask(index),
            onReminderPressed: () => setReminder(index),
            );
        },
      ),
    );
  }
}