import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Widgets/LoadingPage.dart';
import '../../utility/Base.dart';

class AddAnimePage extends StatefulWidget {

  @override
  State<AddAnimePage> createState() => _AddAnimePageState();
}

class _AddAnimePageState extends State<AddAnimePage> {

  final formKey=GlobalKey<FormState>();
  bool loading=true;
  bool ready=false;
  bool imagePicked=false;

  List authorList=[];
  List studioList=[];
  List animeList=[];
  Map chosenAnime={};

  String selectedAuthor='';
  String selectedStudio='';
  String animeName='';
  int yearPublished=0;
  int episodes=0;
  String genre='';
  String imgLink='';
  int animeId = -1;
  int authorId = -1;
  int studioId = -1;

  String? Error;

  void insertAnime() async {
    setState(() {
      ready = false;
      loading = false;
      Error = null;

    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/anime'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'Token' : SessionID,
          'animeName': animeName,
          'authorId': authorId,
          'studioId': studioId,
          'genre': genre,
          'yearPub' : yearPublished,
          'imgLink': imgLink,
        }));

    print(r.body);

    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to add anime.";
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

  void updateAnime()async{
    setState(() {
      ready = false;
      loading = false;
      Error = null;
    });

    var param = {
      'Token' : SessionID,
      'animeName': animeName,
      'authorId': authorId,
      'studioId': studioId,
      'genre': genre,
      'yearPub' : yearPublished,
      'imgLink': imgLink,
      'animeId': animeId,
    };
    print(param);
    var r = await http.post(Uri.parse('$ServerAddress/update/anime'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'Token' : SessionID,
          'animeName': animeName,
          'authorId': authorId,
          'studioId': studioId,
          'genre': genre,
          'yearPub' : yearPublished,
          'imgLink': imgLink,
          'animeId': animeId,
        }));

    print(r.body);

    var data = jsonDecode(r.body);

    if (data["STATUS"] == 0){
      Error = "Failed to update anime , check anime name.";
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

  void getAllStudiosAndAuthors()async{

    var r= await http.get(Uri.parse('$ServerAddress/select/allStudios'));
    print(r.body);
    studioList=jsonDecode(r.body);
    var rr= await http.get(Uri.parse('$ServerAddress/select/allAuthors'));
    print(rr.body);
    authorList=jsonDecode(rr.body);
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

    print(r.body);
    chosenAnime = jsonDecode(r.body);
    controllers[1].text = chosenAnime['anime']['img_link'];
    controllers[2].text = chosenAnime['anime']['anime_name'];
    animeName = controllers[2].text;
    controllers[3].text = chosenAnime['author']['author_name'];
    controllers[4].text = chosenAnime['studio']['studio_name'];
    controllers[5].text = chosenAnime['anime']['year_published'].toString();
    //controllers[6].text = chosenAnime['anime']['rate'].toString();
    controllers[7].text = chosenAnime['anime']['genre'];
    authorId = chosenAnime['author']['id'];
    studioId = chosenAnime['studio']['id'];
    genre = chosenAnime['anime']['genre'];
    imgLink = chosenAnime['anime']['img_link'];
    yearPublished = chosenAnime['anime']['year_published'];

    setState(() {
    });
  }

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
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
                              "Anime data (id: $animeId)",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],

                              ),
                            ),
                          ),
                        ),
                        RippleTextFormField(
                          background: const Color(0x14ff0000),
                          controller: controllers[1],
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
                        RippleTextFormField(
                          background: const Color(0x14ff0000),
                          controller: controllers[2],
                          validator: (input){
                            if(input!.isEmpty){
                              return 'Anime Name cannot be empty';
                            }else{return null;}
                          },
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                              hintText: 'Anime Name',
                              border: InputBorder.none,
                          ),
                          onChanged: (input){
                            animeName=input;
                          },
                        ),SizedBox(height: 15,),
                        RawAutocomplete(
                          focusNode: FocusNode(),
                          textEditingController: controllers[3],
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              List<String> fk_flutter = [];
                              fk_flutter.addAll(authorList.map((e) => e['author_name']));
                              return fk_flutter;
                            }else{
                              List<String> matches = <String>[];
                              matches.addAll(authorList.map((e) => e['author_name']));

                              matches.retainWhere((s){
                                return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                              return matches;
                            }
                          },

                          onSelected: (String selection) {
                          },

                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return RippleTextFormField(
                              background: const Color(0x14ff0000),
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              validator: (input){
                                if(input!.isEmpty){
                                  return 'Author Name cannot be empty';
                                } else {
                                  String au = input;
                                  int i = authorList.indexWhere((element) => element['author_name'] == au);
                                  if (i != -1) {
                                    authorId = authorList[i]['id'];
                                    return null;
                                  } else {
                                    return 'No such Author';
                                  }
                                }
                              },
                              decoration: const InputDecoration(
                                  hintText: 'Author Name',
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
                        ),SizedBox(height: 15,),
                        RawAutocomplete(
                          focusNode: FocusNode(),
                          textEditingController: controllers[4],
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
                          },

                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return RippleTextFormField(
                              background: const Color(0x14ff0000),
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              validator: (input){
                                if(input!.isEmpty){
                                  return 'Studio Name cannot be empty';
                                } else {
                                  String au = input;
                                  int i = studioList.indexWhere((element) => element['studio_name'] == au);
                                  if (i != -1) {
                                    studioId = studioList[i]['id'];
                                    return null;
                                  } else {
                                    return 'No such Studio';
                                  }
                                }
                              },
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
                        ),SizedBox(height: 15,),
                        RippleTextFormField(
                          background: const Color(0x14ff0000),
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          controller: controllers[5],
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
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                              hintText: 'Year Published',
                              suffixText: 'optional',
                              border: InputBorder.none
                          ),
                          onChanged: (input){
                            yearPublished=int.parse(input);
                          },
                        ),SizedBox(height: 15,),
                        RippleTextFormField(
                          background: const Color(0x14ff0000),
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          controller: controllers[7],
                          validator: (input){
                            if(input!.isEmpty){
                              return null;
                            }
                            if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                              return 'Enter correct Genre';
                            }else{return null;}
                          },
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                              hintText: 'Genre',
                              suffixText: 'optional',
                              border: InputBorder.none
                          ),
                          onChanged: (input){
                            genre=input;
                          },
                        ),SizedBox(height: 15,),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:[
                              OutlinedButton(onPressed: (){
                                if(formKey.currentState!.validate()){
                                  insertAnime();
                                }
                              },
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                                child:  const Text('Add',
                                  style: TextStyle(color: Colors.white),),
                              ),
                              OutlinedButton(onPressed: (){
                                if(formKey.currentState!.validate()){
                                  if (animeId == -1){
                                    setState(() {
                                      Error = "Select anime before updating .";
                                    });
                                    return;
                                  }
                                  updateAnime();
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
              ]
          ),
      );
    }
    else{ return const LoadingPage();
    }
  }
}