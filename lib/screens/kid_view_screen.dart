import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:provider/provider.dart';
import 'package:vizsga_feladat/providers/kids.dart';
import 'package:vizsga_feladat/providers/tasks.dart';
import 'package:vizsga_feladat/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth.dart';

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
  Util util = new Util();
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
      if (pref.containsKey('userData')) {
        extractedUserData = json.decode(pref.getString('userData')) as Map<String, Object>;
        getKidTasks().then((value) {});
        return extractedUserData['name'];
      }
    });
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
        .getKidsTodos(extractedUserData['kidId'], selectedFromDate.toString(),
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
          elevation: 5.0,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: (extractedKidTodoDatas[i]['checkDate'] ==
                          '0000-00-00 00:00:00'
                      ? Image.network(
                          "https://e7.pngegg.com/pngimages/972/936/png-clipart-exclamation-mark-dijak-question-mark-school-interjection-exclamation-mark-miscellaneous-child-thumbnail.png")
                      : Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ20JjWhOTQ38G0XIYlBH_81IHv2R9yUjld3w&usqp=CAU"))),
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
                  extractedKidTodoDatas[i]['checkDate'] != "0000-00-00 00:00:00"
                      ? Icons.volunteer_activism
                      : Icons.clear,
                  color: Colors.black87,
                  size: 30.0),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    title: Text(extractedKidTodoDatas[i]['checkDate'] ==
                            '0000-00-00 00:00:00'
                        ? "Tutkó megcsináltad?"
                        : "Mégsem csináltad meg?"),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                        ),
                        child: Text("Mégsem"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                        ),
                        child: Text("Kész"),
                        onPressed: () async {
                          Navigator.pop(context);
                          if (extractedKidTodoDatas[i]['id'] != null) {
                            DateTime aktDatum = DateTime.now();
                            String stringDatum = aktDatum.year.toString() +
                                "-" +
                                (aktDatum.month.toString().length == 1
                                    ? "0" + aktDatum.month.toString()
                                    : aktDatum.month.toString()) +
                                "-" +
                                (aktDatum.day.toString().length == 1
                                    ? "0" + aktDatum.day.toString()
                                    : aktDatum.day.toString()) +
                                " " +
                                (aktDatum.hour.toString().length == 1
                                    ? "0" + aktDatum.hour.toString()
                                    : aktDatum.hour.toString()) +
                                ":" +
                                (aktDatum.minute.toString().length == 1
                                    ? "0" + aktDatum.minute.toString()
                                    : aktDatum.minute.toString());
                            if (extractedKidTodoDatas[i]['checkDate'] !=
                                '0000-00-00 00:00:00')
                              stringDatum = '0000-00-00 00:00:00';
                            await tasks
                                .setTodoCheck(
                                    extractedKidTodoDatas[i]['id'], stringDatum)
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

  void handleClick(String value) async {
    switch (value) {
      case 'Kilépés':
        final pref = await SharedPreferences.getInstance();
        pref.clear();
        Provider.of<Auth>(context, listen: false).logout();
        Navigator.of(context).pushReplacementNamed("/");
        //Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
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
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: handleClick,
          itemBuilder: (BuildContext context) {
            return {'Kilépés'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  dynamic elozoGomb() {
    return AnimatedButton(
      width: 60,
      height: 30,
      text: 'Előző',
      backgroundColor: Colors.transparent,
      selectedBackgroundColor: Colors.transparent,
      selectedTextColor: Colors.greenAccent,
      transitionType: TransitionType.BOTTOM_TO_TOP,
      isReverse: true,
      onPress: () {
        minuszEgyNap();
        var name = getUserData();
        name.then((name) {
          if (mounted) {
            setState(() {});
          }
        });
      },
      textStyle: TextStyle(
          fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.w900),
    );
  }

  dynamic kovetkezoGomb() {
    return AnimatedButton(
      width: 110,
      height: 30,
      text: 'Következő',
      backgroundColor: Colors.transparent,
      selectedBackgroundColor: Colors.transparent,
      selectedTextColor: Colors.greenAccent,
      transitionType: TransitionType.BOTTOM_TO_TOP,
      isReverse: true,
      onPress: () {
        pluszEgyNap();
        var name = getUserData();
        name.then((name) {
          if (mounted) {
            setState(() {});
          }
        });
      },
      textStyle: TextStyle(
          fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.w900),
    );
  }

  void pluszEgyNap() {
    String fromWhen = selectedFromDate.year.toString() +
        "-" +
        util.normalizeTimeMin(selectedFromDate.month) +
        "-" +
        util.normalizeTimeMin(selectedFromDate.day + 1) +
        " " +
        "00:00:00";
    selectedFromDate = DateTime.parse(fromWhen);
    String toWhen = selectedToDate.year.toString() +
        "-" +
        util.normalizeTimeMin(selectedToDate.month) +
        "-" +
        util.normalizeTimeMin(selectedToDate.day + 1) +
        " " +
        "00:00:00";
    selectedToDate = DateTime.parse(toWhen);
  }

  void minuszEgyNap() {
    String fromWhen = selectedFromDate.year.toString() +
        "-" +
        util.normalizeTimeMin(selectedFromDate.month) +
        "-" +
        util.normalizeTimeMin(selectedFromDate.day - 1) +
        " " +
        "00:00:00";
    selectedFromDate = DateTime.parse(fromWhen);
    String toWhen = selectedToDate.year.toString() +
        "-" +
        util.normalizeTimeMin(selectedToDate.month) +
        "-" +
        util.normalizeTimeMin(selectedToDate.day - 1) +
        " " +
        "00:00:00";
    selectedToDate = DateTime.parse(toWhen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Container(
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
                child: Column(
                  children: [
                    Row(children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          (extractedUserData != null)
                              ? extractedUserData['kidName']
                              : "",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      SizedBox(
                        width: 50,
                      ),
                      Text(selectedFromDate.year.toString() +
                          "-" +
                          (selectedFromDate.month.toString().length == 1
                              ? "0" + selectedFromDate.month.toString()
                              : selectedFromDate.month.toString()) +
                          "-" +
                          (selectedFromDate.day.toString().length == 1
                              ? "0" + selectedFromDate.day.toString()
                              : selectedFromDate.day.toString())),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 50,
                              ),
                              elozoGomb(),
                              SizedBox(
                                width: 20,
                              ),
                              kovetkezoGomb(),
                            ]),
                      ),
                    ]),
                  ],
                ),
              ),
              todoListBuilder(),
            ],
          ),
        ),
      ),
    );
  }
}
