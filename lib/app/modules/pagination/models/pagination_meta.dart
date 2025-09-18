import 'package:json_annotation/json_annotation.dart';

part 'pagination_meta.g.dart';

@JsonSerializable()
class PageMeta {
  final int page;
  final int take;
  final int itemCount;
  final int pageCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PageMeta({
    required this.page,
    required this.take,
    required this.itemCount,
    required this.pageCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) =>
      _$PageMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PageMetaToJson(this);

  // Método para criar meta vazia
  factory PageMeta.empty() {
    return PageMeta(
      page: 1,
      take: 0,
      itemCount: 0,
      pageCount: 0,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  // Métodos de conveniência
  int get nextPage => hasNextPage ? page + 1 : page;
  int get previousPage => hasPreviousPage ? page - 1 : page;

  @override
  String toString() {
    return 'PageMeta(page: $page, take: $take, total: $itemCount, hasNext: $hasNextPage)';
  }
}
