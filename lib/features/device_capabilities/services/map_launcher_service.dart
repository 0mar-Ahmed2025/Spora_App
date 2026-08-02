import 'package:url_launcher/url_launcher.dart';

abstract class MapLauncherService {
  Future<bool> openMap(double latitude, double longitude);
}

class MapLauncherServiceImpl implements MapLauncherService {
  @override
  Future<bool> openMap(double latitude, double longitude) async {
    final Uri geoUri = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude',
    );
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      // 1. try open via geo: intent
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
      // 2. try open via link Google Maps Web/App
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
      // 3. final trying
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
