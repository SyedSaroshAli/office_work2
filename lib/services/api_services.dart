import 'dart:convert';
import 'package:api_sqflite/models/subscription_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://karsaazebs.com/BMS/api/v1.php';

  /// Fetch all subscriptions
  Future<Subscriptions> fetchSubscriptions() async {
    final response = await http.get(
        Uri.parse('$baseUrl?table=bank_details&action=list'),
        headers: {'Authorization': 'Basic YWRtaW46YWRtaW4xMjM='});

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Subscriptions.fromJson(json);
    } else {
      throw Exception('Failed to fetch subscriptions');
    }
  }

  /// Create a new subscription
  createSubscription(Data data) async {
    final payload = jsonEncode(data.toJson());
    print(data);
    print('Payload: $payload');
    final response = await http.post(
      Uri.parse(
          'https://karsaazebs.com/BMS/api/v1.php?table=bank_details&action=insert'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic YWRtaW46YWRtaW4xMjM='
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'] ?? false;
    } else {
      throw Exception('Failed to create subscription');
    }
  }

  /// Update an existing subscription
  Future<bool> updateSubscription(String id, Data data) async {
    final response = await http.post(
      Uri.parse(
          'https://karsaazebs.com/BMS/api/v1.php?table=bank_details&action=update&editid1=$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'] ?? false;
    } else {
      throw Exception('Failed to update subscription');
    }
  }

  /// Delete a subscription
  Future<bool> deleteSubscription(String id) async {
    final response = await http.get(Uri.parse(
        'https://karsaazebs.com/BMS/api/v1.php?table=bank_details&action=delete&editid1=$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'] ?? false;
    } else {
      throw Exception('Failed to delete subscription');
    }
  }
}
