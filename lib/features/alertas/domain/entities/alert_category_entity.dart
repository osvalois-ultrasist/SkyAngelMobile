import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_category_entity.freezed.dart';

@freezed
class AlertCategoryEntity with _$AlertCategoryEntity {
  const factory AlertCategoryEntity({
    required int id,
    required String nombre,
    required String descripcion,
  }) = _AlertCategoryEntity;
}

@freezed
class AlertSubcategoryEntity with _$AlertSubcategoryEntity {
  const factory AlertSubcategoryEntity({
    required int id,
    required int categoriaId,
    required String nombre,
    required String descripcion,
  }) = _AlertSubcategoryEntity;
}
