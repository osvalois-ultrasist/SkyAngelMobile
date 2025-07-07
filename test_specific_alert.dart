// Test the specific alert statistics endpoint
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Alert Statistics Endpoint...\n');
  
  const baseUrl = 'http://localhost:3001';
  const endpoint = '/api/alerts/alertas/estadisticas';
  final url = '$baseUrl$endpoint';
  
  print('Testing: $url\n');
  
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('📊 Response:');
    print('   Status: ${response.statusCode}');
    print('   Headers: ${response.headers}');
    print('');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ SUCCESS! Alert statistics endpoint working');
      print('📋 Statistics data:');
      print(const JsonEncoder.withIndent('  ').convert(data));
    } else {
      print('❌ Error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    
  } catch (e) {
    print('❌ Request failed: $e');
  }
  
  print('\n🔧 The issue is that the Flutter app is not using the updated configuration.');
  print('Solution: Complete restart of the Flutter app is needed.');
}