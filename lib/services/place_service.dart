import 'dart:convert';

import 'package:dgha/misc/data.dart';
import 'package:dgha/misc/helper.dart';
import 'package:dgha/models/place.dart';
import 'package:dgha/models/search_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location_permissions/location_permissions.dart';

// TODO: change the url to rootURL
class PlaceService {

  static Future<bool> getPermission() async {
    // check if the user has already allowed for the app to use location
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    bool hasAsked = false;

    // if the user has not yet allow the app to use location, the app will ask to request locaiton ONCE
    while (permission != PermissionStatus.granted && hasAsked == false) {
      permission = await LocationPermissions().requestPermissions();
      hasAsked = true;
    }

    if (permission == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  static Future<String> getState() async {
    bool isGranted = await getPermission();

    if (isGranted) {
      Position pos = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
      List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(pos.latitude, pos.longitude);

      return placemarks[0].administrativeArea;
    }
    return null;
  }

  static Future<List<PlaceData>> getRecommendedPlaces() async {
    // this only works with a physical device
    // final String state = await getState();
    final String state = "Victoria";

    if (state != null) {
      String url = '${Data.rootTestingUrl}/location/recommend?state=$state';
      http.Response res = await http.get(url, headers: {"Accept": "application/json"});

      if (res.statusCode == 200) {
        return PlaceData.decodePlaceDataList(res.body);
      }
    }
    return List<PlaceData>();
  }
  

  static Future<SearchPlace> getSearchedPlaces(String query, String nextPageToken) async {
    String formattedQuery = Helper().formatStringForQuery(query);
    String url = '${Data.rootTestingUrl}/location/search?query=$formattedQuery&nextpagetoken=$nextPageToken'; 
    http.Response res = await http.get(url, headers: {"Accept": "application/json"});

    if(res.statusCode == 200) {
      SearchPlace spr = SearchPlace.decodePlaceReponseFromJson(res.body);

      // if nextPageToken is null, it will break the app
      spr.nextPageToken = spr.nextPageToken != null ? spr.nextPageToken : '';

      return spr; 
    } else {
      return SearchPlace(places: List<PlaceData>(), nextPageToken: ''); 
    } 
  }

  static Future<PlaceData> getPlaceRatingById(String placeId) async {
    String url = "${Data.rootTestingUrl}/location/placeId/$placeId";
    http.Response res = await http.get(url, headers: {"Accept": "application/json"});

    if(res.statusCode == 200) {
      Map<String, dynamic> decodeJson = jsonDecode(res.body); 
      return PlaceData.fromJson(decodeJson); 
    }

    return null; 
  }
}