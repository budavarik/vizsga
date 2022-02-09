import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vizsga_feladat/providers/kids.dart';
import 'task_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/models.dart';

class SelectKidScreen extends StatefulWidget {
  @override
  State<SelectKidScreen> createState() => _SelectKidScreenState();
}

class _SelectKidScreenState extends State<SelectKidScreen> {
  Map<String, Object> extractedUserData;
  List<Map<String, Object>> extractedKidsData = [];
  List<Map<String, Object>> extractedKidTodoDatas = [];
  Kids kids = new Kids();
  String selectedKid;
  List<String> kidsMenu = [];
  List<KidTodoList> kidTodoList = [];
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool toggleFrom = false;
  bool toggleTo = false;

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
      extractedUserData =
          json.decode(pref.getString('userData')) as Map<String, Object>;
      kids.getKids(extractedUserData['id']).then((value) {
        var name = getKidsData();
        name.then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      });
    });
    return extractedUserData['name'];
  }

  Future<String> getKidsData() async {
    String retVal = null;
    final pref2 = await SharedPreferences.getInstance().then((pref2) {
      List<String> decoded = pref2.getStringList('kidsData');
      for (int i = 0; i < decoded.length; i++) {
        var tmp = json.decode(decoded[i]) as Map<String, Object>;
        extractedKidsData.add(tmp);
        kidsMenu.add(tmp['name']);
        retVal = "OK";
      }
    });
    return retVal;
  }

  Future<String> getKidTasks() async {
    String retVal = null;
    var index;
    for (var value in extractedKidsData) {
      if (value.values.contains(selectedKid)) {
        index = value['id'];
      }
    }
    kids
        .getKidsTodos(
            index, selectedFromDate.toString(), selectedToDate.toString())
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

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
      });
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
              trailing: Icon(Icons.delete, color: Colors.black87, size: 30.0),
              onTap: () {

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(

                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(
                            Radius.circular(10.0))),
                    title: Text("Biztos vagy benne?"),
                    actions: [
                      TextButton(
                        child: Text("Mégsem"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("Törlés"),
                        onPressed: () async {
                          Navigator.pop(context);
                          if (extractedKidTodoDatas[i]['id'] != null) {
                            await kids.delKidTodoData(extractedKidTodoDatas[i]['id']).then((value) {
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
          FlatButton(
              padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
              color: Colors.amber,
              shape: RoundedRectangleBorder(side: BorderSide.none),
              child: Text('Szűrés'),
              onPressed: () {
                getKidTasks();
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: setAppBar(),
      body: SingleChildScrollView(
          child: Center(
        child: Column(children: <Widget>[
          Row(
            children: [
              DropdownButton<String>(
                hint: Text('Select kid name'),
                value: selectedKid,
                onChanged: (newValue) {
                  setState(() {
                    selectedKid = newValue;
                  });
                },
                items: kidsMenu.map((location) {
                  return DropdownMenuItem(
                    child: Text(location),
                    value: location,
                  );
                }).toList(),
              ),
              Text("${selectedFromDate.toLocal()}".split(' ')[0]),
              SizedBox(
                width: 1.0,
              ),
              IconButton(
                  icon: toggleFrom
                      ? Icon(Icons.favorite_border)
                      : Icon(
                          Icons.favorite,
                        ),
                  onPressed: () {
                    toggleFrom = !toggleFrom;
                    _selectFromDate(context);
                  }),
              SizedBox(
                width: 1.0,
              ),
              Text("--"),
              SizedBox(
                width: 1.0,
              ),
              Text("${selectedToDate.toLocal()}".split(' ')[0]),
              SizedBox(
                width: 1.0,
              ),
              IconButton(
                  icon: toggleTo
                      ? Icon(Icons.favorite_border)
                      : Icon(
                          Icons.favorite,
                        ),
                  onPressed: () {
                    toggleTo = !toggleTo;
                    _selectToDate(context);
                  }),
            ],
          ),
          todoListBuilder(),
          SizedBox(
            height: 5.0,
          ),
          Column(
            children: [
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    elevation: 15,
                    padding: const EdgeInsets.all(12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    var index;
                    for (var value in extractedKidsData) {
                      if (value.values.contains(selectedKid)) {
                        index = value['id'];
                      }
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TaskList(selectedKid: index)));

                  },
                  child: Text(
                    "+",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ]),
      )),
    );
  }
}
