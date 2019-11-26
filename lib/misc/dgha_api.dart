import 'dart:convert';
import 'package:dgha/models/account.dart';
import 'package:dgha/models/review_place.dart';
import 'package:dgha/models/review.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

// Class to handle all calls to the DGHA API
class DghaApi {
  static final String rootUrl = "https://dgha-api.azurewebsites.net";
  static oauth2.Client currentClient;

//------------------------------ Note: Get UserID from token ------------------------------//
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  //------------------------------ Note: Authentication ------------------------------//
  static Future<oauth2.Client> signIn({String email, String password}) async {
    // Authentication parameters
    Uri tokenEndpoint = Uri.parse(
        "https://dgha-identityserver.azurewebsites.net/connect/token");
    String identifier = "ro.client";
    String secret = "secret";

    // Get credientials data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (email == null && password == null) {
      String credString = prefs.getString('credentials');
      if (credString != null && credString != "") {
        // Get client from credentials file
        oauth2.Credentials credentials =
            new oauth2.Credentials.fromJson(credString);

        if (!credentials.isExpired) {
          currentClient = oauth2.Client(credentials,
              identifier: identifier, secret: secret);

          // await refreshCredentials();

          return currentClient;
        } else {
          signOut();
          print("Credentials don't exist");
          return null;
        }
      } else {
        print("Credentials don't exist");
        return null;
      }
    } else {
      // Request client from token endpoint
      currentClient = await oauth2.resourceOwnerPasswordGrant(
        tokenEndpoint,
        email,
        password,
        identifier: identifier,
        secret: secret,
      );

      prefs.setString('credentials', currentClient.credentials.toJson());

      currentClient = currentClient;
      return currentClient;
    }
  }

  // Couldn't figure out how to get refreshing working
  // static Future<bool> refreshCredentials() async {
  //   print(currentClient.credentials.expiration);
  //   if (currentClient.credentials.isExpired) {
  //     oauth2.Client client = await currentClient.refreshCredentials();
  //     currentClient = client;

  //     print("Refreshed");
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  static void signOut() async {
    currentClient = null;

    // Empty credentials file
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credentials', "");
  }

  //------------------------------ Note: Accounts ------------------------------//
  static Future<http.Response> postAccount(
    String email,
    String password,
  ) async {
    Map<String, dynamic> data = {
      "email": email,
      "password": password,
    };

    http.Response response = await http.post(
      "$rootUrl/Accounts",
      body: jsonEncode(data),
      headers: {"content-type": "application/json"},
    );

    return response;
  }

  static Future<Account> getAccount() async {
    if (currentClient != null) {
      //await refreshCredentials();

      http.Response response = await currentClient.get(
        "$rootUrl/Accounts/${parseJwt(currentClient.credentials.accessToken)['sub']}",
        headers: {
          "content-type": "application/json",
        },
      );

      //Prevent decoding errors with a blank body
      if (response.body == "") {
        return Account();
      }

      var json = jsonDecode(response.body);
      Account account = new Account(id: json['id'], email: json['email']);

      return account;
    } else {
      print("User not logged in");
      return null;
    }
  }

  static Future<http.Response> deleteAccount() async {
    if (currentClient != null) {
      //await refreshCredentials();

      http.Response response = await currentClient.delete(
        "$rootUrl/Accounts/${parseJwt(currentClient.credentials.accessToken)['sub']}",
        headers: {
          "content-type": "application/json",
        },
      );

      return response;
    } else {
      print("User not logged in");
      return null;
    }
  }

  static Future<http.Response> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (currentClient != null) {
      //await refreshCredentials();

      http.Response response = await currentClient.put(
        "$rootUrl/Accounts/${parseJwt(currentClient.credentials.accessToken)['sub']}/UpdatePassword?currentPassword=$currentPassword&newPassword=$newPassword",
        headers: {
          "content-type": "application/json",
        },
      );

      return response;
    } else {
      print("User not logged in");
      return null;
    }
  }

  //------------------------------ Note: Complaints ------------------------------//
  static Future<http.Response> postComplaint(
    String placeID,
    String comment,
  ) async {
    if (currentClient != null) {
      //await refreshCredentials();

      Map<String, dynamic> data = {
        "userID": parseJwt(currentClient.credentials.accessToken)['sub'],
        "placeID": placeID,
        "comment": comment,
      };

      http.Response response = await currentClient.post(
        "$rootUrl/Complaints",
        body: jsonEncode(data),
        headers: {"content-type": "application/json"},
      );

      return response;
    } else {
      print("User not logged in");
      return null;
    }
  }
  //------------------------------ Note: Locations ------------------------------//

  //------------------------------ Note: Reviews ------------------------------//
  static Future<http.Response> postReview(
    String placeId,
    int overallRating,
    int locationRating,
    int amenitiesRating,
    int serviceRating,
    String comment,
  ) async {
    if (currentClient != null) {
      //await refreshCredentials();

      Map<String, dynamic> data = {
        "userID": parseJwt(currentClient.credentials.accessToken)['sub'],
        "placeID": placeId,
        "overallRating": overallRating,
        "locationRating": locationRating,
        "amentitiesRating": amenitiesRating,
        "serviceRating": serviceRating,
        "comment": comment,
      };

      http.Response response = await currentClient.post(
        "$rootUrl/Reviews",
        body: jsonEncode(data),
        headers: {"content-type": "application/json"},
      );

      return response;
    } else {
      print("User not logged in");
      return null;
    }
  }

  static Future<ReviewPlace> getReviewsFromPlaceId(String placeId) async {
    http.Response response = await http.get(
      "$rootUrl/Reviews/placeId/$placeId",
      headers: {
        "content-type": "application/json",
      },
    );

    //Prevent decoding errors with a blank body
    if (response.body == "" || response.statusCode != 200) {
      print(response.statusCode);
      return ReviewPlace(reviews: new List<ReviewData>());
    }

    Map<String, dynamic> json = jsonDecode(response.body);

    //Get all individual reviews
    List<ReviewData> userReviews = new List<ReviewData>();
    for (int i = 0; i < json['reviews'].length; i++) {
      ReviewData r = new ReviewData(
        placeId: json['reviews'][i]['placeId'],
        userId: json['reviews'][i]['userId'],
        timeAdded: json['reviews'][i]['timeAdded'],
        comment: json['reviews'][i]['comment'],
        overallRating: json['reviews'][i]['overallRating'],
        locationRating: json['reviews'][i]['locationRating'],
        custServRating: json['reviews'][i]['serviceRating'],
        amenitiesRating: json['reviews'][i]['amenitiesRating'],
      );

      userReviews.add(r);
    }

    ReviewPlace reviews = new ReviewPlace(
      averageRating: json['averageRating'].toDouble(),
      averageLocationRating: json['averageLocationRating'].toDouble(),
      averageAmenitiesRating: json['averageAmentitiesRating'].toDouble(),
      averageServiceRating: json['averageServiceRating'].toDouble(),
      count: json['count'],
      reviews: userReviews,
    );

    return reviews;
  }

  static Future<List<ReviewData>> getReviewsFromPlaceIdAndSet(
    String placeId,
    int setIndex,
  ) async {
    http.Response response = await http.get(
      "$rootUrl/Reviews/placeId/$placeId/$setIndex",
      headers: {
        "content-type": "application/json",
      },
    );

    //Prevent decoding errors with a blank body
    if (response.body == "" || response.statusCode != 200) {
      print(response.statusCode);
      return List<ReviewData>();
    }

    List<dynamic> json = jsonDecode(response.body);

    //Get all reviews
    List<ReviewData> userReviews = new List<ReviewData>();
    for (int i = 0; i < json.length; i++) {
      ReviewData r = new ReviewData(
        placeId: json[i]['placeId'],
        userId: json[i]['userId'],
        timeAdded: json[i]['timeAdded'],
        comment: json[i]['comment'],
        overallRating: json[i]['overallRating'],
        locationRating: json[i]['locationRating'],
        custServRating: json[i]['serviceRating'],
        amenitiesRating: json[i]['amenitiesRating'],
      );

      userReviews.add(r);
    }

    return userReviews;
  }

  static Future<List<ReviewData>> getReviewsFromUser() async {
    http.Response response = await http.get(
      "$rootUrl/Reviews/userId/${parseJwt(currentClient.credentials.accessToken)['sub']}",
      headers: {
        "content-type": "application/json",
      },
    );

    //Prevent decoding errors with a blank body
    if (response.body == "") {
      return new List<ReviewData>();
    }

    Map<String, dynamic> json = jsonDecode(response.body);

    List<ReviewData> userReviews = new List<ReviewData>();
    for (int i = 0; i < json.length; i++) {
      ReviewData r = new ReviewData(
        placeId: json[i]['placeId'],
        userId: json[i]['userId'],
        timeAdded: json[i]['timeAdded'],
        comment: json[i]['comment'],
        overallRating: json[i]['overallRating'],
        locationRating: json[i]['locationRating'],
        custServRating: json[i]['serviceRating'],
        amenitiesRating: json[i]['amenitiesRating'],
      );

      userReviews.add(r);
    }

    return userReviews;
  }

  static Future<ReviewData> getReviewFromPlaceIdAndUserId(
    String placeId,
    String userId,
  ) async {
    http.Response response = await http.get(
      "$rootUrl/Reviews/$placeId/$userId",
      headers: {
        "content-type": "application/json",
      },
    );

    //Prevent decoding errors with a blank body
    if (response.body == "") {
      return ReviewData();
    }

    Map<String, dynamic> json = jsonDecode(response.body);
    ReviewData review = new ReviewData(
      placeId: json['placeId'],
      userId: json['userId'],
      timeAdded: json['timeAdded'],
      comment: json['comment'],
      overallRating: json['overallRating'],
      locationRating: json['locationRating'],
      custServRating: json['serviceRating'],
      amenitiesRating: json['amenitiesRating'],
    );

    return review;
  }

  static Future<http.Response> updateReview(
    String placeId,
    int overallRating,
    int locationRating,
    int amenitiesRating,
    int servicceRating,
    String comment,
  ) async {
    if (currentClient != null) {
      //await refreshCredentials();

      Map<String, dynamic> data = {
        "userID": parseJwt(currentClient.credentials.accessToken)['sub'],
        "placeID": placeId,
        "overallRating": overallRating,
        "locationRating": locationRating,
        "amentitiesRating": amenitiesRating,
        "serviceRating": servicceRating,
        "comment": comment,
      };

      http.Response response = await currentClient.put(
        "$rootUrl/Reviews/$placeId/${parseJwt(currentClient.credentials.accessToken)['sub']}",
        body: jsonEncode(data),
        headers: {"content-type": "application/json"},
      );

      return response;
    } else {
      print("User not logged in");
      return null;
    }
  }

  static Future<http.Response> deleteReview(String placeId) async {
    if (currentClient != null) {
      //await refreshCredentials();

      http.Response response = await currentClient.delete(
        "$rootUrl/Reviews/$placeId/${parseJwt(currentClient.credentials.accessToken)['sub']}",
        headers: {
          "content-type": "application/json",
        },
      );

      return response;
    } else {
      print("User not logged in");
      return null;
    }
  }
}
