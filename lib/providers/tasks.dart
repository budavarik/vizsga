import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rest_api_login/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:rest_api_login/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tasks with ChangeNotifier {
  var MainUrl = Api.authUrl;
  List<String> tasks = [];

  Future<List<String>> getTasksApi() async {
    tasks.clear();
    try {
      //final url = '${MainUrl}/accounts:${endpoint}?key=${AuthKey}';
      final url = Uri.parse('${MainUrl}/get_allTask.php');

      final response = await http.post(url,
          body: json.encode({
          }));

      final responseData = json.decode(response.body);

      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException("The statusCode is not equal 200!");
      }

      final prefs = await SharedPreferences.getInstance();
      tasks = [];
      for (int i = 0; i < responseData.length; i++) {
        String tmpTaskData = json.encode({
          'id': responseData[i]['id'],
          'task': responseData[i]['task'],
        });
        tasks.add(tmpTaskData);
      }

      prefs.setStringList('tasks', tasks);

      print('check' + tasks.toString());
    } catch (e) {
      throw e;
    }
    return tasks;
  }

  Future<void> insertTodo(String task) async {
    try {
      final url = Uri.parse('${MainUrl}/insert_todo.php?task=$task');

      final response = await http.post(url,
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

  Future<void> insertTodoList(String kidsId, String whenDate, String taskId) async {
    try {
      final url = Uri.parse('${MainUrl}/insert_todoList.php?kidsId=$kidsId&whenDate=$whenDate&taskId=$taskId');

      final response = await http.post(url,
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





}


