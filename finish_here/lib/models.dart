import 'package:google_maps_flutter/google_maps_flutter.dart';

class Shop {
  String name;
  String distance;
  String price;
  int rating;
  LatLng location;

  Shop(
      {required this.name,
      required this.distance,
      required this.price,
      required this.rating,
      required this.location});
}
