import 'package:flutter/material.dart';
import 'package:trucaralho/screens/home.dart';
import 'package:trucaralho/logic/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleNotification.init();
  runApp(const MaterialApp(home: HomePage(), title: 'Trucaralho'));
}
