import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Widgets/LoadingPage.dart';
import '../../utility/Base.dart';

class AddAwardPage extends StatefulWidget {

  @override
  State<AddAwardPage> createState() => _AddAwardPageState();
}

class _AddAwardPageState extends State<AddAwardPage> {

  final formKey=GlobalKey<FormState>();
  bool loading=true;
  bool ready=false;

  List animeList=[];
  List animeAwards=[];

  Map chosenAnime={};

  int animeId = -1;

  String? Error;

  void insertAward() async {
    setState(() {
      ready = false;
      loading = false;
      Error = null;

    });

    print(jsonEncode({
      'Token' : SessionID,
      'animeId' : animeId,
      'awardName' : controllers[1].text
    }));

    var r = await http.post(Uri.parse('$ServerAddress/insert/animeaward'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'Token' : SessionID,
          'animeId' : animeId,
          'awardName' : controllers[1].text
        }));

    print(r.body);

    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to add Award.";
    }else{
      setState(() {
        animeAwards.add(controllers[1].text);
        controllers[1].text = "";
      });
    }

    setState(() {
      ready=true;
      loading=false;
    });
  }

  void deleteAward()async{
    setState(() {
      ready = false;
      loading = false;
      Error = null;
    });

    var r = await http.post(Uri.parse('$ServerAddress/delete/animeaward'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'Token' : SessionID,
          'animeId': animeId,
          'awardName' : controllers[1].text
        }));

    print(r.body);

    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to update anime , check anime name.";
    }else{
      setState(() {
        animeAwards.remove(controllers[1].text);
        controllers[1].text = "";
      });
    }

    setState(() {
      ready=true;
      loading=false;
    });
  }

  void getAllStudiosAndAuthors()async{

    var rrr= await http.get(Uri.parse('$ServerAddress/anime_list'));
    print(rrr.body);
    animeList=jsonDecode(rrr.body);

    setState(() {
      ready=true;
      loading=false;
    });


  }
  void getAnime(int id) async {
    print("Running: $ServerAddress/anime_details");
    var r = await http.post(
      Uri.parse("$ServerAddress/anime_details"),
      headers: {"content-type" : "application/json"},
      body: jsonEncode(
        {
          "Token"  : SessionID,
          "animeId": id,
        },
      ),
    );

    print("-----------RECEIVED-----------");
    print(r.body);
    print("------------------------------");

    chosenAnime = jsonDecode(r.body);
    controllers[0].text = chosenAnime['anime']['anime_name'];
    //controllers[1].text = chosenAnime['anime']['anime_name'];
    animeAwards.clear();
    for (var element in chosenAnime["awards"]) {
      animeAwards.add(element["award_name"]);
    }

    setState(() {
    });
  }

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    getAllStudiosAndAuthors();
  }

  @override
  Widget build(BuildContext context) {
    if(ready){
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(centerTitle: true,title: Text('Add Anime'),backgroundColor: Colors.black,),
        body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                          for (var element in animeList) {
                            if(element['anime_name']==selection){
                              animeId = element['id'];
                              getAnime(animeId);
                            }
                          }
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return RippleTextFormField(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            decoration: const InputDecoration(
                                hintText: 'Search by Anime name',
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
                            "Award (aid: $animeId)",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                      RawAutocomplete(
                        focusNode: FocusNode(),
                        textEditingController: controllers[1],
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            List<String> fk_flutter = [];
                            fk_flutter.addAll(animeAwards.map((e) => e));
                            return fk_flutter;
                          }else{
                            List<String> matches = <String>[];
                            matches.addAll(animeAwards.map((e) => e));

                            matches.retainWhere((s){
                              return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                            return matches;
                          }
                        },

                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return RippleTextFormField(
                            background: const Color(0x14ff0000),
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            validator: (input){
                              if(input!.isEmpty){
                                return 'Award name cannot be empty';
                              } else {
                                return null;
                              }
                            },
                            decoration: const InputDecoration(
                                hintText: 'Award name',
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
                                if (animeId == -1){
                                  Error = "Choose anime first.";
                                  setState(() {

                                  });
                                  return;
                                }
                                insertAward();
                              }
                            },
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                              child:  const Text('Add',
                                style: TextStyle(color: Colors.white),),
                            ),
                            OutlinedButton(onPressed: (){
                              if(formKey.currentState!.validate()){
                                if (animeId == -1){
                                  Error = "Choose anime first.";
                                  setState(() {

                                  });
                                  return;
                                }
                                deleteAward();
                              }
                            },
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                              child:  const Text('Delete',
                                style: TextStyle(color: Colors.white),),
                            )
                          ]
                      )
                    ],
                  ),
                ),
              ),
            ]
        ),
      );
    }
    else{ return const LoadingPage();
    }
  }
}