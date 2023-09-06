import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimeCard extends StatelessWidget {

  String rating,
      anime_name,
      num_of_eps,
      anime_image_url;
  int anime_id;


  AnimeCard(this.anime_id,this.rating,this.anime_name,this.num_of_eps,this.anime_image_url);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 12,
        color: Colors.grey,
        margin: EdgeInsets.all(5),
        child: Container(
          child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(anime_image_url),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        color: Colors.black54,
                        height: 40,
                        child:Flexible(
                          child: Text(' $anime_name',
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      color: Colors.black54,
                      child: Column(
                        children: [
                          RichText(text: TextSpan(
                              children: [
                                WidgetSpan(child: Icon(Icons.star,size: 15,color: Colors.yellow.shade800,)),
                                TextSpan(text: rating,style: const TextStyle(fontSize: 15,color: Colors.white)),
                              ]
                          ),
                          ),
                          Container(
                            color: Colors.orange,
                            child: Text('EP $num_of_eps',
                              style:const TextStyle(fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
          ),
        ),
      ),
      onTap: (){
        Navigator.pushNamed(context, '/anime/AnimeForm',
            arguments: {
              'id': anime_id,
              'anime_name': anime_name,
            }
        );
      },
    );
  }
}