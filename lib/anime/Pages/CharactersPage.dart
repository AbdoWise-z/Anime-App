import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../utility/Base.dart';
import '../data/AnimeCharacter.dart';
import 'package:http/http.dart' as http;

class CharactersPage extends StatelessWidget {
  final List<AnimeCharacter> mainChars;
  final List<AnimeCharacter> supChars;
  final String disc;
  double rating;
  final int animeId;

  CharactersPage({
    Key? key,
    required this.mainChars,
    required this.supChars,
    required this.disc,
    required this.animeId,
    this.rating = 0,
  }) : super(key: key) ;

  void _updateRating(double nr) async{
    rating = nr;
    await Future.delayed(const Duration(milliseconds: 300)); //prevent spamming
    if (rating != nr) return; //user changed the rating

    var res = await http.post(
      Uri.parse("$ServerAddress/insert/rating"),
      headers: {"content-type" : "application/json"},
      body: jsonEncode(
        {
          "rating" : rating,
          "Token"  : SessionID,
          "animeId": animeId,
        },
      ),
    );
    print("-----------RECEIVED-----------");
    print(res.body);
    print("------------------------------");

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Main Characters",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 140,
            child: ListView.builder(
              itemBuilder: (bc , i) {
                return AnimeCharacterCard(
                  name: mainChars[i].character_name,
                  vaName: mainChars[i].va_name,
                  imgLink: mainChars[i].char_img_link,
                  vaID : mainChars[i].va_id,
                  vaBirthDate: mainChars[i].va_birth_date,
                  vaImgLink: mainChars[i].va_img_link,
                  rippleColor: Color(0xBE2CD5FF),
                );
              },
              itemCount: mainChars.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Secondary Characters",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 140,
            child: ListView.builder(
              itemBuilder: (bc , i) {
                return AnimeCharacterCard(
                  name: supChars[i].character_name,
                  vaName: supChars[i].va_name,
                  imgLink: supChars[i].char_img_link,
                  vaID : supChars[i].va_id,
                  vaImgLink: supChars[i].va_img_link,
                  vaBirthDate: supChars[i].va_birth_date,
                  rippleColor: Color(0xBEFF2C6B),
                );
              },
              itemCount: supChars.length,
              scrollDirection: Axis.horizontal,
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Text(
          //         "Description",
          //         style: TextStyle(
          //           color: Colors.grey[600],
          //           fontSize: 20,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       Text(
          //         disc,
          //         style: const TextStyle(
          //           color: Colors.black,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Rate Anime:",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _updateRating(rating);
                  },
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class AnimeCharacterCard extends StatelessWidget {
  final String name;
  final String vaName;
  final String imgLink;
  final int vaID;
  final Color rippleColor;
  final String vaImgLink;
  final String vaBirthDate;


  const AnimeCharacterCard({
    Key? key,
    required this.name,
    required this.vaName,
    required this.imgLink,
    required this.vaID,
    required this.vaImgLink,
    required this.vaBirthDate,
    required this.rippleColor,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
        child: Theme(
          data: ThemeData(splashColor: rippleColor),
          child: Material(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            clipBehavior: Clip.hardEdge,
            color: const Color(0x06000000),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/anime/Pages/VAPage' , arguments: {
                  'vaName': vaName,
                  'vaImgLink': vaImgLink,
                  'vaBirthDate': vaBirthDate,
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Material(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Image(
                          image: NetworkImage(imgLink),
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,

                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        name,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        vaName,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

