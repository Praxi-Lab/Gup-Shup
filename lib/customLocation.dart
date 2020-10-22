import 'package:location/location.dart';
import 'dart:async';

// Class to hold latLong values
class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({this.latitude, this.longitude});
}

// Main location class with all the methods
class LocationService {
  // this will hold the currentLocation
  UserLocation _currentLocation;

  LocationService() {
    getLocation();
    updateLocation();
  }

  var location = Location();
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      print("got new user location");
      print(
          "lat : ${userLocation?.latitude}   lon : ${userLocation?.longitude} ");
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }

  updateLocation() {
    location.onLocationChanged.listen((locationData) {
      if (locationData != null) {
        _locationController.add(UserLocation(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
        ));
        print("got updated user location");
        print(
            "lat : ${locationData?.latitude}   lon : ${locationData?.longitude} ");
      }
    });
  }
}
