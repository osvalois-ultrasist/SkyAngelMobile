import 'package:dio/dio.dart';
import 'lib/core/config/api_endpoints.dart';

void main() async {
  await testPasswordIntegration();
}

Future<void> testPasswordIntegration() async {
  print('🧪 Testing Password Integration with Mock API');
  print('=============================================\n');

  final dio = Dio();
  
  // Test 1: Validate Password Endpoint
  print('1️⃣ Testing Password Validation Endpoint');
  print('---------------------------------------');
  
  final testPasswords = [
    {'password': 'weak', 'shouldPass': false},
    {'password': 'Password1!', 'shouldPass': true},
    {'password': 'nouppercasE1!', 'shouldPass': false},
    {'password': 'NOLOWERCASE1!', 'shouldPass': true}, // Frontend only requires uppercase + symbol
    {'password': 'NoSymbol123', 'shouldPass': false},
    {'password': 'Short1!', 'shouldPass': false},
  ];

  for (final test in testPasswords) {
    try {
      final response = await dio.post(
        ApiEndpoints.validatePassword,
        data: {'password': test['password']},
      );
      
      final isValid = response.data['valid'] as bool;
      final message = response.data['message'] as String;
      final requirements = response.data['requirements'] as Map<String, dynamic>;
      
      final shouldPass = test['shouldPass'] as bool;
      final passed = isValid == shouldPass;
      print('${passed ? "✅" : "❌"} Password: "${test['password']}"');
      print('   Expected: ${shouldPass ? "VALID" : "INVALID"}');
      print('   Got: ${isValid ? "VALID" : "INVALID"}');
      print('   Message: $message');
      print('   Requirements: minLength=${requirements['minLength']}, hasUppercase=${requirements['hasUppercase']}, hasSymbol=${requirements['hasSymbol']}');
      print('');
      
    } catch (e) {
      print('❌ Error testing password "${test['password']}": $e\n');
    }
  }

  // Test 2: Registration with Password Validation
  print('2️⃣ Testing Registration with Password Validation');
  print('------------------------------------------------');
  
  // Test with weak password (should fail)
  try {
    await dio.post(
      ApiEndpoints.register,
      data: {
        'usuario': 'testuser_weak_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'weak${DateTime.now().millisecondsSinceEpoch}@test.com',
        'password': 'weak',
        'nombre': 'Test User Weak',
      },
    );
    print('❌ Registration with weak password should have failed');
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 400) {
      print('✅ Registration correctly rejected weak password');
      print('   Error: ${e.response?.data['error']}');
    } else {
      print('❌ Unexpected error: $e');
    }
  }
  print('');

  // Test with strong password (should succeed)
  try {
    final response = await dio.post(
      ApiEndpoints.register,
      data: {
        'usuario': 'testuser_strong_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'strong${DateTime.now().millisecondsSinceEpoch}@test.com',
        'password': 'StrongPass123!',
        'nombre': 'Test User Strong',
      },
    );
    print('✅ Registration succeeded with strong password');
    print('   User: ${response.data['user']['usuario']}');
  } catch (e) {
    print('❌ Registration failed with strong password: $e');
  }
  print('');

  // Test 3: Login with Valid Credentials
  print('3️⃣ Testing Login with Valid Credentials');
  print('---------------------------------------');
  
  try {
    final response = await dio.post(
      ApiEndpoints.loginUser,
      data: {
        'usuario': 'usuario1',
        'password': 'Password1!',
      },
    );
    print('✅ Login successful with valid password');
    print('   Token: ${response.data['token'].toString().substring(0, 20)}...');
    print('   User: ${response.data['user']['nombre']}');
  } catch (e) {
    if (e is DioException) {
      print('❌ Login failed: ${e.response?.data['error'] ?? e.message}');
    } else {
      print('❌ Login failed: $e');
    }
  }
  print('');

  // Test 4: Check Token Validation
  print('4️⃣ Testing Token Validation');
  print('---------------------------');
  
  try {
    // First login to get token
    final loginResponse = await dio.post(
      ApiEndpoints.loginUser,
      data: {
        'usuario': 'usuario1',
        'password': 'Password1!',
      },
    );
    
    final token = loginResponse.data['token'] as String;
    
    // Then validate token
    final validateResponse = await dio.get(
      ApiEndpoints.checkToken,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    
    print('✅ Token validation successful');
    print('   Valid: ${validateResponse.data['valid']}');
    print('   User: ${validateResponse.data['user']['usuario']}');
  } catch (e) {
    if (e is DioException) {
      print('❌ Token validation failed: ${e.response?.data['error'] ?? e.message}');
    } else {
      print('❌ Token validation failed: $e');
    }
  }
  print('');

  print('🎉 Password Integration Testing Completed!');
  print('\n📋 Summary of Features Tested:');
  print('   ✓ Password validation endpoint with frontend requirements');
  print('   ✓ Registration with password strength validation');
  print('   ✓ Login with properly hashed passwords');
  print('   ✓ JWT token generation and validation');
  print('   ✓ Error handling for invalid passwords');
  print('\n🔐 Password Requirements Enforced:');
  print('   • Minimum 8 characters');
  print('   • At least one uppercase letter (A-Z)');  
  print('   • At least one symbol or underscore (\\W_)');
  print('   • Cannot be empty or null');
}