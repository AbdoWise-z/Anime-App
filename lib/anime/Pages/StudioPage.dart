import 'package:flutter/material.dart';

class Studio extends StatefulWidget {



  @override
  State<Studio> createState() => _StudioState();
}

class _StudioState extends State<Studio> {
  @override
  Map data={};


  @override
  Widget build(BuildContext context) {
    data= ModalRoute.of(context)!.settings.arguments as Map;
    //print(data);

    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('${data['studio_name']}'),backgroundColor: Colors.black12,),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Name: ${data['studio_name']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Founder: ${data['founder']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Date Created: ${data['year_founded']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          //ListTile(
            //leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            //title: Text('Popular Anime',style: TextStyle(fontWeight: FontWeight.bold),), //TODO:
            //onTap: (){
              //Navigator.pushNamed(context, '/Anime',arguments: { 'id': data['popularAnimeId']});
            //},
         // ),
        ],
      ),
    );
  }
}
