import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utility/Base.dart';

class BannedPage extends StatefulWidget {
  const BannedPage({Key? key}) : super(key: key);

  @override
  State<BannedPage> createState() => _BannedPageState();
}

class _BannedPageState extends State<BannedPage> {
  bool _submitting = false;
  void do_submit_enquiry() async {
    if (_submitting) return;
    _submitting = true;

    try {
      String url = "$ServerAddress/insert/enquiry";
      print("Running: $url");

      var res = await http.post(Uri.parse(url) ,
        headers: {
          "content-type" : "application/json",
        },
        body : jsonEncode({
          "Token" : SessionID ,
          "type" : 1,
          "message" : "Please un ban me"
        }).toString(),
      );

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");

    }catch (e){

    }
    Navigator.pop(context);
  }

  String reason = "";
  var args;
  _load_function(args) async {
    if (args == null){
      return;
    }

    Map data = args as Map;
    reason = data["reason"];
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
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SizedBox (
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  splashColor: Colors.black,
                ),
              ),
              const Expanded(flex: 1,child: SizedBox() ,),
              const Icon(
                Icons.warning_amber,
                size: 150,
                color: Colors.amber,
              ),
              const Text(
                "banned for",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey
                ),
              ),
              Text(
                reason,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black
                ),
              ),
              const Expanded(flex: 1,child: SizedBox() ,),

              Theme(
                data: ThemeData(splashColor: Colors.red[200]),
                child: Material(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.hardEdge,
                  color: const Color(0x1200ff00),
                  child: InkWell(
                    child: const SizedBox(width: 200 , height: 40,
                      child: Center(
                        child: Text(
                          "Submit Enquiry",
                        ),
                      ),
                    ),
                    onTap: () {
                      do_submit_enquiry();
                    },
                  ),
                ),
              ),

              const Expanded(flex: 1,child: SizedBox() ,),
            ],
          ),
        ),
      ),
    );
  }
}
