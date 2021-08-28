import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(MyApp());
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

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String _mapStyle = "";

  @override
  void initState() {
    super.initState();
    rootBundle
        .loadString('assets/style.json')
        .then((value) => _mapStyle = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              _controller.complete(controller);
            },
          ),
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
              itemCount: 2,
              itemBuilder: (context, index) {
                return CarouselCard();
              },
            ),
          ),
        );
  }
}

class CarouselCard extends StatelessWidget {
  const CarouselCard({
    Key? key,
  }) : super(key: key);

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
                        Text("text"),
                        Text("\$\$\$"),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text("36 km"),
                        ...List.generate(
                            5,
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
