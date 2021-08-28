import 'package:google_maps_flutter/google_maps_flutter.dart';

class Shop {
  String name;
  String distance;
  String price;
  int rating;
  LatLng location;

  Shop(this.name, this.distance, this.price, this.rating, this.location);
}