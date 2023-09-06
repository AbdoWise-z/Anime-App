
import 'dart:convert';

import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utility/Base.dart';

class EnquiryPage extends StatefulWidget {
  const EnquiryPage({Key? key}) : super(key: key);

  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  bool _loading  = false;
  String _msg = "";

  void do_submit_enquiry() async {
    setState(() {
      _loading = true;
    });

    try {
      String url = "$ServerAddress/insert/enquiry";
      print("Running: $url");

      var res = await http.post(Uri.parse(url) ,
        headers: {
          "content-type" : "application/json",
        },
        body : jsonEncode({
          "Token" : SessionID ,
          "type" : 0,
          "message" : _msg
        }).toString(),
      );

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");

      var data = jsonDecode(res.body);

      if (data["STATUS"] == 1){
        setState(() {
          Navigator.pop(context);
        });
      }else{
        Error = "Failed to submit.";
      }
    }catch (e){

    }

    //Navigator.pop(context);
    setState(() {
      _loading = false;
    });
  }

  String? Error;

  @override
  Widget build(BuildContext context) {
    if (_loading){
      return const LoadingPage(msg : "Submitting , please wait ....");
    }else{
      return Scaffold(
        appBar: AppBar(
          title: const Text("Enquiry Page"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RippleTextFormField(
                maxLength: 100,
                maxLines: 4,
                minLines: 1,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                background: Color(0x10000000),
                onChanged: (txt) => _msg = txt,
                decoration: InputDecoration(
                  hintText: "Enter Enquiry",
                  errorText: Error,
                  border: InputBorder.none
                ),
              ),
            ),

            const SizedBox(height: 45,)
            ,
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
                    if (_msg.trim().length == 0){
                      setState(() {
                        Error = "Message cannot be empty.";
                      });
                      return;
                    }
                    do_submit_enquiry();
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
