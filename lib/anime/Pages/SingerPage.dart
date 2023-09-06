import 'package:flutter/material.dart';

class Singer extends StatefulWidget {



  @override
  State<Singer> createState() => _SingerState();
}

class _SingerState extends State<Singer> {
  @override
  List data=[];


  @override
  Widget build(BuildContext context) {
    data= ModalRoute.of(context)!.settings.arguments as List;
    //print(data);
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('Singer Details'),backgroundColor: Colors.black,),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(data[0]['img_link']),
                      fit: BoxFit.fill
                  )
              ),
            ),
          ),
              ListTile(
                leading: Icon(Icons.circle,color: Colors.black,size: 10,),
                title: Text('Name: ${data[0]['singer_name']}',style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              ListTile(
                leading: Icon(Icons.circle,color: Colors.black,size: 10,),
                title: Text('Birth Date: ${data[0]['birth_date'].toString().split('T')[0]}',style: TextStyle(fontWeight: FontWeight.bold),),
              ),
        ],
      ),
    );
  }
}
