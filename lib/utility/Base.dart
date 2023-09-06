import 'dart:convert';

import 'package:anime/utility/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

const String ServerAddress = "https://dbprojectserver.onrender.com";


bool isAdmin(){
  return CurrentUser.Attr == 1;
}

String SessionID = "";

User CurrentUser = User(
  name: "Test",
  Attr: 1,
);

List<int> gList = [];

const String CMD_LOGIN = "Login";
const String CMD_INSERT = "insert";
const String CMD_REGISTER = "Register";

String CreateCommand(Object cmd , {Map<String,Object> params = const {}}){
  String ret = "cmd=$cmd";

  params.forEach((key, value) {
    ret += "&$key=$value";
  });

  return ret;
}


final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();


