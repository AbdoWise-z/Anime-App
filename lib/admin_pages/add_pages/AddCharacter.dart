import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../Widgets/LoadingPage.dart';
import '../../utility/Base.dart';

class AddCharacter extends StatefulWidget {
  const AddCharacter({Key? key}) : super(key: key);

  @override
  State<AddCharacter> createState() => _AddCharacterState();
}

class _AddCharacterState extends State<AddCharacter> {


  bool loading=true;
  bool ready=false;
  List vaList=[];
  List animeList=[];
  List charList=[];
  List chosenChar=[];
  String? Error;

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void getChar(int id)async{

    var r = await http.get(Uri.parse('$ServerAddress/select/characterByAnime?animeId=$id'));

    print(r.body);

    chosenChar = jsonDecode(r.body);

    controllers[1].text = chosenChar[0]['character_name'];

    animeId = chosenChar[0]['anime_id'];

    animeList.forEach((element) {
      if(animeId==element['id']){
        controllers[2].text=element['anime_name'];
      }
    });

    vaId = chosenChar[0]['va_id'];

    vaList.forEach((element) {
      if(vaId==element['va_id']){
        controllers[3].text=element['va_name'];
      }
    });

    controllers[4].text = chosenChar[0]['char_img_link'];

    characterRole = chosenChar[0]['character_role'];
    characterName = chosenChar[0]['character_name'];
    imgLink = chosenChar[0]['char_img_link'];
    charId = chosenChar[0]['char_id'];

    setState(() {});

  }

  void getAllAnimeNamesAndVAsAndCharacters()async{

    var rr= await http.get(Uri.parse('$ServerAddress/select/allVAs'));
    //print(rr.body);
    vaList=jsonDecode(rr.body);

    var r= await http.get(Uri.parse('$ServerAddress/anime_list'));
    //print(r.body);
    animeList=jsonDecode(r.body);
    //print(animeList.map((e) => e));
    var rrr = await http.get(Uri.parse('$ServerAddress/select/allCharacters'));

    charList = jsonDecode(rrr.body);

    setState(() {
      ready=true;
      loading=false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllAnimeNamesAndVAsAndCharacters();
  }
  void updateCharacter() async {
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/update/character'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'characterName': characterName,
          'characterRole': characterRole,
          'animeId': animeId,
          'vaId': vaId,
          'imgLink': imgLink,
          'characterId': charId,
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

  void insertCharacter() async {
    setState(() {
      loading = true;
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/character'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'characterName': characterName,
          'characterRole': characterRole,
          'animeId': animeId,
          'vaId': vaId,
          'imgLink': imgLink,
          'Token': SessionID
        }));

    print(r.body);
    var data = jsonDecode(r.body);


    if (data["STATUS"] == 0){
      Error = "Failed to add , check input.";
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


  final formKey = GlobalKey<FormState>();
  String characterName='';
  int characterRole=0;
  String imgLink='';
  int animeId=-1;
  int vaId=-1;
  int charId=-1;

  @override
  Widget build(BuildContext context) {
    if (ready){return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add Character',),
        centerTitle: true,backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
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
                      fk_flutter.addAll(charList.map((e) => e['character_name']));
                      return fk_flutter;
                    }else{
                      List<String> matches = <String>[];
                      matches.addAll(charList.map((e) => e['character_name']));

                      matches.retainWhere((s){
                        return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },

                  onSelected: (String selection) {
                    charList.forEach((element) {
                      if(element['character_name']==selection){
                        animeId=element['anime_id'];
                        getChar(animeId);
                      }
                    });
                    //print(animeId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      decoration: const InputDecoration(
                          hintText: 'Character Name',
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
                      "Character Data (id: $charId)",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),

                RippleTextFormField(
                  //padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  background: const Color(0x14ff0000),
                  controller: controllers[1],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Character Name cannot be empty';
                    } if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Character Name',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    characterName=input;
                  },
                ),
                SizedBox(height: 15,),
                RawAutocomplete(

                  focusNode: FocusNode(),
                  textEditingController: controllers[2],
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      List<String> fk_flutter = [];
                      fk_flutter.addAll(animeList.map((e) => e['anime_name']));
                      return fk_flutter;
                    }else{
                      List<String> matches = <String>[];
                      matches.addAll(animeList.map((e) => e['anime_name']));

                      matches.retainWhere((s){
                        return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },

                  onSelected: (String selection) {
                    animeList.forEach((element) {
                      if(element['anime_name']==selection){
                        animeId=element['id'];
                      }
                    });
                    print(animeId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      background: const Color(0x14ff0000),
                      validator: (input){
                        if(input!.isEmpty){
                          return 'Anime Name cannot be empty';
                        } else {
                          String au = input;
                          int i = animeList.indexWhere((element) => element['anime_name'] == au);
                          if (i != -1) {
                            animeId = animeList[i]['id'];
                            return null;
                          } else {
                            return 'No such Anime';
                          }
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Anime Name',
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

                SizedBox(height: 15,),

                RawAutocomplete(
                  focusNode: FocusNode(),
                  textEditingController: controllers[3],
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
                      }
                    });
                    print(vaId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      background: const Color(0x14ff0000),

                      validator: (input){
                        if(input!.isEmpty){
                          return 'VA Name cannot be empty';
                        } else {
                          String au = input;
                          int i = vaList.indexWhere((element) => element['va_name'] == au);
                          if (i != -1) {
                            vaId = vaList[i]['va_id'];
                            return null;
                          } else {
                            return 'No such VA';
                          }
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'VA Name',
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

                SizedBox(height: 15,),

                RippleTextFormField(
                  //padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  background: const Color(0x14ff0000),

                  controller: controllers[4],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Image link cannot be empty';
                    }
                    else{return null;}
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Image Link',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    imgLink=input;
                  },
                ),

                SizedBox(height: 15,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8 , 0 , 0 , 0 ),
                      child: Text(
                        "Character Type: ",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    DropdownButton<String>(items: const [
                      DropdownMenuItem(value: "Main",child: Text("Main") ,),
                      DropdownMenuItem(value: "Secondary", child: Text("Secondary")),
                    ], onChanged: (str){
                      characterRole = (str! == "Main") ? 0 : 1;
                      setState(() {
                      });
                    },
                      value: characterRole == 0 ? "Main" : "Secondary",
                    ),
                  ],
                ),

                SizedBox(height: 15,),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[ OutlinedButton(onPressed: (){
                      if(formKey.currentState!.validate()){
                        insertCharacter();
                      }
                    },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                      child:  const Text('Add',
                        style: TextStyle(color: Colors.white),),
                    ),
                      OutlinedButton(onPressed: (){
                        if (charId == -1){
                          Error = "Select character first.";
                          setState(() {

                          });
                          return;
                        }
                        updateCharacter();
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
    }else{
      return LoadingPage();
    }
  }
}