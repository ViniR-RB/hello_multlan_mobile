import 'package:hello_multlan/app/modules/pagination/models/pagination_meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PageModel<T> {
  final List<T> data;
  final PageMeta meta;

  PageModel({
    required this.data,
    required this.meta,
  });

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PageModelToJson(this, toJsonT);

  // Métodos de conveniência
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;

  // Getter para verificar se tem mais páginas
  bool get canLoadMore => meta.hasNextPage;
  bool get canLoadPrevious => meta.hasPreviousPage;

  // Método para criar uma página vazia
  factory PageModel.empty() {
    return PageModel<T>(
      data: [],
      meta: PageMeta.empty(),
    );
  }

  // Método para combinar páginas (útil para infinite scroll)
  PageModel<T> appendPage(PageModel<T> nextPage) {
    return PageModel<T>(
      data: [...data, ...nextPage.data],
      meta: nextPage.meta,
    );
  }

  @override
  String toString() {
    return 'PageModel(items: ${data.length}, page: ${meta.page}/${meta.pageCount})';
  }
}
