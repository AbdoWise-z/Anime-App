import 'dart:convert';

import 'package:anime/login/LoginPage.dart';
import 'package:anime/login/RegisterPage.dart';
import 'package:anime/utility/Base.dart';
import 'package:anime/Widgets/LoadingCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static const int LOGIN_PAGE = 0;
  static const int REGISTER_PAGE = 1;

  int page = LOGIN_PAGE;
  bool loading = false;

  String msg = "";

  bool loghasNameError = false;
  String logNameError = "";

  bool loghasPassError = false;
  String logPassError = "";

  bool reghasNameError = false;
  String regNameError = "";

  bool reghasPassError = false;
  String regPassError = "";

  bool reghasEmailError = false;
  String regEmailError = "";


  void doLogin(String user , String pass , bool rem) async{
    loghasNameError = false;
    loghasPassError = false;

    user = user.trim();
    pass = pass.trim();

    if (user.isEmpty){
      setState(() {
        page = LOGIN_PAGE;
        loghasNameError = true;
        logNameError = "Username cannot be empty";
      });
      return;
    }

    if (user.contains(" ")){
      setState(() {
        page = LOGIN_PAGE;
        loghasNameError = true;
        logNameError = "username cannot have white spaces";
      });
      return;
    }

    if (pass.isEmpty){
      setState(() {
        page = LOGIN_PAGE;
        loghasPassError = true;
        logPassError = "password cannot be empty";
      });
      return;
    }

    if (pass.contains(" ")){
      setState(() {
        page = LOGIN_PAGE;
        loghasPassError = true;
        logPassError = "password cannot have white spaces";
      });
      return;
    }

    loading = true;
    msg = "Logging in , please wait ..";
    setState(() {
    });

    String url = "$ServerAddress/login";
    print("Running: $url");

    try {

      var res = await http.post(Uri.parse(url) ,
        headers: {
          "content-type" : "application/json",
        },
        body : jsonEncode({
          "username" : user,
          "password" : pass
          //"email"    : "test_acc@gmail.com"
        }).toString(),
      );

      print(res.body);

      Map data = jsonDecode(res.body);

      if (data["STATUS"] == 1){
        SessionID = data["session_id"];

        CurrentUser.Attr = data["user"]["admin"];
        CurrentUser.ID = data["user"]["id"];
        CurrentUser.name = user;

        if (rem) {
          final pref = await SharedPreferences.getInstance();
          await pref.setString("SessionID", SessionID); //save the current "SessionID"
        }

        setState(() {
          Navigator.pushReplacementNamed(context, "/anime/Home");
        });

        //Navigator.pushReplacementNamed(context, "/admin/enq_list"); //for debugging
        return;
      }else if (data["STATUS"] == 2) {
        SessionID = data["session_id"];
        CurrentUser.Attr = data["user"]["admin"];
        CurrentUser.ID = data["user"]["id"];
        CurrentUser.name = user;
        setState(() {
          Navigator.pushNamed(context, "/login/banned" , arguments: {"reason" : data["ban"]["ban_reason"]});
        });
        loading = false;
        setState(() {});
        return;
      } else{
        loading = false;
        logPassError = "Wrong username or password.";
        loghasPassError = true;
        setState(() {});
        return;
      }
    }catch (e){
      print(e);
      loading = false;
      logPassError = "Failed to connect to server.";
      loghasPassError = true;
      setState(() {});
      return;
    }
  }

  void Register(String name , String pass , String email) async {
    reghasPassError = false;
    reghasEmailError = false;
    reghasNameError = false;

    name = name.trim();
    pass = pass.trim();
    email = email.trim();

    if (name.isEmpty){
      setState(() {
        page = REGISTER_PAGE;
        reghasNameError = true;
        regNameError = "Username cannot be empty";
      });
      return;
    }

    if (name.contains(" ")){
      setState(() {
        page = REGISTER_PAGE;
        reghasNameError = true;
        regNameError = "username cannot have white spaces";
      });
      return;
    }

    if (pass.isEmpty){
      setState(() {
        page = REGISTER_PAGE;
        reghasPassError = true;
        regPassError = "password cannot be empty";
      });
      return;
    }

    if (pass.contains(" ")){
      setState(() {
        page = REGISTER_PAGE;
        reghasPassError = true;
        regPassError = "password cannot have white spaces";
      });
      return;
    }

    if (email.isEmpty){
      setState(() {
        page = REGISTER_PAGE;
        reghasEmailError = true;
        regEmailError = "Email cannot be empty";
      });
      return;
    }

    if (email.contains(" ")){
      setState(() {
        page = REGISTER_PAGE;
        reghasEmailError = true;
        regEmailError = "Email cannot have white spaces";
      });
      return;
    }

    if (!email.contains("@") || email.split("@").length > 2){
      setState(() {
        page = REGISTER_PAGE;
        reghasEmailError = true;
        regEmailError = "Invalid email address";
      });
      return;
    }

    loading = true;
    msg = "Creating account , please wait ..";
    setState(() {
    });

    String url = "$ServerAddress/register";
    print("Running: $url");

    try {

      var res = await http.post(Uri.parse(url) ,
        body : jsonEncode({
          "username" : name,
          "password" : pass,
          "email"    : email
        }),
        headers: {
          "content-type" : "application/json",
        },
      );

      print(res.body);

      Map data = jsonDecode(res.body);


      if (data["status"] == 1){
        doLogin(name, pass, false);
      }else{
        if (data["detail"].toString().contains("email")){
          regEmailError = "this email is already used";
          reghasEmailError = true;
          loading = false;
          setState(() {});
        } else {
          regNameError = "this username is already used";
          reghasNameError = true;
          loading = false;
          setState(() {});
        }
      }
    }catch (e){
      print(e);
      loading = false;
      regEmailError = "Failed to connect to server.";
      reghasEmailError = true;
      setState(() {});
      return;
    }
  }

  void tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    SessionID = pref.getString("SessionID") ?? "";
    //await pref.setString("SessionID", "");
    print("Saved sid: $SessionID");
    //SessionID = "";
    //SessionID = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7IlNUQVRVUyI6MSwidXNlciI6eyJpZCI6NTIsInVzZXJuYW1lIjoiQWRtaW4wMDEiLCJwYXNzd29yZCI6IkFkbWluMDAxIiwiZW1haWwiOiJBZG1pbjAwMUBlbWFpbC5jb20iLCJhZG1pbiI6MSwiZGF0ZV9jcmVhdGVkIjoiMjAyMi0xMS0yN1QyMDozMDoxMS4wMDBaIn0sImJhbm5lZCI6MH0sImlhdCI6MTY3MjIzNTYzNSwiZXhwIjoxNjcyMjM2NjM1fQ.FHuYf3j6z-JqwNvBHt9fnnIdgga6rEYYHh5Wx54XzOE";
    if (SessionID.isNotEmpty){
      loading = true;
      msg = "Logging in , please wait ..";
      setState(() {
      });
      String url = "$ServerAddress/login";
      print("Running: $url");

      try {
        var res = await http.post(Uri.parse(url) ,
          body : jsonEncode({
            "Token" : SessionID,
          }),
          headers: {
            "content-type" : "application/json",
          },
        );

        Map data = jsonDecode(res.body);

        if (data["status"] == 1){
          SessionID = data["session_id"];
          CurrentUser.Attr = data["account_type"];
          CurrentUser.ID = data["user_id"];
          CurrentUser.name = data["username"];
          await pref.setString("SessionID", SessionID); //save the new "SessionID"
          setState(() {
            Navigator.pushReplacementNamed(context, "/anime/Home");
          });
          return;
        }else{
          await pref.setString("SessionID", "");
          loading = false;
          logPassError = "Session Expired";
          loghasPassError = true;
          setState(() {});
          return;
        }

      }catch (e){
        print(e);
        loading = false;
        logPassError = "Failed to connect to server.";
        loghasPassError = true;
        setState(() {});
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child:
            Stack(
              children: [
                Visibility(
                  visible: page == LOGIN_PAGE,
                  child: AbsorbPointer(
                    absorbing: loading,
                    child: LoginPage(
                      UserError: logNameError,
                      PasswordError: logPassError,
                      hasUserError: loghasNameError,
                      hasPasswordError: loghasPassError,
                      (String name , String pass , bool rem) { //login
                        doLogin(name, pass , rem);
                      },
                      () { //register
                        setState(() {
                          page = REGISTER_PAGE;
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: page == REGISTER_PAGE,
                  child: AbsorbPointer(
                    absorbing: loading,
                    child: RegisterPage(
                        UserError: regNameError,
                        PasswordError: regPassError,
                        hasUserError: reghasNameError,
                        hasPasswordError: reghasPassError,
                        EmailError: regEmailError,
                        hasEmailError: reghasEmailError,

                        (String name , String pass , String email) { //login
                          Register(name, pass , email);
                        },
                        () {
                          setState(() {
                            page = LOGIN_PAGE;
                          });
                        }
                    ) ,
                  ),
                ),

                Visibility(
                  visible: loading,
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LoadingCard(msg: msg),
                  )),
                ),
              ],
            )
      ),
    );
  }
}
