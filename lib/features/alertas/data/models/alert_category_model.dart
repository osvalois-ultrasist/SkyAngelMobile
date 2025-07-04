import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/alert_category_entity.dart';

part 'alert_category_model.freezed.dart';
part 'alert_category_model.g.dart';

@freezed
class AlertCategoryModel with _$AlertCategoryModel {
  const factory AlertCategoryModel({
    required int id,
    required String nombre,
    required String descripcion,
  }) = _AlertCategoryModel;

  factory AlertCategoryModel.fromJson(Map<String, dynamic> json) => _$AlertCategoryModelFromJson(json);
}

@freezed
class AlertSubcategoryModel with _$AlertSubcategoryModel {
  const factory AlertSubcategoryModel({
    required int id,
    @JsonKey(name: 'categoria_id') required int categoriaId,
    required String nombre,
    required String descripcion,
  }) = _AlertSubcategoryModel;

  factory AlertSubcategoryModel.fromJson(Map<String, dynamic> json) => _$AlertSubcategoryModelFromJson(json);
}

extension AlertCategoryModelExtension on AlertCategoryModel {
  AlertCategoryEntity toEntity() {
    return AlertCategoryEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
    );
  }
}

extension AlertSubcategoryModelExtension on AlertSubcategoryModel {
  AlertSubcategoryEntity toEntity() {
    return AlertSubcategoryEntity(
      id: id,
      categoriaId: categoriaId,
      nombre: nombre,
      descripcion: descripcion,
    );
  }
}
