import 'package:api_sqflite/screens/details_screen.dart';
import 'package:api_sqflite/screens/subscription_form_screen.dart';
import 'package:api_sqflite/services/database_helper.dart';
import 'package:api_sqflite/services/timer_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  _SubscriptionListScreenState createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  final controller = Get.put(TimerService());
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    controller.listenToInternetChanges(context: context);
    controller.startRealTimeTimer(context: context);
    ever(controller.subscriptions, (_) {
      setState(() {}); // Updates the UI whenever subscriptions change
    });
  }

  checkInternetThenGet({required context}) {
    if (controller.isConnected.value) {
      controller.fetchDataFromApiAndUpdateDatabase();
      print('Fetched data from api and updated database');
      //controller.fetchDataFromUpdatedTableAndUploadToApi();
      //dbHelper.deleteAllUpdatedSubscriptions();
      // controller.fetchDataFromDeletedTableAndDeleteFromAPI();
      // dbHelper.deleteAllDeletedSubscriptions();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data Synced to Api')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please Turn on Internet Connection to Sync')));
    }
  }

  @override
  void dispose() {
    controller.timer?.cancel();
    controller.streamSubscription?.cancel();
    super.dispose();
  }

  // void _listenToInternetChanges() {
  //   streamSubscription = InternetConnection().onStatusChange.listen((event) {
  //     if (event == InternetStatus.connected) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('You are Connected to Internet')));

  //       setState(() => isConnected = true);
  //     } else {
  //       showDialog(
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //               title: const Text('Internet Error'),
  //               content: const Text('Internet Not connected'),
  //               actions: [
  //                 GestureDetector(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text('Ok'))
  //               ],
  //             );
  //           });
  //       setState(() => isConnected = false);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Subscriptions List',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      content: const Text(
                          'Your Local database is synced to API every 15 minutes. Do you want to sync now ?'),
                      actions: [
                        GestureDetector(
                          onTap: () {
                            checkInternetThenGet(context: context);
                            Navigator.pop(context);
                          },
                          child: Text('Yes'),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SubscriptionFormScreen()),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.subscriptions.isEmpty) {
          return const Center(
            child: Text(
              'No subscriptions found.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: controller.subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = controller.subscriptions[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionDetailsPage(
                        id: subscription.id.toString(),
                        userId: subscription.userId.toString(),
                        accountNumber: subscription.accountNumber.toString(),
                        bankName: subscription.bankName.toString(),
                        branchCode: subscription.branchCode.toString(),
                        accounHolderName:
                            subscription.accountHolderName.toString(),
                        currencyId: subscription.currencyId.toString(),
                        cardNumber: subscription.cardNumber.toString(),
                        cardCreationDate:
                            subscription.cardCreationDate.toString(),
                        cardExpiryDate: subscription.cardExpiryDate.toString(),
                        phoneNumber: subscription.phoneNumber.toString(),
                        emailAddress: subscription.emailAddress.toString(),
                        balance: subscription.balance.toString(),
                        cvv: subscription.cvv.toString(),
                        accountTypeId: subscription.accountTypeId.toString(),
                        accountStatusId:
                            subscription.accountStatusId.toString(),
                        createdOn: subscription.createdOn.toString(),
                        branchName: subscription.branchName.toString(),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade800,
                        blurRadius: 15,
                        offset: const Offset(4, 4),
                      ),
                      const BoxShadow(
                        color: Colors.black,
                        blurRadius: 15,
                        offset: Offset(-4, -4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade900,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Holder Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subscription.accountHolderName ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Account Number',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subscription.accountNumber ?? '----------',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Bank Name ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subscription.bankName ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
