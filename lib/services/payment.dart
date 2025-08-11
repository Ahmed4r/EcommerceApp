import 'dart:convert';

import 'package:http/http.dart' as http;

class PaymobService {
  static const String baseUrl = 'https://accept.paymob.com/api';
  static const String apiKey = 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBeU1EVXhNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5pVG4zdFFRRk9zLXlpMHpTaEJmdXlzTExncGdqLVZIMzlDX2g5Yk5paHFoWWhLSmk3S0F6OHdRM0xxUXVlN25YN0JUSUdoX05iMHNHbUJ6elNacTFZdw=='; // Replace with your actual API key
  static const int integrationId = 4938727; // Replace with your actual integration ID
  static const int iframeId =896802;
  
   // Replace with your actual iframe ID

  static Future<String> authenticate() async {
    const endpoint = 'auth/tokens';
    final requestData = {'api_key': apiKey};
    
    try {
      PaymobTracker.logRequest(endpoint, requestData);
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      PaymobTracker.logResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Auth Token: ${data['token'].substring(0, 20)}...');
        return data['token'];
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Auth failed: ${errorData.toString()}');
      }
    } catch (e) {
      PaymobTracker.logError('Authentication', e);
      rethrow;
    }
  }

  static Future<int> createOrder(String authToken, double amount) async {
    const endpoint = 'ecommerce/orders';
    final requestData = {
      'auth_token': authToken,
      'delivery_needed': false,
      'amount_cents': (amount * 100).toInt(),
      'currency': 'EGP',
      'items': [],
    };
    
    try {
      PaymobTracker.logRequest(endpoint, requestData);
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      PaymobTracker.logResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Order ID: ${data['id']}');
        return data['id'];
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Order creation failed: ${errorData.toString()}');
      }
    } catch (e) {
      PaymobTracker.logError('Order Creation', e);
      rethrow;
    }
  }

  static Future<String> getPaymentKey(String authToken, int orderId, double amount, String cardholderName) async {
    const endpoint = 'acceptance/payment_keys';
    
    final names = cardholderName.trim().split(' ');
    final firstName = names.isNotEmpty && names[0].isNotEmpty ? names[0] : 'John';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Doe';

    final requestData = {
      'auth_token': authToken,
      'amount_cents': (amount * 100).toInt(),
      'expiration': 3600,
      'order_id': orderId,
      'billing_data': {
        'apartment': 'NA',
        'email': 'ahmedrady03@gmail.com',
        'floor': 'NA',
        'first_name': firstName,
        'street': 'Test Street',
        'building': 'NA',
        'phone_number': '+201091541856',
        'shipping_method': 'PKG',
        'postal_code': '12345',
        'city': 'Cairo',
        'country': 'EG',
        'last_name': lastName,
        'state': 'Cairo',
      },
      'currency': 'EGP',
      'integration_id': integrationId,
    };
    
    try {
      PaymobTracker.logRequest(endpoint, requestData);
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      PaymobTracker.logResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Payment Token: ${data['token'].substring(0, 20)}...');
        return data['token'];
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Payment key failed: ${errorData.toString()}');
      }
    } catch (e) {
      PaymobTracker.logError('Payment Key Generation', e);
      rethrow;
    }
  }
  
}
class PaymobTracker {
  static void logRequest(String endpoint, Map<String, dynamic> data) {
    print('🚀 REQUEST to $endpoint');
    print('📤 Data: ${json.encode(data)}');
    print('⏰ Time: ${DateTime.now()}');
    print('─' * 50);
  }
  
  static void logResponse(String endpoint, int statusCode, String body) {
    print('📨 RESPONSE from $endpoint');
    print('📊 Status: $statusCode');
    print('📄 Body: $body');
    print('⏰ Time: ${DateTime.now()}');
    print('─' * 50);
  }
  
  static void logError(String operation, dynamic error) {
    print('❌ ERROR in $operation');
    print('🔥 Error: $error');
    print('⏰ Time: ${DateTime.now()}');
    print('═' * 50);
  }
}