import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../utility/Base.dart';

class AddSinger extends StatefulWidget {
  const AddSinger({Key? key}) : super(key: key);

  @override
  State<AddSinger> createState() => _AddSingerState();
}

class _AddSingerState extends State<AddSinger> {

  bool ready=false;
  bool loading=true;
  List singerList=[];

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void getSinger(Map chosenSinger)async{
    controllers[1].text=chosenSinger['singer_name'];
    controllers[2].text=chosenSinger['birth_date'].toString().split('T')[0];
    controllers[3].text=chosenSinger['img_link'];

    singerName=chosenSinger['singer_name'];
    dateOfBirth=chosenSinger['birth_date'].toString().split('T')[0];
    imgLink=chosenSinger['img_link'];
    setState(() {});
  }
  void getAllSingers()async{
    var rr= await http.get(Uri.parse('$ServerAddress/select/allSingers'));
    //print(rr.body);
    singerList=jsonDecode(rr.body);
    setState(() {
      ready=true;
      loading=false;
    });
  }

  void insertSinger() async{
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/singer'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'singerName': singerName,
          'birthDate': dateOfBirth,
          'imgLink': imgLink,
          'Token': SessionID
        }));

    print(r.body);

    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to insert , check input.";
    }else{
      setState(() {
        Navigator.pop(context);
      });
    }

    setState(() {
      loading = true;
      ready = true;
    });
  }

  void updateSinger() async{
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/update/singer'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'singerName': singerName,
          'birthDate': dateOfBirth,
          'imgLink': imgLink,
          'singerId': singerId,
          'Token': SessionID
        }));

    print(r.body);

    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to update , check input.";
    }else{
      setState(() {
        Navigator.pop(context);
      });
    }

    setState(() {
      loading = true;
      ready = true;
    });

  }


  final formKey=GlobalKey<FormState>();
  String singerName='';
  String dateOfBirth='';
  String imgLink='';
  int singerId=-1;
  String? Error;

  @override
  void initState() {
    super.initState();
    getAllSingers();
  }

  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(
        title: Text('Add Singer',),centerTitle: true,backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Visibility(
                  visible: Error != null,
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      child: Text(
                        Error ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],

                      ),
                    ),
                  ),
                ),

                RawAutocomplete(
                  focusNode: FocusNode(),
                  textEditingController: controllers[0],
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      List<String> fk_flutter = [];
                      fk_flutter.addAll(singerList.map((e) => e['singer_name']));
                      return fk_flutter;
                    }else{
                      List<String> matches = <String>[];
                      matches.addAll(singerList.map((e) => e['singer_name']));

                      matches.retainWhere((s){
                        return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },

                  onSelected: (String selection) {
                    singerList.forEach((element) {
                      if(element['singer_name']==selection){
                        singerId=element['id'];
                        getSinger(element);
                      }
                    });
                    print(singerId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      decoration: const InputDecoration(
                          hintText: 'Singer name',
                          border: InputBorder.none
                      ),
                      controller: textEditingController,
                      focusNode: focusNode,

                    );
                  },

                  optionsViewBuilder: (BuildContext context, void Function(String) onSelected,
                      Iterable<String> options) {
                    return Material(
                        child:SizedBox(
                            height: 200,
                            child:SingleChildScrollView(
                                child: Column(
                                  children: options.map((opt){
                                    return InkWell(
                                        onTap: (){
                                          onSelected(opt);
                                        },
                                        child:Container(
                                            padding: EdgeInsets.only(right:60),
                                            child:Card(
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(10),
                                                  child:Text(opt),
                                                )
                                            )
                                        )
                                    );
                                  }).toList(),
                                )
                            )
                        )
                    );
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Singer data (id: $singerId)",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],

                      ),
                    ),
                  ),
                ),

                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[1],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Singer Name cannot be empty';
                    } if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Singer name',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    singerName=input;
                  },
                ),
                SizedBox(height: 15,),

                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[2],
                  validator: (input){
                    if(!RegExp(r'^([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))+$').hasMatch(input!)){
                      return 'Enter correct Date of birth (YYYY-MM-DD)';
                    }else {return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'singer birthday',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    dateOfBirth= input;
                  },
                ),
                SizedBox(height: 15,),

                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[3],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Image link cannot be empty';
                    }
                    else{return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Singer image link',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    imgLink=input;
                  },
                ),
                SizedBox(height: 15,),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          insertSinger();
                        }
                      },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                        child:  const Text('Add',
                          style: TextStyle(color: Colors.white),),
                      ),
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          if (singerId == -1){
                            setState(() {
                              Error = "Select singer first.";
                            });
                            return;
                          }
                          updateSinger();
                        }
                      },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                        child:  const Text('Update',
                          style: TextStyle(color: Colors.white),),
                      )
                    ]
                )
              ],
            ),
          ),
        ),
      ),
    );}else{return LoadingPage();}
  }
}