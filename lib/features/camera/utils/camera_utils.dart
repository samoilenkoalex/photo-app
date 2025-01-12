import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';

///Adds geotag to image
Future<void> writeExifData(String imagePath, Position position) async {
  final exif = await Exif.fromPath(imagePath);
  final now = DateTime.now().toUtc();
  final gpsTimeStamp = '${now.hour}:${now.minute}:${now.second}';

  await exif.writeAttributes({
    'GPSLatitude': position.latitude.abs(),
    'GPSLongitude': position.longitude.abs(),
    'GPSTimeStamp': gpsTimeStamp,
    'GPSDateStamp': '${now.year}:${now.month.toString().padLeft(2, '0')}:${now.day.toString().padLeft(2, '0')}',
  });

  await exif.close();
}
