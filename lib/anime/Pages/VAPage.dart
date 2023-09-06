import 'package:flutter/material.dart';

class VA extends StatefulWidget {

  bool loading =true;
  bool ready=false;

  @override
  State<VA> createState() => _VAState();
}

class _VAState extends State<VA> {
  @override
  Map data={};


  @override
  Widget build(BuildContext context) {
    data= ModalRoute.of(context)!.settings.arguments as Map;
    //print(data);
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('${data['vaName']}'),backgroundColor: Colors.black12,),
      body: ListView(
        children: [
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(data['vaImgLink'])
                )
            ),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Name: ${data['vaName']}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.circle,color: Colors.black,size: 10,),
            title: Text('Birth Date: ${data['vaBirthDate'].toString().split('T')[0]}',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }
}
