import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository.dart';
import 'package:hello_multlan/app/modules/pagination/models/pagination_model.dart';

class GetAllOccurrenceCommand
    extends BaseCommand<PageModel<OccurrenceModel>, AppException> {
  final OccurrenceRepository _repository;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  OccurrenceStatus? _currentStatus;

  GetAllOccurrenceCommand({required OccurrenceRepository repository})
    : _repository = repository,
      super(CommandInitial(PageModel.empty()));

  @override
  void reset() {
    _currentPage = 1;
    _isLoadingMore = false;
    _currentStatus = null;
    setState(CommandInitial(PageModel.empty()));
  }

  Future<void> execute({
    int take = 10,
    bool refresh = false,
    OccurrenceStatus? status,
  }) async {
    // Atualiza o status atual se fornecido
    if (status != _currentStatus) {
      _currentStatus = status;
      _currentPage = 1;
      setState(CommandLoading());
    } else if (refresh) {
      _currentPage = 1;
      setState(CommandLoading());
    }

    final occurrenceListResult = await _repository.getUserOccurrences(
      page: _currentPage,
      take: take,
      status: _currentStatus,
    );

    occurrenceListResult.when(
      onSuccess: (newPageModel) {
        final currentState = state;

        if (refresh || _currentPage == 1) {
          // Primeira carga ou refresh
          setState(CommandSuccess(newPageModel));
        } else if (currentState
            is CommandSuccess<PageModel<OccurrenceModel>, AppException>) {
          // Append para infinite scroll
          final updatedPageModel = currentState.value.appendPage(
            PageModel(data: newPageModel.data, meta: newPageModel.meta),
          );

          setState(CommandSuccess(updatedPageModel));
        }
      },
      onFailure: (error) {
        setState(CommandFailure(error));
      },
    );
  }

  Future<void> loadMore({int take = 10}) async {
    final currentState = state;

    if (_isLoadingMore ||
        currentState
            is! CommandSuccess<PageModel<OccurrenceModel>, AppException> ||
        !currentState.value.canLoadMore) {
      return;
    }

    _isLoadingMore = true;
    _currentPage++;

    final occurrenceListResult = await _repository.getUserOccurrences(
      page: _currentPage,
      take: take,
      status: _currentStatus,
    );

    occurrenceListResult.when(
      onSuccess: (newPageModel) {
        final currentPageModel = currentState.value;
        final combinedData = [
          ...newPageModel.data,
        ];

        final updatedPageModel = PageModel<OccurrenceModel>(
          data: combinedData,
          meta: newPageModel.meta,
        );

        setState(CommandSuccess(currentPageModel.appendPage(updatedPageModel)));
        _isLoadingMore = false;
      },
      onFailure: (error) {
        _currentPage--;
        _isLoadingMore = false;
      },
    );
  }

  bool get canLoadMore {
    final currentState = state;
    return currentState
            is CommandSuccess<PageModel<OccurrenceModel>, AppException> &&
        currentState.value.canLoadMore &&
        !_isLoadingMore;
  }

  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  OccurrenceStatus? get currentStatus => _currentStatus;
}
