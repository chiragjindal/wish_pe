import 'dart:convert';

import 'package:wish_pe/model/itemDetailModel.dart';

class JsonResponseItemModel {
  final String? upin;
  final String? brand;
  final String? currency;
  final String? description;
  final String? discount;
  final String? finalPrice;
  final List<String>? image;
  final String? initialPrice;
  final String? rating;
  final String? reviewsCount;
  final String? url;

  final String? title;
  final List<String> categories;
  final String? provider;
  final String? insights;
  final List<String>? pros;
  final List<String>? cons;
  JsonResponseItemModel(
      {required this.upin,
      required this.brand,
      required this.currency,
      required this.description,
      required this.discount,
      required this.finalPrice,
      required this.image,
      required this.initialPrice,
      required this.rating,
      required this.reviewsCount,
      required this.url,
      required this.title,
      required this.categories,
      required this.provider,
      required this.insights,
      required this.pros,
      required this.cons});

  toItemDetailModel() {
    return ItemDetailModel(
        upin: upin,
        brand: brand,
        currency: currency,
        description: description,
        images: image,
        discount: discount,
        finalPrice: finalPrice,
        initialPrice: initialPrice,
        rating: rating,
        reviewsCount: reviewsCount,
        url: url,
        insights: insights,
        pros: pros,
        cons: cons);
  }

  factory JsonResponseItemModel.fromJson(Map<dynamic, dynamic> map,
          {bool isJson = false}) =>
      JsonResponseItemModel(
        upin: map['upin']?.toString(),
        brand: map['brand'],
        currency: map['currency'],
        description: map['description'],
        discount: map['discount']?.toString(),
        finalPrice: map['finalPrice']?.toString(),
        image: isJson
            ? List<String>.from(json.decode(map['imageUrl']))
            : map['imageUrl'] != null
                ? [map['imageUrl']]
                : null,
        initialPrice: map['initialPrice']?.toString(),
        rating: map['rating'] != null ? map['rating'].toString() : null,
        reviewsCount:
            map['reviewsCount'] != null ? map['reviewsCount'].toString() : null,
        url: map['url'],
        title: map['title'],
        provider: map['provider'],
        categories: isJson
            ? List<String>.from(json.decode(map['categories']))
            : List<String>.from(map['categories']),
        insights: map['insights']?.toString(),
        pros: map['pros']?.cast<String>(),
        cons: map['cons']?.cast<String>(),
      );
}
