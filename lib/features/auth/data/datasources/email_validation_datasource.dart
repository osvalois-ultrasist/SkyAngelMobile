import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/network/dio_client.dart';

abstract class EmailValidationDataSource {
  Future<bool> checkEmailAuthorization(String email);
}

@LazySingleton(as: EmailValidationDataSource)
class EmailValidationDataSourceImpl implements EmailValidationDataSource {
  final DioClient _dioClient;

  EmailValidationDataSourceImpl(this._dioClient);

  @override
  Future<bool> checkEmailAuthorization(String email) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.validateEmail,
        data: {'correo': email},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['auth'] == 1;
      }

      throw const AppError(
        message: 'Usuario no autorizado',
        code: 'EMAIL_NOT_AUTHORIZED',
      );
    } on DioException catch (e) {
      throw AppError(
        message: e.response?.data['message'] ?? 'Error al validar correo',
        code: 'EMAIL_VALIDATION_ERROR',
      );
    } catch (e) {
      throw AppError(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      );
    }
  }
}