import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:vizsga_feladat/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:vizsga_feladat/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class Auth with ChangeNotifier {
  var MainUrl = Api.authUrl;
  var AuthKey = Api.authKey;
  UserData parentData = new UserData();

  Future<void> logout() async {
    parentData.userEmail = "";

    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  Future<bool> tryautoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      return false;
    }
/*
    final extractedUserData =
        json.decode(pref.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    parentData.userId = extractedUserData['id'];
    parentData.userEmail = extractedUserData['email'];
    parentData.userName = extractedUserData['name'];
*/
    notifyListeners();
    var extractedUserData = json.decode(pref.getString('userData')) as Map<String, Object>;
    return (extractedUserData['kidName'] != null && extractedUserData['kidName'] != "");
  }


  Future<void> Authentication(
      String email, String password) async {
    try {
      //final url = '${MainUrl}/accounts:${endpoint}?key=${AuthKey}';
      final url = Uri.parse('${MainUrl}/get_parent.php?email=$email&password=$password');

      final response = await http.post(url,
          body: json.encode({

          }));

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException("The statusCode is not equal 200!");
      }
      parentData.userId = responseData[0]['id'];
      parentData.userEmail = responseData[0]['email'];
      parentData.userName = responseData[0]['name'];

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'id': parentData.userId,
        'email': parentData.userEmail,
        'name': parentData.userName,
      });

      prefs.setString('userData', userData);

      print('check' + userData.toString());
    } catch (e) {
      throw e;
    }
  }

  Future<void> KidAuthentication(
      String email, String password, String kidName) async {
    try {
      //final url = '${MainUrl}/accounts:${endpoint}?key=${AuthKey}';
      final url = Uri.parse('${MainUrl}/get_kid.php?email=$email&name=$kidName&password=$password');

      final response = await http.post(url,
          body: json.encode({
            'returnSecureToken': true
          }));

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException(responseData['error']['message']);
      }
      parentData.userId = responseData[0]['id'];
      parentData.userEmail = responseData[0]['email'];
      parentData.userName = responseData[0]['name'];

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'id': parentData.userId,
        'email': parentData.userEmail,
        'name': parentData.userName,
        'kidId': responseData[0]['kidId'],
        'kidName': responseData[0]['kidName'],
      });

      prefs.setString('userData', userData);

      print('check' + userData.toString());
    } catch (e) {
      throw e;
    }
  }


  Future<void> NewParent(
      String email, String password, String name, String childName) async {
    try {
      final url = Uri.parse('${MainUrl}/insert_parent.php?email=$email&password=$password&name=$name&childName=$childName');

      final response = await http.post(url,
          body: json.encode({

          }));

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode != 200) {
        throw HttpException(responseData['error']['message']);
      }
      parentData.userId = responseData[0]['id'];
      parentData.userEmail = responseData[0]['email'];
      parentData.userName = responseData[0]['name'];

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'id': parentData.userId,
        'email': parentData.userEmail,
        'name': parentData.userName,
      });

      prefs.setString('userData', userData);

      print('check' + userData.toString());
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(String email, String password) {
    return Authentication(email, password);
  }

  Future<void> signUp(String email, String password, String name, String childName) {
    return NewParent(email, password, name, childName);
  }

  Future<void> kidLogin(String email, String password, String kidName) {
    return KidAuthentication(email, password, kidName);
  }

}
