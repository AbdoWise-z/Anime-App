
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingCard extends StatefulWidget {
  final String msg;
  const LoadingCard({this.msg = "Loading..." , Key? key}) : super(key: key);

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.discreteCircle(color: Colors.black, size: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
              child: Text(
                widget.msg,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
    );
  }
}
