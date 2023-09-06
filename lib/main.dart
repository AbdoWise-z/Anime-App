import 'package:anime/admin_pages/AdminPanel.dart';
import 'package:anime/admin_pages/BanPage.dart';
import 'package:anime/admin_pages/EnquiriesList.dart';
import 'package:anime/admin_pages/add_pages/AddAnimePage.dart';
import 'package:anime/admin_pages/add_pages/AddAuthorPage.dart';
import 'package:anime/admin_pages/add_pages/AddAwardPage.dart';
import 'package:anime/admin_pages/add_pages/AddCharacter.dart';
import 'package:anime/admin_pages/add_pages/AddEpisodePage.dart';
import 'package:anime/admin_pages/add_pages/AddNewsPage.dart';
import 'package:anime/admin_pages/add_pages/AddSingerPage.dart';
import 'package:anime/admin_pages/add_pages/AddSong.dart';
import 'package:anime/admin_pages/add_pages/AddStudioPage.dart';
import 'package:anime/admin_pages/add_pages/AddVA.dart';
import 'package:anime/anime/Pages/CommentSectionPage.dart';
import 'package:anime/anime/Pages/SingerPage.dart';
import 'package:anime/anime/Pages/Song.dart';
import 'package:anime/anime/Pages/SongsPage.dart';
import 'package:anime/anime/Pages/StudioPage.dart';
import 'package:anime/anime/SearchPage.dart';
import 'package:anime/login/BannedPage.dart';
import 'package:anime/login/Login.dart';
import 'package:anime/user_pages/FavouritesPage.dart';
import 'package:anime/user_pages/WatchListPage.dart';
import 'package:anime/utility/Base.dart';
import 'package:anime/user_pages/EnquiryPage.dart';
import 'package:flutter/material.dart';

import 'admin_pages/delete_pages/DeleteNews.dart';
import 'anime/AnimeForm.dart';
import 'anime/Home.dart';
import 'anime/Pages/AuthorPage.dart';
import 'anime/Pages/VAPage.dart';

void main() {

  runApp(MaterialApp(
      initialRoute: "/login/LoginPage",
      navigatorObservers: [routeObserver],
      routes: {

        //Login
        '/login/LoginPage' : (context) => Login(),
        '/login/banned' : (context) => BannedPage(),

        //Anime View
        '/anime/CommentsSection' : (context) => CommentsSectionPage(),
        '/anime/Home' :(context) => Home(),
        '/anime/Search' :(context) => SearchPage(),
        '/anime/AnimeForm' :(context) => AnimeForm(),
        '/anime/Pages/Song' : (context) => Song(),
        '/anime/Pages/VAPage' : (context) => VA(),
        '/anime/Pages/SongsPage' : (context) => SongsPage(),
        '/anime/Pages/StudioPage' : (context) => Studio(),
        '/anime/Pages/AuthorPage' : (context) => Author(),
        '/anime/Pages/SingerPage' : (context) => Singer(),

        //Admin Pages
        '/admin/enq_list' : (context) => EnquiriesList(),
        '/admin/ban' : (context) => BanPage(),
        '/admin/add/Anime' : (context) => AddAnimePage(),
        '/admin/add/Author' : (context) => AddAuthor(),
        '/admin/add/Character' : (context) => AddCharacter(),
        '/admin/add/Episode' : (context) => AddEpisode(),
        '/admin/add/News' : (context) => AddNews(),
        '/admin/add/Singer' : (context) => AddSinger(),
        '/admin/add/Song' : (context) => AddSong(),
        '/admin/add/Studio' : (context) => AddStudio(),
        '/admin/add/VA'     : (context) => AddVA(),
        '/admin/add/Awards' : (context) => AddAwardPage(),

        '/admin/delete/News' : (context) => DeleteNews(),

        '/admin/panel' : (context) => AdminPanel(),


        //User Pages
        '/user/Favourite' : (context) => Favourites(),
        '/user/WatchList' : (context) => WatchList(),
        '/user/enquiry' : (context) => EnquiryPage(),

      },
    ));
}
