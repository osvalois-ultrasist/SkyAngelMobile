import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request.freezed.dart';

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    required String name,
    required String familyName,
    String? phoneNumber,
  }) = _RegisterRequest;

  const RegisterRequest._();
}