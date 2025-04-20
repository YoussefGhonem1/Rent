  import 'package:url_launcher/url_launcher.dart';

Future<void> OpenMap({required String location}) async {
    final query = Uri.encodeComponent(location); // المكان اللي في الداتا
    final googleMapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(googleMapUrl)) {
      print(googleMapUrl.toString());

      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }