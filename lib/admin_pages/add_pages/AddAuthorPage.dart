import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/Widgets/RippleTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../utility/Base.dart';

class AddAuthor extends StatefulWidget {
  const AddAuthor({Key? key}) : super(key: key);

  @override
  State<AddAuthor> createState() => _AddAuthorState();
}

class _AddAuthorState extends State<AddAuthor> {

  bool loading=true;
  bool ready=false;

  final formKey=GlobalKey<FormState>();
  String authorName='';
  String dateOfBirth='';
  String Atype='';
  String imgLink='';
  int yearsActive=0;
  List authorList=[];
  int authorId=-1;
  Map chosenAuthor={};
  String? Error;

  List<TextEditingController> controllers=[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void getAuthor(int id)async{
    var r= await http.get(Uri.parse('$ServerAddress/select/authorById?authorId=$authorId'));
    //print(r.body);
    chosenAuthor =jsonDecode(r.body);
    controllers[1].text=chosenAuthor['author_name'];
    controllers[2].text=chosenAuthor['birth_date'].toString().split('T')[0];
    controllers[3].text=chosenAuthor['anime_genre'];
    controllers[4].text=chosenAuthor['img_link'];
    controllers[5].text=chosenAuthor['years_active'].toString();
    authorName=chosenAuthor['author_name'];
    dateOfBirth=chosenAuthor['birth_date'].toString().split('T')[0];
    imgLink=chosenAuthor['img_link'];
    Atype=chosenAuthor['anime_genre'];
    yearsActive=chosenAuthor['years_active'];
    setState(() {
    });

  }
  void updateAuthor()async{
    setState(() {
      loading = true;
      ready = false;
    });
    var r = await http.post(Uri.parse('$ServerAddress/update/author'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'authorName': authorName,
          'birthDate': dateOfBirth,
          'yearsActive': yearsActive,
          'animeGenre': Atype,
          'imgLink': imgLink,
          'authorId':authorId,
          'Token': SessionID,
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
  void insertAuthor()async{
    setState(() {
      ready = false;
    });

    var r = await http.post(Uri.parse('$ServerAddress/insert/author'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode({
          'Token' : SessionID,
          'authorName': authorName,
          'birthDate': dateOfBirth,
          'yearsActive': yearsActive,
          'animeGenre': Atype,
          'imgLink': imgLink,
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

  void getAllAuthors()async{
    var rr= await http.get(Uri.parse('$ServerAddress/select/allAuthors'));
    //print(rr.body);
    authorList=jsonDecode(rr.body);
    setState(() {
      ready=true;
      loading=false;
    });
  }
  @override
  void initState() {
    super.initState();
    getAllAuthors();
  }


  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(
        title: Text('Add Author',),centerTitle: true,backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Form(
            key: formKey,
            child: Column(
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
                    authorList.forEach((element) {
                      if(element['author_name']==selection){
                        authorId=element['id'];
                        getAuthor(authorId);
                      }
                    });
                    print(authorId);
                    //print('You just selected $selection');

                  },

                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return RippleTextFormField(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                      "Author Data (id: $authorId)",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),

                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  //padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[1],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Author Name cannot be empty';
                    } if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Name';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Author Name',
                      border: InputBorder.none,
                  ),
                  onChanged: (input){
                    authorName=input;
                  },
                ),
                SizedBox(height: 15,),
                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  //padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[2],
                  validator: (input){
                    if(!RegExp(r'^([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))+$').hasMatch(input!)){
                      return 'Enter correct Date of birth (YYYY-MM-DD)';
                    }else {return null;}
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Date of Birth',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    dateOfBirth= input;
                  },
                ),
                SizedBox(height: 15,),
                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  //padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[3],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Cannot be empty';
                    }
                    if(!RegExp(r'^[a-z A-Z]+$').hasMatch(input)){
                      return 'Enter correct Genre';
                    }else{return null;}
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Most Genre',
                      suffixText: 'optional',
                      border: InputBorder.none
                  ),
                  onChanged: (input){
                    Atype=input;
                  },
                ),
                SizedBox(height: 15,),
                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  //padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[4],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Image link cannot be empty';
                    }
                    else{return null;}
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Image Link',
                      border: InputBorder.none,
                  ),
                  onChanged: (input){
                    imgLink=input;
                  },
                ),
                SizedBox(height: 15,),
                RippleTextFormField(
                  background: const Color(0x14ff0000),
                  //padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  controller: controllers[5],
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Cannot be empty';
                    }else{
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  formatter: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                      hintText: 'Years Active',
                      border: InputBorder.none,
                  ),
                  onChanged: (input){
                    yearsActive=int.parse(input);
                  },
                ),
                SizedBox(height: 15,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[ OutlinedButton(onPressed: (){
                      if(formKey.currentState!.validate()){
                        insertAuthor();
                      }
                    },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                      child:  const Text('Add',
                        style: TextStyle(color: Colors.white),),
                    ),
                      OutlinedButton(onPressed: (){
                        if(formKey.currentState!.validate()){
                          if (authorId == -1){
                            setState(() {
                              Error = "Select author first.";
                            });
                            return;
                          }
                          updateAuthor();
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
    }else{
      return LoadingPage();
    }
  }
}