import 'package:dartz/dartz.dart';

import '../error/app_error.dart';

abstract class UseCase<Type, Params> {
  Future<Either<AppError, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
