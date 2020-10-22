import 'package:GupShup/customLocation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';

// Class to hold latLong values

class ShowLocation extends StatefulWidget {
  ShowLocation({Key key}) : super(key: key);

  @override
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  @override
  Widget build(BuildContext context) {
    return
        //Text("lol")
        StreamProvider<UserLocation>(
      create: (context) => LocationService().locationStream,
      //builder:(context) => Text("lol"),
      child: Scaffold(appBar: AppBar(title: Text('GupShup')), body: Mapwid()),
    );
  }
}

class Mapwid extends StatefulWidget {
  const Mapwid({Key key}) : super(key: key);

  @override
  _MapwidState createState() => _MapwidState();
}

class _MapwidState extends State<Mapwid> {
  Completer<GoogleMapController> _controller = Completer();

  var curLoc = "home";
  List<Address> _address = [];
  bool addressFound = false;

  void _findAddress(double lat, double lon) async {
    var x = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(lat, lon));

    setState(() {
      _address = x;
      addressFound = true;
    });
    print("Address found : ");
    print(_address[0].addressLine);
  }

  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);
    print(
        "lat : ${userLocation?.latitude}   lon : ${userLocation?.longitude} ");
    if (userLocation == null)
      return Center(child: CircularProgressIndicator());
    else {
      var _markers = <Marker>{
        Marker(
            markerId: MarkerId(curLoc),
            position: LatLng(userLocation?.latitude, userLocation?.longitude))
      };
      return Container(
        height: 700,
        child:
            // Text(
            //     "lat : ${userLocation?.latitude}   lon : ${userLocation?.longitude} "),
            Stack(
          children: [
            GoogleMap(
              // minMaxZoomPreference: MinMaxZoomPreference(32, 234),
              // 2
              markers: _markers,

              initialCameraPosition: CameraPosition(
                target: LatLng(userLocation?.latitude, userLocation?.longitude),
                zoom: 14,
              ),
              // 3
              mapType: MapType.normal,
              // 4
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Container(
                color: Colors.blue,
                height: 100,
                width: double.infinity,
                child: Center(
                    child: Column(
                  children: [
                    addressFound
                        ? Container(
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(_address[0].addressLine),
                            ))
                        : Container(
                            height: 50,
                            width: double.infinity,
                          ),
                    FlatButton(
                      color: Colors.blue[300],
                      child: Text("Click to get your location details"),
                      onPressed: () {
                        _findAddress(
                            userLocation?.latitude, userLocation?.longitude);
                      },
                    ),
                  ],
                )))
          ],
        ),
      );
    }
  }
}
