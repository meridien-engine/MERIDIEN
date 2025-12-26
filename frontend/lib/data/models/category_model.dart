import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  bool get isRoot => parentId == null;
}
