
import 'dart:convert';
import 'dart:ffi';

import 'package:animations/animations.dart';
import 'package:anime/Widgets/LoadingPage.dart';
import 'package:anime/anime/Pages/AnimeMainPage.dart';
import 'package:anime/anime/Pages/CharactersPage.dart';
import 'package:anime/anime/Pages/CommentSectionPage.dart';
import 'package:anime/anime/Pages/EpisodesListPage.dart';
import 'package:anime/utility/Base.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

import 'data/AnimeCharacter.dart';
import 'data/Comment.dart';
import 'data/Episode.dart';

  //pass anime_name , id before pushing this..
class AnimeForm extends StatefulWidget {
  const AnimeForm({Key? key}) : super(key: key);

  @override
  State<AnimeForm> createState() => _AnimeFormState();
}

class _AnimeFormState extends State<AnimeForm> {

  bool ready = false;
  bool error = false;

  String animeName = "Loading Data ...";
  String disc      = "";
  int id = 12;

  String authorName    = "Rukkadifattah";
  int authorID         = -1;

  String studioName    = "Mihoyo";
  int studioID         = -1;

  double rating        = 5;
  double userRating    = 5;
  int numOfEps         = 6000;
  String genre         = "OP Characters";
  DateTime releaseDate = DateTime(2022 , 9 , 18 , 14 , 30);
  String imageUrl      = "https://paimon.moe/images/characters/full/nahida.png";
  List animeSongs      = [];
  List<String> animeRewards  = ["Gigachad Reward" , "Best Archon Reward" , "Cute AF Reward"];

  List<Comment> comments = [
    Comment(
      user_name: "Osama",
      data: "Reddish archon lesgoo",
      date: DateTime.now(),
      Comment_Id: 1,
    ),
    Comment(
      user_name: "Abdo",
      data: "Reject humanity , turn to a tree",
      date: DateTime.now(),
      Comment_Id: 2,
    ),
    Comment(
      user_name: "Amr",
      data: "click here to win 100000\$ 'www.Im_gonna_hack_you.com' totally not a bait link",
      date: DateTime.now(),
      Comment_Id: 3,
    ),
    Comment(
      user_name: "Hefney",
      data: "sleep..",
      date: DateTime.now(),
      Comment_Id: 4,
    ),
  ];

  List<Episode> episodes = [
    Episode(url: "test" , num: 0),
    Episode(url: "test" , num: 1),
    Episode(url: "test" , num: 2),
    Episode(url: "test" , num: 3),
    Episode(url: "test" , num: 4),
    Episode(url: "test" , num: 5),
  ];

  List<AnimeCharacter> mainCharacters = [];
  List<AnimeCharacter>  supCharacters = [];


  void load_details() async{
    try {
      print("Running: $ServerAddress/anime_details");
      var res = await http.post(
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
      print(res.body);
      print("------------------------------");


      Map data = jsonDecode(res.body);

      animeName   = data["anime"]["anime_name"];
      rating      = data["anime"]["rate"].toDouble();
      numOfEps    = data["anime"]["episodes"];
      genre       = data["anime"]["genre"];
      imageUrl    = data["anime"]["img_link"];
      //disc        = data["anime"]["disc"]; TODO: uncomment this when ready
      userRating  = data["rating"].toDouble();
      releaseDate = DateTime(data["anime"]["year_published"]);

      authorName = data["author"]["author_name"];
      authorID   = data["author"]["id"];

      studioName = data["studio"]["studio_name"];
      studioID   = data["studio"]["id"];

      animeSongs = data['songs'];


      List aw       = data["awards"];
      animeRewards.clear();
      for (var element in aw) {
        animeRewards.add(element["award_name"]);
      }
      List eps      = data["episodes"];
      episodes.clear();
      for (var element in eps) {
        episodes.add(
          Episode(
            url: element["episode_link"],
            num: element["episode_number"],
          )
        );
      }

      List characters = data["characters"];
      mainCharacters.clear();
      supCharacters.clear();

      for (var i in characters){
        if (i["character_role"] == 0){
          mainCharacters.add(AnimeCharacter(char_id: i["char_id"], character_name: i["character_name"], character_role: i["character_role"], va_id: i["va_id"], anime_id: i["anime_id"], char_img_link: i["char_img_link"], va_name: i["va_name"], va_img_link: i["va_img_link"], va_birth_date: i["va_birth_date"]));
        }else{
          supCharacters .add(AnimeCharacter(char_id: i["char_id"], character_name: i["character_name"], character_role: i["character_role"], va_id: i["va_id"], anime_id: i["anime_id"], char_img_link: i["char_img_link"], va_name: i["va_name"], va_img_link: i["va_img_link"], va_birth_date: i["va_birth_date"]));
        }
      }

      ready = true;
      error = false;
    }catch (e){
      print(e);
      ready = false;
      error = true;

    }

    print("load_details() done");
    setState(() {});

  }
  bool _toggle_favorate_lock = false;
  void ToggleFavorite() async {
    //gList.add(id);
    //CurrentUser.list.add(id);
    _toggle_favorate_lock = true;
    if (CurrentUser.favorites.contains(id)) {
      CurrentUser.favorites.remove(id);
      var r=await http.post(Uri.parse('$ServerAddress/delete/favorites'),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                'Token': SessionID,
                'animeId': id,
              }));
      print(r.body);
    } else {
      CurrentUser.favorites.add(id);
      var rr=await http.post(Uri.parse('$ServerAddress/insert/favorites'),
          headers: {"content-type" : "application/json"},
          body: jsonEncode(
              {
                'Token': SessionID,
                'animeId': id,
              }));
      print(rr.body);
    }
    setState(() {});
    _toggle_favorate_lock = false;
  }

  Future load_comments() async {
    comments.clear();

    String url = "$ServerAddress/select/commentsByAnime?animeId=$id";
    print("Running: $url");

    try {
      var res = await http.get(Uri.parse(url));

      print("-----------RECEIVED-----------");
      print(res.body);
      print("------------------------------");

      List comment = jsonDecode(res.body);
      for (Map m in comment){
        String date_string = m["date_published"];
        List<String> date_data = date_string.split("T");
        List<String> date = date_data[0].split("-");
        List<String> time = date_data[1].split(":");
        DateTime obj = DateTime(
          int.parse(date[0]) , //year
          int.parse(date[1]) , //month
          int.parse(date[2]) , //day
          int.parse(time[0]) , //hours
          int.parse(time[1]) , //minutes
        );

        comments.add(
          Comment(
            Comment_Id: m["comment_id"],
            User_Id: m["user_id"],
            date: obj,
            Anime_Id: m["anime_id"],
            data: m["comment_data"],
            user_name: m["username"],
          )
        );
      }
    }catch (e){
      print(e);
    }

    print("load_comments() done");
    setState(() {});

      setState(() {
    });
  }

  var args;
  _load_function(args) async {
    if (args == null){
      if (id != -1) { //theres a default
        load_details();
        load_comments();
      }
      return;
    }

    Map data = args as Map;
    id = data["id"];

    load_details();
    load_comments();
  }

  @override
  void initState() {
    super.initState();
    // future that allows us to access context. function is called inside the future
    // otherwise it would be skipped and args would return null
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(context)!.settings.arguments;
      });
      _load_function(args);
    });
  }

  final PageController _controller = PageController();
  int _currentpage = 0;

  @override
  Widget build(BuildContext context) {
    if (ready) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _currentpage == 0 ? animeName : _currentpage == 1 ? "Episodes" : _currentpage == 2 ? "Comments section" : "Characters",
          ),
          backgroundColor: Colors.grey[900],
        ),
        body: PageView(
          onPageChanged: (index) {
            _currentpage = index;
            setState(() {});
          },
          controller: _controller,
          children: [
            AnimeMainPage(authorName, animeName, studioName, "$rating", "$numOfEps", genre,
                "${releaseDate.year}", imageUrl,animeRewards,authorID,studioID,animeSongs,id),
            EpisodesList(list: episodes),
            RefreshIndicator(onRefresh: load_comments , child: CommentsSectionPage(AnimeID: id,comments: comments,)),
            CharactersPage(mainChars: mainCharacters, supChars: supCharacters , disc: disc , animeId: id , rating: userRating,),
          ],
        ),

        floatingActionButton: _currentpage == 0 ? FloatingActionButton(
          onPressed: () {
            if (!_toggle_favorate_lock) ToggleFavorite();
          },
          tooltip: CurrentUser.favorites.contains(id) ? "Remove from favorites" : "Add to favorites",
          backgroundColor: Colors.grey[800],
          child: Icon(
            CurrentUser.favorites.contains(id) ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.grey[800],
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: <Widget>[
                IconButton(
                  color: _currentpage == 0 ? Colors.blue : Colors.white,
                  tooltip: 'Details',
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
                IconButton(
                  color: _currentpage == 1 ? Colors.blue : Colors.white,
                  tooltip: 'Episodes',
                  icon: const Icon(Icons.video_collection),
                  onPressed: () {
                    _controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
                IconButton(
                  color: _currentpage == 2 ? Colors.blue : Colors.white,
                  tooltip: 'Comments',
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    _controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
                IconButton(
                  color: _currentpage == 3 ? Colors.blue : Colors.white,
                  tooltip: 'Characters',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    _controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }else{
      if (error){
        return Scaffold(
          appBar: AppBar(
            title: Text(animeName),
          ),
          body: const Center(
            child: Text(
              "Failed to load Anime data\ncheck internet and try again",
              style: TextStyle(
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }else{
        return Scaffold(
          appBar: AppBar(
            title: Text(animeName),
          ),
          body: Center(child: Container(
            width: 250,
            height: 200,
            child: const LoadingPage(msg: "Loading Anime's info..."),
          ))
        );
      }
    }
  }
}
