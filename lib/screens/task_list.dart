import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/providers/tasks.dart';
import 'newTodotoKid.dart';

class TaskList extends StatefulWidget {
  final String selectedKid;

  const TaskList({Key key, this.selectedKid}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState(selectedKid);
}

class _TaskListState extends State<TaskList> {
  final String selectedKid;
  Tasks tasks = new Tasks();
  TextEditingController nameController = TextEditingController();
  List<Map<String, Object>> taskList = [];
  List<Map<String, Object>> extractedKidsData = [];
  String selectedKidName = "";

  _TaskListState(this.selectedKid);

  @override
  void initState() {
    var name = getTaskList();
    name.then((name) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<void> getTaskList() async {
    String retVal = null;
    taskList.clear();
    await tasks.getTasksApi().then((value) {
      final pref = SharedPreferences.getInstance().then((pref) {
        List<String> decoded = pref.getStringList('tasks');
        for (int i = 0; i < decoded.length; i++) {
          var tmp = json.decode(decoded[i]) as Map<String, Object>;
          taskList.add(tmp);
          retVal = "OK";
        }
        getKidsData();
      });
    });
    return retVal;
  }

  Future<String> getKidsData() async {
    String retVal = null;
    final pref2 = await SharedPreferences.getInstance().then((pref2) {
      List<String> decoded = pref2.getStringList('kidsData');
      for (int i = 0; i < decoded.length; i++) {
        var tmp = json.decode(decoded[i]) as Map<String, Object>;
        if (tmp['id'] == selectedKid) {
          selectedKidName = tmp['name'];
        }
        extractedKidsData.add(tmp);
        retVal = "OK";
      }
    });
    return retVal;
  }

  dynamic taskListBuilder() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: taskList.length,
      itemBuilder: (context, i) {
        return Card(
          shadowColor: Colors.black,
          margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            child: ListTile(
//              leading: CircleAvatar(
//                  child: Image.network("https://via.placeholder.com/150")),
              title: Text(
                taskList[i]['task'],
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  Icon(Icons.linear_scale, color: Colors.greenAccent),
                  Text("Id: " + taskList[i]['id'],
                      style: TextStyle(color: Colors.black87))
                ],
              ),
              onTap: () {
                //selectTask(context, taskList[i]['id'], taskList[i]['task']);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => newTodoToKid(
                            kidsId: selectedKid,
                            taskId: taskList[i]['id'],
                            taskName: taskList[i]['task'])));
              },
            ),
          ),
        );
      },
    );
  }

  dynamic newTask() {
    nameController.text = "";
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Builder(
          builder: (context) {
            // Get available height and width of the build area of this widget. Make a choice depending on the size.
            var height = 0.0; //MediaQuery.of(context).size.height;
            var width = MediaQuery.of(context).size.width;

            return Container(
              height: height,
              width: width - 100,
            );
          },
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text("Új task:"),
        actions: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Task neve',
            ),
          ),
          Row(
            children: [
              TextButton(
                child: Text("Mégsem"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Rögzít"),
                onPressed: () async {
                  await tasks.insertTodo(nameController.text).then((value) {
                    var name = getTaskList();
                    name.then((name) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  dynamic ujTetelGomb() {
    return AnimatedButton(
      width: 90,
      height: 50,
      text: 'Új tétel',
      borderRadius: 20,
      selectedBackgroundColor: Colors.transparent,
      selectedTextColor: Colors.greenAccent,
      transitionType: TransitionType.BOTTOM_TO_TOP,
      isReverse: true,
      onPress: () {
        newTask();
      },
      textStyle: TextStyle(
          fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.w900),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Taskok listája"),
      ),
      body: SingleChildScrollView(
        child: AnimatedContainer(
          duration: Duration(seconds: 5),
          child: Center(
            child: Column(children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 80,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white12,
                        Colors.white,
                      ],
                    )),
                child: Row(

                    children: <Widget>[
                      Expanded(
                        flex: 8,
                        child: Container(
                          child: Row(
                            children: [
                            Text(
                            "Kiválasztott felhasználó: $selectedKidName",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ],
                        ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Row(
                            children: [
                              ujTetelGomb(),
                            ],
                          ),
                        ),
                      ),
                ]),
              ),
              SizedBox(
                height: 10,
              ),
              taskListBuilder(),
            ]),
          ),
        ),
      ),
    );
  }
}
