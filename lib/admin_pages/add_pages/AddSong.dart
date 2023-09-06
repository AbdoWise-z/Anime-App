import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../utility/Base.dart';

class AddSong extends StatefulWidget {
  const AddSong({Key? key}) : super(key: key);

  @override
  State<AddSong> createState() => _AddSongState();
}

class _AddSongState extends State<AddSong> {

  bool loading=true;
  bool ready=false;
  List animeList=[];
  List singerList=[];
  List songsList=[];

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void getSong(Map chosenSong)async{
    controllers[1].text=chosenSong['song_name'];
    controllers[2].text=chosenSong['date_published'].toString().split('T')[0];

    animeList.forEach((element) {
      if(chosenSong['anime_id']==element['id']){
        controllers[3].text=element['anime_name'];
      }
    });
    singerList.forEach((element) {
      if(chosenSong['singer_id']==element['id']){
        controllers[4].text=element['singer_name'];
      }
    });

    songName=chosenSong['song_name'];
    datePublished=chosenSong['date_published'].toString().split('T')[0];
    animeId=chosenSong['anime_id'];
    singerId=chosenSong['singer_id'];
  }

  void getAllAnimeNamesAndSingers()async{
    var rrr = await http.get(Uri.parse('$ServerAddress/select/allSongs'));

    songsList=jsonDecode(rrr.body);

    var rr= await http.get(Uri.parse('$ServerAddress/select/allSingers'));
    //print(rr.body);
    singerList=jsonDecode(rr.body);

    var r= await http.get(Uri.parse('$ServerAddress/anime_list'));
    //print(r.body);
    animeList=jsonDecode(r.body);
    //print(animeList.map((e) => e));
    setState(() {
      ready=true;
      loading=false;
    });
  }
  @override
  void initState() {
    super.initState();
    getAllAnimeNamesAndSingers();
  }

  void insertSong()async{
    setState(() {
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/song'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'songName': songName,
          'animeId': animeId,
          'singerId': singerId,
          'datePublished': datePublished,
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
      ready = true;
    });

  }
  void updateSong()async{
    setState(() {
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/update/song'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'songName': songName,
          'animeId': animeId,
          'singerId': singerId,
          'datePublished': datePublished,
          'songId':songId,
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
      ready = true;
    });

  }


  final formKey=GlobalKey<FormState>();

  String songName='';
  String datePublished='';
  int animeId=-1;
  int singerId=-1;
  int songId=-1;
  String? Error;


  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(
        title: Text('Add Song',),centerTitle: true,backgroundColor: Colors.black,
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
                      fk_flutter.addAll(songsList.map((e) => e['song_name']));
                      return fk_flutter;
                    }else{
                      List<String> matches = <String>[];
                      matches.addAll(songsList.map((e) => e['song_name']));

                      matches.retainWhere((s){
                        return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                      return matches;
                    }
                  },

                  onSelected: (String selection) {
                    songsList.forEach((element) {
                      if(element['song_name']==selection){
                        songId=element['id'];
                        //print(element);
                        getSong(element);
                      }
                    });
                    //print(songId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),

                      decoration: const InputDecoration(
                          hintText: 'Song Name',
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
                      "Song data",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  controller: controllers[1],
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Song Name cannot be empty';
                    } if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Song Name',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    songName=input;
                  },
                ),
                SizedBox(height: 15,),
                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  controller: controllers[2],
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  validator: (input){
                    if(!RegExp(r'^([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))+$').hasMatch(input!)){
                      return 'Enter correct Date of birth (YYYY-MM-DD)';
                    }else {return null;}
                  },
                  decoration: const InputDecoration(
                      hintText: 'Date Published',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    datePublished= input;
                  },
                ),
                SizedBox(height: 15,),
                RawAutocomplete(
                  focusNode: FocusNode(),
                  textEditingController: controllers[3],
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
                      background: const Color(0x14ff0000),
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
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
                  textEditingController: controllers[4],
                  //focusNode: FocusNode(),
                  //textEditingController: controllers[0],
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
                      }
                    });
                    print(singerId);
                    //print('You just selected $selection');
                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      background: const Color(0x14ff0000),
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      validator: (input){
                        if(input!.isEmpty){
                          return 'Singer Name cannot be empty';
                        } else {
                          String au = input;
                          int i = singerList.indexWhere((element) => element['singer_name'] == au);
                          if (i != -1) {
                            singerId = singerList[i]['id'];
                            return null;
                          } else {
                            return 'No such Singer';
                          }
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Singer Name',
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          insertSong();
                        }
                      },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                        child:  const Text('Add',
                          style: TextStyle(color: Colors.white),),
                      ),
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          if (songId == -1){
                            setState(() {
                              Error = "Select song before updating .";
                            });
                            return;
                          }
                          updateSong();
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