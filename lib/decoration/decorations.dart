import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BoxBorderDecoration extends BoxDecoration {
  final Color borderColor;
  final Color backColor;
  Color color;

  BoxBorderDecoration(this.borderColor, this.backColor) {
    this.color = super.color;
    new Border.all(color: Colors.grey[600]);
    color = Colors.transparent;
  }
}

// ignore: must_be_immutable
class BoxBackgroundDecoration extends BoxDecoration {
  final String filename;
  DecorationImage image;

    BoxBackgroundDecoration({this.filename}) { 
      this.image = super.image;
      this.image =  new DecorationImage(
                          image: AssetImage('$filename'),
                          fit: BoxFit.cover
                        );
    }
}