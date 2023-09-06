import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

import '../../utility/Base.dart';

class AnimeMainPage extends StatefulWidget {
  String author_name,
      anime_name,
      studio_name,
      rating,
      num_of_eps,
      genre,
      date,
      anime_image_url;
  List<String>anime_awards;
  int authorId;
  int studioId;
  List animeSongs;
  int animeId;

  AnimeMainPage(this.author_name,this.anime_name,this.studio_name,
      this.rating,this.num_of_eps,this.genre,this.date,this.anime_image_url,this.anime_awards,
      this.authorId,this.studioId,this.animeSongs,this.animeId);

  @override
  State<AnimeMainPage> createState() => _AnimeMainPageState();
}

class _AnimeMainPageState extends State<AnimeMainPage> {
  List authorData=[];
  List studioData=[];
  List songData=[];

  bool _toggle_loading = false;
  void ToggleWatchlist()async{
    _toggle_loading = true;

    if (CurrentUser.watchList.contains(widget.animeId)) {
      CurrentUser.watchList.remove(widget.animeId);
      var r = await http.post(Uri.parse('$ServerAddress/delete/watchlist'),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                'Token': SessionID,
                'animeId': widget.animeId,
              }));
      print(r.body);
    } else {
      CurrentUser.watchList.add(widget.animeId);
      var rr=await http.post(Uri.parse('$ServerAddress/insert/watchlist'),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                'Token': SessionID,
                'animeId': widget.animeId,
              }));
      print(rr.body);
    }
    setState(() {});
    _toggle_loading = false;
  }

  bool _delete_lock = false;
  void delete() async {
    _delete_lock = true;

    print("Delete: ${widget.animeId}");

    var r = await http.post(Uri.parse('$ServerAddress/delete/anime'),
        headers: {"content-type" : "application/json"},
        body: jsonEncode(
            {
              'Token': SessionID,
              'animeId': widget.animeId,
            }
            )
    );
    print(r.body);
    _delete_lock = false;
    Navigator.pop(context);
  }


  void getAuthor()async{
    var r=await http.get(Uri.parse('$ServerAddress/select/authorById?authorId=${widget.authorId}'));

    print(r.body);
    authorData=jsonDecode(r.body);
    setState(() {
      Navigator.pushNamed(context, '/anime/Pages/AuthorPage',arguments: authorData[0]);
    });
  }
  void getStudio()async{
    var r=await http.get(Uri.parse('$ServerAddress/select/studioById?studioId=${widget.studioId}'));

    print(r.body);
    studioData=jsonDecode(r.body);
    setState(() {
      Navigator.pushNamed(context, '/anime/Pages/StudioPage',arguments: studioData[0]);
    });
  }


  IconData header = Icons.keyboard_arrow_up;
  @override
  Widget build(BuildContext context) {
    return Stack(
        children:[
          ExpandableBottomSheet(
            enableToggle: true,
            background: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.anime_image_url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            onIsExtendedCallback: () => setState( () => header = Icons.keyboard_arrow_down ),
            onIsContractedCallback: () => setState( () => header = Icons.keyboard_arrow_up ),
            persistentHeader: Container(
              height: 40,
              color: Colors.white70,
              child: Center(
                child: Icon(header,),
              ),
            ),
            expandableContent:
            Container(
              color: Colors.white70,
              height: 470,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person,color: Colors.black,),
                    title: Text('Author: ${widget.author_name}',style: TextStyle(fontWeight: FontWeight.bold),),
                    onTap: getAuthor,
                  ),
                  ListTile(
                    leading: Icon(Icons.apartment,color: Colors.black,),
                    title: Text('Studio: ${widget.studio_name}',style: TextStyle(fontWeight: FontWeight.bold),),
                    onTap: getStudio,
                  ),
                  ListTile(
                    leading: Icon(Icons.star,color: Colors.black,),
                    title: Text('Rating: ${widget.rating}',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Icon(Icons.play_circle,color: Colors.black,),
                    title: Text('Episodes: ${widget.num_of_eps}',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Icon(Icons.tag,color: Colors.black,),
                    title: Text('Genre: ${widget.genre}',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Icon(Icons.date_range,color: Colors.black,),
                    title: Text('Year Published: ${widget.date}',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Icon(Icons.diamond,color: Colors.black,),
                    title: Text('Awards: ${widget.anime_awards.map((e) => e)} ',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Icon(Icons.music_note,color: Colors.black,),
                    title: Text('Songs',style: TextStyle(fontWeight: FontWeight.bold),),
                    onTap: (){
                      Navigator.pushNamed(context, '/anime/Pages/SongsPage',arguments: widget.animeSongs);
                    },
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              isAdmin() ?
              IconButton(
                onPressed: (){
                  if (!_delete_lock)
                    delete();
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
                splashRadius: 40,
                splashColor: Colors.black,
                tooltip: "Delete Anime",
              ) : SizedBox(),
              Expanded(child: SizedBox() , flex: 1,),
              IconButton(
                onPressed: (){
                  if (!_toggle_loading)
                    ToggleWatchlist();
                },
                tooltip: CurrentUser.watchList.contains(widget.animeId) ? "Remove from watch list" : "Add to watch list",
                icon: CurrentUser.watchList.contains(widget.animeId)?
                Icon(Icons.bookmark_added,color: Colors.white,size: 40,):
                Icon(Icons.add,color: Colors.white,size: 40,),
              ),
            ],
          )
        ]
    );
  }
}

