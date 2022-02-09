import 'package:flutter/material.dart';
import '/providers/tasks.dart';
import 'select_kid_screen.dart';
import 'package:rest_api_login/utils/util.dart';
import '/providers/tasks.dart';

class newTodoToKid extends StatefulWidget {
  final String kidsId;
  final String taskId;
  final String taskName;

  const newTodoToKid({Key key, this.kidsId, this.taskId, this.taskName})
      : super(key: key);

  @override
  State<newTodoToKid> createState() =>
      _newTodoToKidState(kidsId, taskId, taskName);
}

class _newTodoToKidState extends State<newTodoToKid> {
  final String kidsId;
  final String taskId;
  final String taskName;
  Tasks tasks = new Tasks();
  Util util = new Util();
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  TimeOfDay onTimeChange = TimeOfDay.now();
  TimeOfDay pickedTime = TimeOfDay.now();
  bool toggleFrom = false;
  bool toggleTo = false;
  bool checkedValue = false;
  List<String> days = [
    'Hétfő',
    'Kedd',
    'Szerda',
    'Csütörtök',
    'Péntek',
    'Szombat',
    'Vasárnap'
  ];
  List<bool> daysCheck = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  _newTodoToKidState(this.kidsId, this.taskId, this.taskName);

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

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: onTimeChange,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },);
    if (pickedTime != null && pickedTime != selectedToDate)
      setState(() {
        onTimeChange = pickedTime;
      });
  }

  dynamic weekDays(int i) {
      return Row(
        children: [
          SizedBox(
            width: 200,
            child: CheckboxListTile(
              title: Text(days[i]),
              value: daysCheck[i],
              onChanged: (newValue) {
                setState(() {
                  daysCheck[i] = newValue;
                });
              },
              controlAffinity:
              ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          ),
        ],
      );
  }

  void createTodoList() {
    for (DateTime aktDate = selectedFromDate; aktDate.isBefore(selectedToDate); aktDate = new DateTime(aktDate.year, aktDate.month, aktDate.day + 1)) {
      if (daysCheck[aktDate.weekday-1]) {
        var whenDate = aktDate.year.toString() + "-" +
                       util.normalizeTimeMin(aktDate.month) + "-" +
                       util.normalizeTimeMin(aktDate.day) + " " +
                       util.normalizeTimeMin(onTimeChange.hour) + ":" +
                       util.normalizeTimeMin(onTimeChange.minute) + ":" +
                       "00";
        tasks.insertTodoList(kidsId, whenDate, taskId).then((value) => null);
      }
    }
    //var aktDate = DateTime.parse(responseData[i]['whenDate']);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text("Új feladat hozzáadása"),
            SizedBox(
              width: 50,
            ),
            FlatButton(
                padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                color: Colors.amber,
                shape: RoundedRectangleBorder(side: BorderSide.none),
                child: Text('Mentés'),
                onPressed: () {
                  createTodoList();
                  Navigator.push(context,MaterialPageRoute(builder: (context) => SelectKidScreen()));
                }),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Text("Feladat: $taskName"),
              ],
            ),
            Row(
              children: [
                Text(
                    "Mettől: " + "${selectedFromDate.toLocal()}".split(' ')[0]),
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
                Text("Meddig: " + "${selectedToDate.toLocal()}".split(' ')[0]),
                SizedBox(
                  height: 10.0,
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

                SizedBox(
                  width: 1.0,
                ),
                Text("Hánykor: " + "${onTimeChange.hour}:${util.normalizeTimeMin(onTimeChange.minute)}"),
                SizedBox(
                  height: 10.0,
                ),
                IconButton(
                    icon: toggleTo
                        ? Icon(Icons.favorite_border)
                        : Icon(
                      Icons.favorite,
                    ),
                    onPressed: () {
                      toggleTo = !toggleTo;
                      _selectTime(context);
                    }),

              ],
            ),
            for (int i=0; i<days.length; i++) weekDays(i),
          ],
        ),
      ),
    );
  }

}
