import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/models/geo_location.dart';

/// Identify the current location of the device
Future<GeoLocation> identifyDeviceLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // User allows access, but the location services of the device are disabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return Future.error('Location services are disabled');

  permission = await Geolocator.checkPermission();

  /// [LocationPermission.denied] is the initial state on both Android and iOS
  if (permission == LocationPermission.denied)
    permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.deniedForever)
    return Future.error(
        'Location permissions are permanently denied, we cannot find your current location');

  final geoPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);

  /// [name] is the name of a building, [street] is the address of this building
  /// [administrativeArea] is the state or province -> [locality] is the city
  List<Placemark> placemarks = await placemarkFromCoordinates(
      geoPosition.latitude, geoPosition.longitude);

  final placemark = placemarks[0];
  final addressBuilder = StringBuffer();
  addressBuilder.writeAll([
    placemark.street,
    placemark.subLocality,
    placemark.subAdministrativeArea,
    placemark.locality,
    placemark.country
  ], ', ');

  return GeoLocation(
    latitule: geoPosition.latitude,
    longitude: geoPosition.longitude,
    address: addressBuilder.toString(),
  );
}
