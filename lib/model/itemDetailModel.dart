class ItemDetailModel {
  String? key;
  String? upin;
  String? brand;
  String? currency;
  String? description;
  String? discount;
  List<String>? images;

  String? finalPrice;
  String? initialPrice;
  String? rating;
  String? reviewsCount;
  String? url;
  String? insights;
  List<String>? pros;
  List<String>? cons;
  ItemDetailModel(
      {this.key,
      this.upin,
      this.brand,
      this.currency,
      this.description,
      this.discount,
      this.images,
      this.finalPrice,
      this.initialPrice,
      this.rating,
      this.reviewsCount,
      this.url,
      this.insights,
      this.pros,
      this.cons});

  toJson() {
    return {
      "key": key,
      "upin": upin,
      "brand": brand,
      "currency": currency,
      "description": description,
      "images": images,
      "discount": discount,
      "finalPrice": finalPrice,
      "initialPrice": initialPrice,
      "rating": rating,
      "reviewsCount": reviewsCount,
      "url": url,
      "insights": insights,
      "pros": pros,
      "cons": cons,
    };
  }

  ItemDetailModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    upin = map['upin'];
    brand = map['brand'];
    currency = map['currency'];
    description = map['description'];
    discount = map['discount'];
    finalPrice = map['finalPrice'];
    initialPrice = map['initialPrice'];
    rating = map['rating'];
    reviewsCount = map['reviewsCount'];
    url = map['url'];
    insights = map['insights'];

    if (map['images'] != null) {
      map['images'].forEach((value) {
        images = <String>[];
        map['images'].forEach((value) {
          images!.add(value);
        });
      });
    } else {
      images = [];
    }

    if (map['pros'] != null) {
      map['pros'].forEach((value) {
        pros = <String>[];
        map['pros'].forEach((value) {
          pros!.add(value);
        });
      });
    } else {
      pros = [];
    }

    if (map['cons'] != null) {
      map['cons'].forEach((value) {
        cons = <String>[];
        map['cons'].forEach((value) {
          cons!.add(value);
        });
      });
    } else {
      cons = [];
    }
  }
}
