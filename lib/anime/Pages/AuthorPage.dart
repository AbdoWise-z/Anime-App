import 'package:flutter/material.dart';

class Author extends StatefulWidget {

  bool loading =true;
  bool ready=false;

  @override
  State<Author> createState() => _AuthorState();
}

class _AuthorState extends State<Author> {
  @override
  Map data={};


  @override
  Widget build(BuildContext context) {
    data= ModalRoute.of(context)!.settings.arguments as Map;
    //print(data);
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('${data['author_name']}'),backgroundColor: Colors.black12,),
      body: ListView(
        children: [
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(data['img_link'])
              )
            ),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Name: ${data['author_name']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Birth Date: ${data['birth_date'].toString().split('T')[0]}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Years Active: ${data['years_active'].toString()}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Anime Type: ${data['anime_genre']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),

        ],
      ),
    );
  }
}
