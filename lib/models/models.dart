class UserData {
  String userId;
  String userEmail;
  String password;
  String userName;

  bool get isAuth {
    return userEmail != null;
  }
}

class KidData {
  String kidId;
  String kidName;
}

class KidTodoList {
  String id;
  String kidsId;
  String whenDate;
  String taskId;
  String checkDate;
  String task;
}