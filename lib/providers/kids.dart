import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rest_api_login/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:rest_api_login/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_api_login/utils/util.dart';
import '/models/models.dart';

class Kids with ChangeNotifier {
  Util util = new Util();
  List<String> kidData = [];
  List<String> kidTodoList = [];
  var MainUrl = Api.authUrl;


  Future<void> getKidsApi(String parentId) async {
    try {
      //final url = '${MainUrl}/accounts:${endpoint}?key=${AuthKey}';
      final url = Uri.parse('${MainUrl}/get_parentKids.php?parentId=$parentId');

      final response = await http.post(url,
          body: json.encode({
          }));

      final responseData = json.decode(response.body);

      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException("The statusCode is not equal 200!");
      }

      final prefs = await SharedPreferences.getInstance();
      kidData = [];
      for (int i = 0; i < responseData.length; i++) {
        String tmpkidData = json.encode({
          'id': responseData[i]['id'],
          'name': responseData[i]['name'],
        });
        kidData.add(tmpkidData);
      }

      prefs.setStringList('kidsData', kidData);

      print('check' + kidData.toString());
    } catch (e) {
      throw e;
    }
  }

  Future<void> getKidsTodosApi(String kidsId, String fromWhen, String toWhen) async {
    try {
      final url = Uri.parse('${MainUrl}/get_todoList.php?kidsId=$kidsId&fromWhen=$fromWhen&toWhen=$toWhen');

      final response = await http.post(url,
          body: json.encode({
          }));

      final responseData = json.decode(response.body);

      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException("The statusCode is not equal 200!");
      }

      final prefs = await SharedPreferences.getInstance();
      kidTodoList = [];
      if (responseData != "0") {
        for (int i = 0; i < responseData.length; i++) {
          var parsedDate = DateTime.parse(responseData[i]['whenDate']);
          var dayName = dateFormatter(parsedDate);

          String tmpkidData = json.encode({
            'id': responseData[i]['todoListId'],
            'kidsId': responseData[i]['todoListKidsId'],
            'whenDate': responseData[i]['whenDate'],
            'taskId': responseData[i]['taskId'],
            'checkDate': responseData[i]['checkDate'],
            'task': responseData[i]['taskName'],
            'dateFull': dayName,
          });
          kidTodoList.add(tmpkidData);
        }
      }
      prefs.setStringList('kidTodoList', kidTodoList);

      print('check' + kidTodoList.toString());
    } catch (e) {
      throw e;
    }
  }

  Future<void> delKidTodoDataApi(String todoListId) async {
    try {
      //final url = '${MainUrl}/accounts:${endpoint}?key=${AuthKey}';
      final url = Uri.parse('${MainUrl}/del_kidTodo.php?todoListId=$todoListId');

      final response = await http.put(url,
          body: json.encode({
          }));

      final responseData = json.decode(response.body);

      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException("The statusCode is not equal 200!");
      }

    } catch (e) {
      throw e;
    }
  }





  String dateFormatter(DateTime date) {
    dynamic dayData =
        '{ "1" : "Hétfő", "2" : "Kedd", "3" : "Szerda", "4" : "Csütörtök", "5" : "Péntek", "6" : "Szombat", "7" : "Vasárnap" }';

    dynamic monthData =
        '{ "1" : "Január", "2" : "Február", "3" : "Március", "4" : "Április", "5" : "Május", "6" : "Június", "7" : "Július", "8" : "Augusztus", "9" : "Szeptember", "10" : "Október", "11" : "November", "12" : "December" }';

    var percek = date.minute.toString();
    if (date.minute.toString().length == 1) {
      percek = "0" + date.minute.toString();
    }
    return
        date.year.toString() +
        " " +
        json.decode(monthData)['${date.month}'] +
        " " +
        date.day.toString() +
        ", " +
        json.decode(dayData)['${date.weekday}'] +
        " " +
        date.hour.toString() +
        ":" +
        percek;
  }


  Future<void> getKids(String parentId) {
    return getKidsApi(parentId);
  }

  Future<void> getKidsTodos(String kidsId, String fromWhen, String toWhen) {
    var fromParsedDate = DateTime.parse(fromWhen);
    fromWhen = fromParsedDate.year.toString() + "-" + util.normalizeTimeMin(fromParsedDate.month) + "-" + util.normalizeTimeMin(fromParsedDate.day) + " " + "00:00:00";
    var toParsedDate = DateTime.parse(fromWhen);
    fromWhen = toParsedDate.year.toString() + "-" + util.normalizeTimeMin(toParsedDate.month) + "-" + util.normalizeTimeMin(toParsedDate.day) + " " + "00:00:00";
    return getKidsTodosApi(kidsId, fromWhen, toWhen);
  }

  Future<void> delKidTodoData(String todoListId) {
    return delKidTodoDataApi(todoListId);
  }
}


