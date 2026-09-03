import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:re_trace/app.dart';
import 'package:re_trace/services/notification_service.dart';

export 'package:re_trace/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await NotificationService().init();
  await NotificationService().requestPermissions();
  
  runApp(ReTraceApp(prefs: prefs));
}
