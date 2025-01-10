import 'dart:async';
import 'package:api_sqflite/models/subscription_model.dart';
import 'package:api_sqflite/services/api_services.dart';
import 'package:api_sqflite/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class TimerService extends GetxController {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Timer? timer;
  RxBool isConnected = false.obs;
  RxList<Data> subscriptions = <Data>[].obs;
  StreamSubscription? streamSubscription;

  void startRealTimeTimer({required context}) async {
    // Perform the API call immediately when the app starts if connected to the internet
    final prefs = await SharedPreferences.getInstance();
    final lastApiCall = prefs.getInt('lastApiCall') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lastApiCall == 0 && isConnected.value) {
      fetchDataFromApiAndUpdateDatabase();
      await prefs.setInt('lastApiCall', currentTime);
    } else if (lastApiCall == 0 && isConnected.value == false) {
      fetchDataFromDatabase();
    }

    timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedLastApiCall = prefs.getInt('lastApiCall') ?? 0;
      final updatedCurrentTime = DateTime.now().millisecondsSinceEpoch;

      if (updatedCurrentTime - updatedLastApiCall >= 15 * 60 * 1000 &&
          isConnected.value == true) {
        fetchDataFromApiAndUpdateDatabase();
        print('Fetched data from api and updated local database');
        await prefs.setInt('lastApiCall', currentTime);
        // fetchDataFromUpdatedTableAndUploadToApi();

        // _dbHelper.deleteAllUpdatedSubscriptions();
        // fetchDataFromDeletedTableAndDeleteFromAPI();
        //_dbHelper.deleteAllDeletedSubscriptions();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('15 min passed: Api get call executed')));
        await prefs.setInt('lastApiCall', currentTime);
      } else if (currentTime - lastApiCall < 15 * 60 * 1000) {
        fetchDataFromDatabase();
      }
    });
  }

  void listenToInternetChanges({required BuildContext context}) {
    streamSubscription = InternetConnection().onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        _dbHelper.deleteAllSubscriptions();
        fetchDataFromApiAndUpdateDatabase();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Internet connected')));
        print('Internet is connected');
        isConnected.value = true;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Internet is not connected')));
        print('Internet is not connected');
        isConnected.value = false;
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  fetchDataFromApiAndUpdateDatabase() async {
    try {
      final apiData = await _apiService.fetchSubscriptions();

      if (apiData.data != null) {
        await _dbHelper.deleteAllDeletedSubscriptions();

        for (var item in apiData.data!) {
          await _dbHelper.insertSubscription(item);
        }

        // Use assignAll to notify observers
        subscriptions.assignAll(apiData.data!);

        print('Subscriptions updated: ${subscriptions.length} items');
      }
    } catch (error) {
      print("Error while fetching data and updating database: $error");
    }
  }

  // fetchDataFromApiAndUpdateDatabase() async {
  //   try {
  //     // Fetch data from the API
  //     final apiData = await _apiService.fetchSubscriptions();

  //     // Ensure the fetched data is not null
  //     if (apiData.data != null) {
  //       // Optionally: clear the existing subscriptions in the database if necessary
  //       await _dbHelper
  //           .deleteAllDeletedSubscriptions(); // Assumes a method to clear all data

  //       // Insert new data into the database
  //       for (var item in apiData.data!) {
  //         // Insert or update the subscription in the database
  //         await _dbHelper.insertSubscription(item);
  //       }

  //       // Once all database operations are complete, update the UI with the new data
  //       subscriptions.value = apiData.data!;

  //       // Log to confirm the subscriptions have been updated
  //       print('Subscriptions updated: ${subscriptions.length} items');
  //     }
  //   } catch (error) {
  //     print("Error while fetching data and updating database: $error");
  //     // Optionally: show a UI message or snackbar in case of error
  //   }
  // }

  fetchDataFromDatabase() async {
    final localData = await _dbHelper.getAllSubscriptions();
    subscriptions.assignAll(localData); // Notify observers of changes
    print('Fetched data from local database');
  }

  // fetchDataFromDatabase() async {
  //   final localData = await _dbHelper.getAllSubscriptions();
  //   subscriptions.value = localData;
  //   //return localData;
  // }

  fetchDataFromUpdatedTableAndUploadToApi() async {
    final List<Data> updatedData = await _dbHelper.getAllUpdatedSubscriptions();
    for (var item in updatedData) {
      await _apiService.updateSubscription(item.id.toString(), item);
    }
  }

  fetchDataFromDeletedTableAndDeleteFromAPI() async {
    final List<Data> deletedData = await _dbHelper.getAllDeletedSubscriptions();
    for (var item in deletedData) {
      await _apiService.deleteSubscription(item.id.toString());
    }
  }

  checkInternetThenGet({required context}) async {
    listenToInternetChanges(context: context);
    if (isConnected.value) {
      fetchDataFromApiAndUpdateDatabase();
      print('Fetched data from api and updated database');
      fetchDataFromUpdatedTableAndUploadToApi();
      _dbHelper.deleteAllUpdatedSubscriptions();
      fetchDataFromDeletedTableAndDeleteFromAPI();
      _dbHelper.deleteAllDeletedSubscriptions();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data Synced to Api')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please Turn on Internet Connection to Sync')));
    }
  }
}
