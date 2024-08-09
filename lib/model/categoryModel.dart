import 'package:flutter/material.dart';

class CategoryModel {
  String? key;
  String? name;
  String? imageUrl;
  Color? color;
  CategoryModel({
    this.key,
    this.name,
    this.imageUrl,
    this.color,
  });
  toJson() {
    return {
      "name": name,
      "imageUrl": imageUrl,
      "color": color!.value,
    };
  }

  CategoryModel.fromJson(Map<dynamic, dynamic> json) {
    key = json["key"];
    name = json["name"];
    imageUrl = json["imageUrl"];
    color = Color(json['color']);
  }
}
