import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../Widgets/LoadingPage.dart';
import '../../anime/data/News.dart';
import '../../utility/Base.dart';


class DeleteNews extends StatefulWidget {
  const DeleteNews({Key? key}) : super(key: key);

  @override
  State<DeleteNews> createState() => _DeleteNewsState();
}

class _DeleteNewsState extends State<DeleteNews> {
  
  void getAllNews()async{
    var r = await http.get(Uri.parse('$ServerAddress/select/allNews'));
    print(r.body);
    newsList=jsonDecode(r.body);
    news.clear();
    newsList.forEach((e) {
      news.add(News(e['anime_id'],e['img_link'],e['id'],e['link']));
    });
    setState(() {
      loading=false;
      ready=true;
    });
  }
  List newsList =[];
  List<News> news=[];



  final formKey=GlobalKey<FormState>();
  bool loading=true;
  bool ready=false;


  void deleteNews(int newsId)async{
    var r = await http.post(Uri.parse('$ServerAddress/delete/news'),
      headers: {"content-type" : "application/json"},
      body: jsonEncode({
        'newsId': newsId ,
        'Token': SessionID
      })
    );
    print(r.body);
  }

  Future refresh()async{
    getAllNews();
  }
  @override
  void initState() {
    super.initState();
    getAllNews();
  }

  @override
  Widget build(BuildContext context) {
    if(ready){return Scaffold(
      appBar: AppBar(title: Text('Delete News'),centerTitle: true,backgroundColor: Colors.black,),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: refresh,
        child: GridView.count(
          crossAxisCount: 3,
          children: news.map((e) => Stack(
            alignment: Alignment.topLeft,
            children: [
              Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(e.imgLink),
                          fit: BoxFit.cover
                      )
                  ),
                ),
              ),
            ),
              IconButton(
                onPressed: (){
                  deleteNews(e.id);
                  },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
                splashRadius: 40,
                splashColor: Colors.black,
                tooltip: "Delete Anime",
              ),
            ]
          )).toList(),
        ),
      )
    );
    }else{return LoadingPage();}
  }

}
