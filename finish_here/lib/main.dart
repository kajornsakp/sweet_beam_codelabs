import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sweet_beam/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("error");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  ItemScrollController _scrollController = ItemScrollController();

  FirebaseFirestore instance = FirebaseFirestore.instance;

  static final CameraPosition initialLatLong = CameraPosition(
    target: LatLng(13.7450094, 100.5397336),
    zoom: 18,
  );

  String _mapStyle = "";
  List<Shop> shops = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    rootBundle
        .loadString('assets/style.json')
        .then((value) => _mapStyle = value);
  }

  Future<void> fetchShops() async {
    var snapshot = await instance.collection('shops').get();

    List<Shop> shopList = [];
    List<Marker> markerList = [];
    snapshot.docs.forEach((element) {
      var data = element.data();
      var location = data['location'] as GeoPoint;
      var shop = Shop(
          name: data['name'],
          distance: data['distance'],
          price: data['price'],
          rating: data['rating'],
          location: LatLng(location.latitude, location.longitude));
      shopList.add(shop);
    });

    shopList.forEach((element) {
      final marker = Marker(
        markerId: MarkerId(element.name),
        position: element.location,
        infoWindow: InfoWindow(
          title: element.name
        )
      );
      markerList.add(marker);
    });

    setState(() {
      shops = shopList;
      markers = markerList.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: initialLatLong,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              _controller.complete(controller);
              fetchShops();
            },
            markers: markers,
          ),
          buildCarousel()
        ],
      ),
    );
  }

  Align buildCarousel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(bottom: 16),
        height: 140,
        child: ScrollablePositionedList.builder(
          scrollDirection: Axis.horizontal,
          itemScrollController: _scrollController,
          itemCount: shops.length,
          itemBuilder: (context, index) {
            return CarouselCard(model: shops[index]);
          },
        ),
      ),
    );
  }
}

class CarouselCard extends StatelessWidget {
  const CarouselCard({
    Key? key,
    required this.model
  }) : super(key: key);

  final Shop model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 300,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Color(0xFF9795EF),
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.all(16),
                    child: Image.asset('assets/cupcake.png'),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(model.name),
                        Text(model.price),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(model.distance),
                        ...List.generate(
                            model.rating,
                            (index) => Image.asset(
                                  'assets/star.png',
                                  height: 12,
                                  color: Color(0xFFF9C5D1),
                                )),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Image.asset(
                  'assets/right-arrow.png',
                  height: 18,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
