import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../../utility/Base.dart';

class AddVA extends StatefulWidget {
  const AddVA({Key? key}) : super(key: key);

  @override
  State<AddVA> createState() => _AddVAState();
}

class _AddVAState extends State<AddVA> {

  bool ready=false;
  bool loading=true;
  List vaList=[];
  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void getVA(Map chosenVA)async{
    controllers[1].text = chosenVA['va_name'];
    controllers[2].text = chosenVA['va_birth_date'].toString().split('T')[0];
    controllers[3].text = chosenVA['va_img_link'];

    vaName = chosenVA['va_name'];
    dateOfBirth = chosenVA['va_birth_date'].toString().split('T')[0];
    imgLink = chosenVA['va_img_link'];
  }
  void getAllVAs()async{
    try {
      var rr = await http.get(Uri.parse('$ServerAddress/select/allVAs'));
      //print(rr.body);
      vaList = jsonDecode(rr.body);
      setState(() {
        ready = true;
        loading = false;
      });
    } catch (e){
      setState(() {
        Navigator.pop(context);
      });
    }


  }
  void insertVA()async{
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/va'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'vaName': vaName,
          'birthDate': dateOfBirth,
          'imgLink': imgLink,
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
  void updateVA()async{
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/update/va'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'vaName': vaName,
          'birthDate': dateOfBirth,
          'imgLink': imgLink,
          'vaId':vaId,
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
  String vaName='';
  String dateOfBirth='';
  String imgLink='';
  int vaId=-1;
  String? Error;

  @override
  void initState() {
    super.initState();
    getAllVAs();
  }

  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(
        title: Text('Add Voice Actor',),centerTitle: true,backgroundColor: Colors.black,
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
                      fk_flutter.addAll(vaList.map((e) => e['va_name']));
                      return fk_flutter;
                    }else{
                      List<String> matches = <String>[];
                      matches.addAll(vaList.map((e) => e['va_name']));

                      matches.retainWhere((s){
                        return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },

                  onSelected: (String selection) {
                    vaList.forEach((element) {
                      if(element['va_name']==selection){
                        vaId=element['va_id'];
                        getVA(element);
                        print(element);
                      }
                    });
                    print(vaId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      decoration: const InputDecoration(
                          hintText: 'Voice Actor Name',
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
                      "Voice Actor data",
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
                      return 'Voice Actor Name cannot be empty';
                    } if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Voice Actor Name',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    vaName=input;
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
                      hintText: 'Birth Date',
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
                      hintText: 'Image Link',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    imgLink=input;
                  },
                ),
                SizedBox(height: 15,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[ OutlinedButton(onPressed: (){
                      if(formKey.currentState!.validate()){
                        insertVA();
                      }
                    },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                      child:  const Text('Add',
                        style: TextStyle(color: Colors.white),),
                    ),
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          if (vaId == -1){
                            Error = "Select item first.";
                            setState(() {

                            });
                            return;
                          }
                          updateVA();
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