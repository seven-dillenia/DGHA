import 'dart:convert';

class PlaceData {
  String placeId;
  String name;
  String address;
  String state;
  List<String> types;
  double avgOverallRating;
  double avgCustomerRating;
  double avgAmentitiesRating;
  double avgLocationRating;
  int numOfAllReviews;
  int numOfWrittenReviews;

  PlaceData({
    this.placeId,
    this.name,
    this.address,
    this.state,
    this.types,
    this.avgOverallRating,
    this.avgCustomerRating,
    this.avgAmentitiesRating,
    this.avgLocationRating,
    this.numOfAllReviews,
    this.numOfWrittenReviews,
  });

  factory PlaceData.fromJson(Map<String, dynamic> json) => PlaceData(
        placeId: json["placeId"],
        name: json["name"],
        address: json["address"],
        state: json["state"],
        types: json["types"] != null ? List<String>.from(json["types"].map((x) => x)) : null,
        avgOverallRating: json["avgOverallRating"].toDouble(),
        avgCustomerRating: json["avgCustomerRating"].toDouble(),
        avgAmentitiesRating: json["avgAmentitiesRating"].toDouble(),
        avgLocationRating: json["avgLocationRating"].toDouble(),
        numOfAllReviews: json["numOfAllReviews"],
        numOfWrittenReviews: json["numOfWrittenReviews"]
      );

  Map<String, dynamic> toJson() => {
        "placeId": placeId,
        "name": name,
        "address": address,
        "state": state,
        "types": List<dynamic>.from(types.map((x) => x)),
        "avgOverallRating": avgOverallRating,
        "avgCustomerRating": avgCustomerRating,
        "avgAmentitiesRating": avgAmentitiesRating,
        "avgLocationRating": avgLocationRating,
        "numOfAllReviews": numOfAllReviews,
        "numOfWrittenReviews": numOfWrittenReviews
      };

  static List<PlaceData> decodePlaceDataList(String data) {
    return List<PlaceData>.from(
        json.decode(data).map((x) => PlaceData.fromJson(x)));
  }
}
