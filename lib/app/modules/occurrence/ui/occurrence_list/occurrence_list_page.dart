import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_app_bar_sliver.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_foreground.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/cancel_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/get_all_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/resolve_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/occurrence_list_controller.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/widgets/occurrence_detail_bottom_sheet.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/widgets/occurrence_list_item.dart';

class OccurrenceListPage extends StatefulWidget {
  final OccurrenceListController controller;
  final GetAllOccurrenceCommand getAllOccurrenceCommand;
  final CancelOccurrenceCommand cancelOccurrenceCommand;
  final ResolveOccurrenceCommand resolveOccurrenceCommand;
  const OccurrenceListPage({
    super.key,
    required this.controller,
    required this.getAllOccurrenceCommand,
    required this.cancelOccurrenceCommand,
    required this.resolveOccurrenceCommand,
  });

  @override
  State<OccurrenceListPage> createState() => _OccurrenceListPageState();
}

class _OccurrenceListPageState extends State<OccurrenceListPage>
    with LoaderMessageMixin, ErrorTranslator {
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();
  final reasonController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _setupCommandListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.getAllOccurrenceCommand.execute();
    });
  }

  void _setupCommandListeners() {
    widget.cancelOccurrenceCommand.addListener(_onCancelOccurrenceStateChange);
    widget.resolveOccurrenceCommand.addListener(
      _onResolveOccurrenceStateChange,
    );
  }

  void _onCancelOccurrenceStateChange() {
    final state = widget.cancelOccurrenceCommand.state;

    switch (state) {
      case CommandLoading():
        notifier.showLoader();
        break;
      case CommandSuccess():
        notifier.hideLoader();
        notifier.showMessage(
          "Ocorrência cancelada com sucesso!",
          SnackType.success,
        );
        widget.getAllOccurrenceCommand.execute(refresh: true);
        break;
      case CommandFailure(exception: final error):
        notifier.hideLoader();
        notifier.showMessage(
          translateError(context, error.code),
          SnackType.error,
        );
        break;
      default:
        break;
    }
  }

  void _onResolveOccurrenceStateChange() {
    if (!mounted || _isDisposed) return;

    final state = widget.resolveOccurrenceCommand.state;

    switch (state) {
      case CommandLoading():
        notifier.showLoader();
        break;
      case CommandSuccess():
        notifier.hideLoader();
        notifier.showMessage(
          "Ocorrência resolvida com sucesso!",
          SnackType.success,
        );
        // Recarregar a lista após resolver
        widget.getAllOccurrenceCommand.execute(refresh: true);
        break;
      case CommandFailure(exception: final error):
        notifier.hideLoader();
        notifier.showMessage(
          translateError(context, error.code),
          SnackType.error,
        );
        break;
      default:
        break;
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Para implementar infinite scroll futuramente
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Carregar mais dados quando chegar no final
        _loadMoreOccurrences();
      }
    });
  }

  void _loadMoreOccurrences() {
    if (widget.getAllOccurrenceCommand.canLoadMore) {
      widget.getAllOccurrenceCommand.loadMore();
    }
  }

  void _onOccurrenceAction(OccurrenceModel occurrence, String action) {
    if (!mounted || _isDisposed) return;

    switch (action) {
      case 'resolve':
        _showActionDialog(
          occurrence,
          'Resolver',
          'Deseja marcar esta ocorrência como resolvida?',
        );
        break;
      case 'cancel':
        _showCancelDialog(occurrence);
        break;
      case 'details':
        OccurrenceDetailBottomSheet.show(context, occurrence);
        break;
    }
  }

  void _showActionDialog(
    OccurrenceModel occurrence,
    String action,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Executar ação de resolver
              widget.controller.resolveOccurrence(occurrenceId: occurrence.id);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(OccurrenceModel occurrence) {
    reasonController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Ocorrência'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informe o motivo do cancelamento:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo do cancelamento',
                  hintText: 'Digite o motivo...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      value.length < 3) {
                    return 'O motivo do cancelamento é obrigatório.';
                  }
                  return null;
                },
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ValueListenableBuilder(
            valueListenable: reasonController,
            builder: (context, value, child) {
              return FilledButton(
                onPressed:
                    value.text.trim().isEmpty || value.text.trim().length < 3
                    ? null
                    : () {
                        final reason = reasonController.text.trim();
                        Modular.to.pop();
                        widget.controller.cancelOccurrence(
                          occurrenceId: occurrence.id,
                          cancelReason: reason,
                        );
                      },
                child: const Text('Confirmar'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    widget.cancelOccurrenceCommand.removeListener(
      _onCancelOccurrenceStateChange,
    );
    widget.resolveOccurrenceCommand.removeListener(
      _onResolveOccurrenceStateChange,
    );
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScaffoldForegroud(
        child: RefreshIndicator(
          onRefresh: () async {
            await widget.getAllOccurrenceCommand.execute(refresh: true);
          },
          child: SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const CustomSliverAppBar(
                  title: "Ocorrências",
                  actions: [],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Buscar ocorrências',
                              hintText: 'Digite para pesquisar...',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              // Implementar busca
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton.filledTonal(
                          onPressed: () {
                            // Implementar filtros
                            _showFilterDialog();
                          },
                          icon: const Icon(Icons.filter_list),
                        ),
                      ],
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.getAllOccurrenceCommand,
                  builder: (context, child) {
                    return switch (widget.getAllOccurrenceCommand.state) {
                      CommandSuccess(value: final pageModel) =>
                        pageModel.isEmpty
                            ? const SliverFillRemaining(
                                child: _EmptyState(),
                              )
                            : SliverList.separated(
                                itemCount:
                                    pageModel.length +
                                    (widget
                                            .getAllOccurrenceCommand
                                            .isLoadingMore
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index == pageModel.length) {
                                    // Loading indicator para load more
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final occurrence = pageModel.data[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: OccurrenceListItem(
                                      occurrence: occurrence,
                                      onAction: (action) => _onOccurrenceAction(
                                        occurrence,
                                        action,
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                              ),
                      CommandLoading() => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      CommandFailure(exception: final error) =>
                        SliverFillRemaining(
                          child: _ErrorState(
                            message: error.code,
                            onRetry: () =>
                                widget.getAllOccurrenceCommand.execute(),
                          ),
                        ),
                      _ => const SliverFillRemaining(
                        child: SizedBox(),
                      ),
                    };
                  },
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80), // Espaço para o FAB
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Todas'),
              trailing: widget.getAllOccurrenceCommand.currentStatus == null
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                widget.controller.filterByStatus(null);
              },
            ),
            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Criadas'),
              trailing:
                  widget.getAllOccurrenceCommand.currentStatus ==
                      OccurrenceStatus.CREATED
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                widget.controller.filterByStatus(OccurrenceStatus.CREATED);
              },
            ),
            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Resolvidas'),
              trailing:
                  widget.getAllOccurrenceCommand.currentStatus ==
                      OccurrenceStatus.RESOLVED
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                widget.controller.filterByStatus(OccurrenceStatus.RESOLVED);
              },
            ),
            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Canceladas'),
              trailing:
                  widget.getAllOccurrenceCommand.currentStatus ==
                      OccurrenceStatus.CANCELED
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                widget.controller.filterByStatus(OccurrenceStatus.CANCELED);
              },
            ),

            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'Nenhuma ocorrência encontrada',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nenhuma Ocorrência foi criada para você ainda.',
          style: TextStyle(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red[400],
        ),
        const SizedBox(height: 16),
        Text(
          'Erro ao carregar ocorrências',
          style: TextStyle(
            fontSize: 18,
            color: Colors.red[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}
