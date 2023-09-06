import 'dart:convert';

import 'package:flutter/material.dart';
import '../Widgets/LoadingPage.dart';
import '../anime/AnimeCard.dart';
import '../utility/Base.dart';
import 'package:http/http.dart' as http;

class WatchList extends StatefulWidget {



  @override
  State<WatchList> createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {

  bool ready=false;
  bool loading=true;
  List watchlist=[];

  void getWatchlist()async{
    var r = await http.post(Uri.parse('$ServerAddress/anime_list_watchlist'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode(
            {
              'userId' : CurrentUser.ID
            }));
    print(r.body);
    watchlist=jsonDecode(r.body);
    setState(() {
      ready=true;
      loading=false;
    });
  }
  Future refresh()async{
    getWatchlist();
  }

  @override
  void initState() {
    super.initState();
    getWatchlist();
  }

  @override
  Widget build(BuildContext context) {

    if(ready){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Watch List'),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          color: Colors.orange,
          child: GridView.count(
              crossAxisCount: 3,
              children: watchlist.map((e) => AnimeCard(e['id'], e['rate'].toString(), e['anime_name'], e['episodes'].toString(),e['img_link'],
              )).toList()
          ),
        ),
      );
    }else {
      return const LoadingPage();
    }
  }
}
