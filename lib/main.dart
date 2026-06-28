import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/connectivity_service.dart';
import 'services/iap_service.dart';
import 'services/paystack_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database (required for scheduled notifications)
  tz.initializeTimeZones();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize AdMob
  await MobileAds.instance.initialize();
  await AdService.instance.initialize();

  // Initialize notifications
  await NotificationService.instance.initialize();

  // Init prefs
  await SharedPreferences.getInstance();

  // Initialize connectivity monitoring (must be last before runApp)
  await ConnectivityService.instance.initialize();

  // Initialize IAP (loads product + restores purchases from store)
  await IapService.instance.initialize();

  // Initialize Paystack (fallback billing for non-Play-Store installs)
  await PaystackService.instance.initialize();

  runApp(const RedFlagNamesApp());
}
