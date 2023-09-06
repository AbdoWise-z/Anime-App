import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Widgets/LoadingPage.dart';
import '../../utility/Base.dart';

class Song extends StatefulWidget {

  @override
  State<Song> createState() => _SongState();
}

class _SongState extends State<Song> {
  bool loading=false;
  bool ready=true;
  List singerData=[];

  void getSinger()async{

    setState(() {
      loading=true;
      ready=false;
    });
    var r = await http.get(Uri.parse('$ServerAddress/select/singerBySong?songId=${data['id']}'));

    print(r.body);
    singerData=jsonDecode(r.body);
    //print(singerData);
    setState(() {
      loading=false;
      ready=true;
      Navigator.pushNamed(context, '/anime/Pages/SingerPage',arguments: singerData);
    });

  }

  Map data={};

  @override
  Widget build(BuildContext context) {
    data= ModalRoute.of(context)!.settings.arguments as Map;

    //print(data);
     if(ready){
       return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('Song Details'),backgroundColor: Colors.black,),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Name: ${data['song_name']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Date Published: ${data['date_published'].toString().split('T')[0]}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            trailing: Text('Press for details',style: TextStyle(color: Colors.black38),),
            title: Text('Singer',style: TextStyle(fontWeight: FontWeight.bold),),
            onTap: getSinger,
          ),
        ],
      ),
    );}else{return LoadingPage();}
  }
}
