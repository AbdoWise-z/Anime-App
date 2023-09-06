import 'dart:convert';

import 'package:flutter/material.dart';
import '../Widgets/LoadingPage.dart';
import '../anime/AnimeCard.dart';
import '../utility/Base.dart';
import 'package:http/http.dart' as http;

class Favourites extends StatefulWidget {
  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  bool ready=false;
  bool loading=true;
  List favourites=[];


  void getFavourites()async{
    var r = await http.post(Uri.parse('$ServerAddress/anime_list_favorites'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode(
            {
              'userId' : CurrentUser.ID
            })
    );

    print(r.body);
    favourites=jsonDecode(r.body);
    setState(() {
      ready=true;
      loading=false;
    });
  }

  Future refresh()async{
    getFavourites();
  }

  @override
  void initState() {
    super.initState();
    getFavourites();
  }

  @override
  Widget build(BuildContext context) {
    if(ready){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favourites'),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          color: Colors.orange,
          child: GridView.count(
              crossAxisCount: 3,
              children: favourites.map((e) => AnimeCard(e['id'], e['rate'].toString(), e['anime_name'], e['episodes'].toString(),e['img_link'],
              )).toList()
          ),
        ),
      );

    }else {
      return const LoadingPage();
    }
  }
}
