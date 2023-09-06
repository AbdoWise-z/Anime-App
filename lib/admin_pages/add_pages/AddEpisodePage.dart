import 'dart:convert';

import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../../utility/Base.dart';

class AddEpisode extends StatefulWidget {
  const AddEpisode({Key? key}) : super(key: key);

  @override
  State<AddEpisode> createState() => _AddEpisodeState();
}

class _AddEpisodeState extends State<AddEpisode> {
  bool selected=false;
  bool loading=true;
  bool ready=false;
  ScrollController controller=ScrollController();

  List animeList=[];
  List epList=[];


  int epNumber=-1;
  String epLink='';

  int animeId=-1;
  String? Error;

  void insertEpisode()async{
    setState(() {
      ready = false;
      loading = false;
      Error = null;

    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/episode'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'episodeNumber': epNumber,
          'episodeLink': epLink,
          'animeId': animeId,
          'Token': SessionID

        }));
    print(r.body);
    var data=jsonDecode(r.body);


    if (data["STATUS"] == 0){
      Error = "Failed to add Episode.";
    }else{
      setState(() {
        Navigator.pop(context);
      });
    }
    setState(() {
      ready=true;
      loading=false;
    });


  }
  void updateEpisode()async{
    setState(() {
      ready = false;
      loading = false;
      Error = null;

    });

    var r = await http.post(Uri.parse('$ServerAddress/update/episode'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'episodeNumber': epNumber,
          'episodeLink': epLink,
          'animeId': animeId,
          'Token': SessionID,

        }));
    print(r.body);
    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to update Episode , check inputs name.";
    }else{
      setState(() {
        Navigator.pop(context);
      });
    }
    setState(() {
      ready=true;
      loading=false;
    });

  }
  void getAllAnimeNames()async{

    var r= await http.get(Uri.parse('$ServerAddress/anime_list'));
    //print(r.body);
    animeList=jsonDecode(r.body);
    //print(animeList.map((e) => e));


    setState(() {
      ready=true;
      loading=false;
    });
  }
  void getEpisodes()async{

    var rr= await http.get(Uri.parse('$ServerAddress/select/episodeByAnime?animeId=$animeId'));
    epList=jsonDecode(rr.body);
    selected=true;

    setState(() {});

  }
  TextEditingController text_controller=TextEditingController();
  @override
  void initState() {
    super.initState();
    getAllAnimeNames();
  }
  final formKey=GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(

      appBar: AppBar(
        title: const Text('Add Episode'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
          child: Form(
            key: formKey,
            child: Container(
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
                          getEpisodes();
                        }
                      });


                      print(animeId);
                      //print('You just selected $selection');
                    },

                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return RippleTextFormField(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        validator: (input){
                          if(input!.isEmpty){
                            return 'Anime Name cannot be empty';
                          }else{return null;}
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
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        List<String> fk_flutter = [];
                        fk_flutter.addAll(epList.map((e) => e['episode_number'].toString()));
                        return fk_flutter;
                      }else{
                        List<String> matches = <String>[];
                        matches.addAll(epList.map((e) => e['episode_number'].toString()));

                        matches.retainWhere((s){
                          return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                        return matches;
                      }
                    },

                    onSelected: (String selection) {
                      epNumber=int.parse(selection);
                      epList.forEach((element) {
                        if(selection==element['episode_number'].toString()){
                          text_controller.text=element['episode_link'];
                        }
                      });
                      setState(() {});
                      //print('You just selected $selection');
                    },

                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return RippleTextFormField(
                        readOnly: selected? false:true,
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        validator: (input){
                          if(input!.isEmpty){
                            return 'Episode Number cannot be empty';
                          }else{return null;}
                        },
                        formatter: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: 'Episode Number (Select Anime First)',
                          border: InputBorder.none,
                        ),
                        controller: textEditingController,
                        focusNode: focusNode,
                        onChanged: (input){
                          epNumber = int.parse(input);
                          setState(() {});
                        },
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
                        "Episode data (aid: $animeId ,Ep: $epNumber)",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],

                        ),
                      ),
                    ),
                  ),
                  RippleTextFormField(
                    background: const Color(0x14ff0000),
                    controller: text_controller,
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                    validator: (input){
                      if(input!.isEmpty){
                        return 'Episode link cannot be empty';
                      }
                      else{return null;}
                    },
                    decoration: const InputDecoration(
                        hintText: 'Link',
                        border: InputBorder.none
                    ),
                    onChanged: (input){
                      epLink=input;
                    },
                  ),
                  SizedBox(height: 15,),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        OutlinedButton(onPressed: (){
                          if(formKey.currentState!.validate()){
                            if (animeId == -1 || epNumber == -1){
                              setState(() {
                                Error = "Enter anime & episode before updating .";
                              });
                              return;
                            }
                            insertEpisode();
                          }
                        },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                          child:  const Text('Add',
                            style: TextStyle(color: Colors.white),),
                        ),
                        OutlinedButton(onPressed: (){
                          if(formKey.currentState!.validate()){
                            if (animeId == -1 || epNumber == -1){
                              setState(() {
                                Error = "Select anime & episode before updating .";
                              });
                              return;
                            }
                            updateEpisode();
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
      ),
    );}else{return LoadingPage();}
  }
}
