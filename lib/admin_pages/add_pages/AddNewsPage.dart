import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Widgets/LoadingPage.dart';
import '../../utility/Base.dart';

class AddNews extends StatefulWidget {
  const AddNews({Key? key}) : super(key: key);

  @override
  State<AddNews> createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {

  bool loading=true;
  bool ready=false;
  List animeList=[];

  void insertNews()async{
    var r = await http.post(Uri.parse('$ServerAddress/insert/news'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'link': newsLink,
          'imgLink': imgLink,
          'animeId': animeId,
        }));
    print(r.body);

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

  int animeId=-1;
  String datePublished='';
  String newsLink='';
  String imgLink='';

  final formKey=GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getAllAnimeNames();
  }
  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(
        title: Text('Add News',),centerTitle: true,backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                    }
                  });
                  print(animeId);
                  //print('You just selected $selection');
                },

                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    validator: (input){
                      if(input!.isEmpty){
                        return 'Anime Name cannot be empty';
                      }else{return null;}
                    },
                    decoration: const InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.black)
                        ),
                        hintText: 'Anime Name',
                        border: OutlineInputBorder()
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
              TextFormField(
                validator: (input){
                  if(input!.isEmpty){
                    return 'News link cannot be empty';
                  }
                  else{return null;}
                },
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                    hintText: 'Link',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.black)
                    )
                ),
                onChanged: (input){
                  newsLink=input;
                },
              ),
              TextFormField(
                validator: (input){
                  if(input!.isEmpty){
                    return 'Image link cannot be empty';
                  }
                  else{return null;}
                },
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                    hintText: 'Image Link',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.black)
                    )
                ),
                onChanged: (input){
                  imgLink=input;
                },
              ),
              OutlinedButton(onPressed: (){
                if(formKey.currentState!.validate()){
                  insertNews();
                }
              },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                child:  const Text('Add',
                  style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      ),
    );
    }else{return LoadingPage();}
  }
}
