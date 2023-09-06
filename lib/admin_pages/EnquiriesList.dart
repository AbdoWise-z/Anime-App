
import 'dart:convert';

import 'package:anime/Widgets/LoadingPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utility/Base.dart';

class EnquiriesList extends StatefulWidget {
  const EnquiriesList({Key? key}) : super(key: key);

  @override
  State<EnquiriesList> createState() => _EnquiriesListState();
}

class _EnquiriesListState extends State<EnquiriesList> {
  List _Enquiries = [];
  bool _loading = false;
  String message = "Loading Enquiries...";
  Future<void> loadEnquiries() async {
    setState(() {
      _loading = true;
      message = "Loading Enquiries...";
    });

    _Enquiries.clear();
    String url = "$ServerAddress/select/allEnquiries";
    print("Running: $url");

    try {
      var res = await http.post(Uri.parse(url),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                "Token" : SessionID,
              }));

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");

      _Enquiries = jsonDecode(res.body)["data"];
    }catch (e){
      print(e);
    }

    setState(() {
      _loading = false;
    });
  }


  void deleteEnq(int id) async {
    setState(() {
      _loading = true;
      message = "Deleting..";
    });



    try {
      String url = "$ServerAddress/delete/enquiry";
      print("Running: $url");

      var res = await http.post(Uri.parse(url),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                "Token" : SessionID,
                "enquiryId" : id  ,
              }));

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");

      //since you can't access this page unless you're admin then I can assume the result is always 1

      _Enquiries.removeWhere((element) => element["id"] == id);

    }catch (e){
      print(e);
    }

    setState(() {
      _loading = false;
    });
  }

  void unBan(int eID , int uID) async{
    setState(() {
      _loading = true;
      message = "un banning ..";
    });

    try {
      String url = "$ServerAddress/delete/enquiry";
      print("Running: $url");

      var res = await http.post(Uri.parse(url),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                "Token" : SessionID,
                "enquiryId" : eID  ,
              }));

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");

      url = "$ServerAddress/delete/ban";
      print("Running: $url");

      res = await http.post(Uri.parse(url),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                "Token" : SessionID,
                "userId" : uID,
              }));

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");


      //since you can't access this page unless you're admin then I can assume the result is always 1

      _Enquiries.removeWhere((element) => element["id"] == eID);
    }catch (e){
      print(e);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadEnquiries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enquiries"
        ),
        actions: [
          IconButton(
            onPressed: () { if (!_loading) loadEnquiries(); },
            icon: Icon(
              Icons.refresh_rounded,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: loadEnquiries,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              //main page here
              child: ListView.builder(
                itemBuilder: (bc , i) => EnquiryListItem(
                  msg: _Enquiries[i]["message"],
                  type: _Enquiries[i]["type"],
                  uID: _Enquiries[i]["user_id"],
                  eID: _Enquiries[i]["id"],
                  uName: _Enquiries[i]["username"],
                  delete: deleteEnq,
                  un_ban: unBan,
                ),
                itemCount: _Enquiries.length,
              ),
            ),
          ),

          Visibility(
            visible: _loading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: LoadingPage(
                msg : message,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnquiryListItem extends StatefulWidget {
  final int type;
  final String msg;
  final String uName;
  final int uID;
  final int eID;
  final Function(int) delete;
  final Function(int , int) un_ban;

  const EnquiryListItem({
    Key? key,
    this.type = -1,
    this.msg = "This user is a bit-- pls ban him",
    this.uName = "Test user",
    this.uID = 0,
    this.eID = -1,
    required this.delete,
    required this.un_ban,
  }) : super(key: key);

  @override
  State<EnquiryListItem> createState() => _EnquiryListItemState();
}

class _EnquiryListItemState extends State<EnquiryListItem> {
  String _getTextForType(){
    return widget.type == 0 ? "Anime" : "User ban";
  }

  Widget _CreateActionsForType(){
    return widget.type == 0 ?
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: "Delete Enquiry",
          onPressed: () {widget.delete(widget.eID);},
          icon: Icon(
            Icons.delete,
            size: 24,
            color: Colors.blueAccent,
          ),
          padding: EdgeInsets.all(0),

        ),
      ],
    ) :
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: "Delete Enquiry",
          onPressed: () {
            widget.delete(widget.eID);
          },
          icon: Icon(
            Icons.delete,
            size: 24,
            color: Colors.blueAccent,
          ),
          padding: EdgeInsets.all(0),

        ),
        IconButton(
          tooltip: "un ban",
          onPressed: () {
            widget.un_ban(widget.eID , widget.uID);
          },
          icon: Icon(
            Icons.disabled_by_default_outlined,
            size: 24,
            color: Colors.blueAccent,
          ),
          padding: EdgeInsets.all(0),

        ),
      ],

    )
    ;
  }
  bool _expained = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _getTextForType(),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _expained = !_expained;
                    });
                  },
                  icon: Icon( _expained ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined),
                  splashRadius: 20,
                )
              ],
            ),
            Visibility(
              visible: _expained,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From: ${widget.uName} , UID: ${widget.uID}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700]
                    ),
                  ),
                  Text(
                    widget.msg,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[900]
                    ),
                  ),
                  Divider(
                  ),
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700]
                    ),
                  ),
                  _CreateActionsForType(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

