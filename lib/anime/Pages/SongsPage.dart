import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SongsPage extends StatefulWidget {
  const SongsPage({Key? key}) : super(key: key);


  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {


  @override
  Widget build(BuildContext context) {
    List data = ModalRoute.of(context)!.settings.arguments as List;

    return Scaffold(
      appBar: AppBar(title: Text('Songs'),centerTitle: true,backgroundColor: Colors.black,),
      body: ListView(
        children:
          data.map((e) => Card(
            elevation: 20,
            child: ListTile(
              title: Text(e['song_name'],
                style: TextStyle(
                fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
              ),
              leading: Icon(Icons.music_note,color: Colors.black,),
              onTap: (){
                Navigator.pushNamed(context, '/anime/Pages/Song',arguments: e);
              },
            ),
          )).toList()
        ,
      ),
    );
  }
}
