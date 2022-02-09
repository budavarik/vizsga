import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rest_api_login/providers/kids.dart';
import 'package:rest_api_login/providers/tasks.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class kidViewScreen extends StatefulWidget {
  final String selectedKid;

  const kidViewScreen({Key key, this.selectedKid}) : super(key: key);

  @override
  State<kidViewScreen> createState() => _kidViewScreenState(selectedKid);
}

class _kidViewScreenState extends State<kidViewScreen> {
  final String selectedKid;
  Kids kids = new Kids();
  Tasks tasks = new Tasks();
  Map<String, Object> extractedUserData;
  List<Map<String, Object>> extractedKidsData = [];
  List<Map<String, Object>> extractedKidTodoDatas = [];
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  _kidViewScreenState(this.selectedKid);

  @override
  void initState() {
    var name = getUserData();
    name.then((name) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<String> getUserData() async {
    final pref = await SharedPreferences.getInstance().then((pref) {
      extractedUserData = json.decode(pref.getString('userData')) as Map<String, Object>;
      getKidTasks().then((value) {
      });
    });
    return extractedUserData['name'];
  }

  Future<String> getKidTasks() async {
    String retVal = null;
    var index;
    for (var value in extractedKidsData) {
      if (value.values.contains(selectedKid)) {
        index = value['id'];
      }
    }
    kids.getKidsTodos(extractedUserData['kidId'], selectedFromDate.toString(),
            selectedToDate.toString())
        .then((value) {
      extractedKidTodoDatas.clear();
      final pref = SharedPreferences.getInstance().then((pref) {
        List<String> decoded = pref.getStringList('kidTodoList');
        for (int i = 0; i < decoded.length; i++) {
          var tmp = json.decode(decoded[i]) as Map<String, Object>;
          extractedKidTodoDatas.add(tmp);
        }
        if (mounted) {
          setState(() {});
        }
      });
    });
    return retVal;
  }

  dynamic todoListBuilder() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: extractedKidTodoDatas.length,
      itemBuilder: (context, i) {
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0.4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Container(
            child: ListTile(
              leading: CircleAvatar(
                  child: Image.network("https://via.placeholder.com/150")),
              title: Text(
                extractedKidTodoDatas[i]['task'],
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  Icon(Icons.linear_scale, color: Colors.greenAccent),
                  Text(extractedKidTodoDatas[i]['dateFull'],
                      style: TextStyle(color: Colors.black87))
                ],
              ),
              trailing: Icon(
                  extractedKidTodoDatas[i]['checkDate'] != "0000-00-00 00:00:00" ? Icons.volunteer_activism : Icons.clear,
                  color: Colors.black87, size: 30.0),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    title: Text("Tutkó megcsináltad?"),
                    actions: [
                      TextButton(
                        child: Text("Mégsem"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("Kész"),
                        onPressed: () async {
                          Navigator.pop(context);
                          if (extractedKidTodoDatas[i]['id'] != null) {
                            await tasks
                                .setTodoCheck(extractedKidTodoDatas[i]['id'])
                                .then((value) {
                              getKidTasks();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  dynamic setAppBar() {
    return AppBar(
      title: Row(
        children: <Widget>[
          Text(extractedUserData != null ? extractedUserData['name'] : "Home"),
          SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: <Widget>[
            todoListBuilder(),
          ]),
        ),
      ),
    );
  }
}
