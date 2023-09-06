import 'dart:convert';

import 'package:anime/Widgets/LoadingPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utility/Base.dart';

class BanPage extends StatefulWidget {
  const BanPage({Key? key})
      : super(key: key);

  @override
  State<BanPage> createState() => _BanPageState();
}

class _BanPageState extends State<BanPage> {
  int uID = -1;
  String uName = "";
  bool _loading = false;
  String? err = null;
  String reason = "";

  var args;
  _load_function(args) async {
    if (args == null){
      return;
    }

    Map data = args as Map;
    uID = data["uID"];
    uName = data["uName"];
  }

  void submit_ban() async {
    setState(() {
      _loading = true;
    });

    String url = "$ServerAddress/insert/Ban";
    print("Running: $url");

    try {

      var res = await http.post(Uri.parse(url) ,
        headers: {
          "content-type" : "application/json",
        },
        body : jsonEncode({
          "Token" : SessionID ,
          "userId" : uID,
          "banReason" : reason
        }).toString(),
      );

      print(res.body);

      Map data = jsonDecode(res.body);

      if (data["STATUS"] == 1){
        err = null;
        Navigator.pop(context);
      } else {
        err = "User already banned.";
      }
    }catch (e){
      err = "Server error";
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // future that allows us to access context. function is called inside the future
    // otherwise it would be skipped and args would return null
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(context)!.settings.arguments;
      });
      _load_function(args);
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: const Text("Ban form"),
        ),
        body: Stack(
            children:[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Banning user: $uName , UID: $uID",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,

                        ),
                      ),
                    ),
                    Theme(
                      data: ThemeData(splashColor: Color(0x610080FF)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Material(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          clipBehavior: Clip.hardEdge,
                          color: const Color(0x08000000),
                          child: InkWell(
                            child: TextFormField(
                              onChanged: (t) => reason = t,
                              maxLength: 100,
                              maxLines: 3,
                              minLines: 1,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                hintText: "Enter reason",
                                border: InputBorder.none,
                                errorText: err,
                              ),
                            ),
                            onTap: () { //useless because fk flutter
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 0,
                      height: 24,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        submit_ban();
                      },
                      child: const Text("Submit"),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: _loading,
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: LoadingPage(msg: "Submitting please wait."),
                ),
              )
            ]
        ),
      );
  }
}
