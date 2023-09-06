import 'package:anime/Widgets/LoadingPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';

import '../../utility/Base.dart';

class AddStudio extends StatefulWidget {
  const AddStudio({Key? key}) : super(key: key);

  @override
  State<AddStudio> createState() => _AddStudioState();
}

class _AddStudioState extends State<AddStudio> {

  bool ready=false;
  bool loading=true;
  List studioList=[];
  Map chosenStudio={};

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void getStudio(Map chosenStudio)async{
    controllers[1].text=chosenStudio['studio_name'];
    controllers[2].text=chosenStudio['founder'];
    controllers[3].text=chosenStudio['year_founded'].toString();

    studioName=chosenStudio['studio_name'];
    founder=chosenStudio['founder'];
    yearFounded=chosenStudio['year_founded'];
  }
  void getAllStudios()async{
    var rr= await http.get(Uri.parse('$ServerAddress/select/allStudios'));
    //print(rr.body);
    studioList=jsonDecode(rr.body);
    setState(() {
      ready=true;
      loading=false;
    });
  }

  void insertStudio()async{
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/studio'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'studioName': studioName,
          'founder': founder,
          'yearFounded': yearFounded,
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
  void updateStudio()async{
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/update/studio'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'studioName': studioName,
          'founder': founder,
          'yearFounded': yearFounded,
          'studioId': studioId,
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
  @override
  void initState() {
    super.initState();
    getAllStudios();
  }

  final formKey=GlobalKey<FormState>();
  String studioName='';
  String founder='';
  int yearFounded=0;
  int studioId=-1;
  String? Error;

  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(
        title: Text('Add Studio',),centerTitle: true,backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                      fk_flutter.addAll(studioList.map((e) => e['studio_name']));
                      return fk_flutter;
                    }else{
                      List<String> matches = <String>[];
                      matches.addAll(studioList.map((e) => e['studio_name']));

                      matches.retainWhere((s){
                        return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },

                  onSelected: (String selection) {
                    studioList.forEach((element) {
                      if(element['studio_name']==selection){
                        studioId=element['id'];
                        getStudio(element);
                        //print(element);
                      }
                    });
                    //print(studioId);
                    //print('You just selected $selection');

                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      decoration: const InputDecoration(
                          hintText: 'Studio Name',
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

                Divider(),

                Container(
                  alignment: Alignment.bottomLeft,

                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Studio Data",
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
                      return 'Studio Name cannot be empty';
                    } if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Studio Name',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    studioName=input;
                  },
                ),

                SizedBox(height: 15,),

                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[2],
                  validator: (input){
                    if(input!.isEmpty){
                      return null;
                    }
                    if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Founder Name',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    founder=input;
                  },
                ),

                SizedBox(height: 15,),

                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[3],
                  validator: (input){
                    if(input!.isEmpty){
                      return null;
                    }
                    if(input.length!=4||!RegExp(r'^[0-9]+$').hasMatch(input)){
                      return 'Enter correct Year';
                    }else {return null;}
                  },
                  keyboardType: TextInputType.number,
                  formatter: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      hintText: 'Year Founded',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    yearFounded = int.parse(input);
                  },
                ),

                SizedBox(height: 15,),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[ OutlinedButton(onPressed: (){
                      if(formKey.currentState!.validate()){
                        insertStudio();
                      }
                    },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                      child:  const Text('Add',
                        style: TextStyle(color: Colors.white),),
                    ),
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          if (studioId == -1){
                            Error = "Select Studio first.";
                            setState(() {
                            });
                            return;
                          }
                          updateStudio();
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
    );
    }else{return LoadingPage();}
  }
}