import 'package:api_sqflite/screens/subs_screen_list.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Subscription Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SubscriptionListScreen(),
    );
  }
}
