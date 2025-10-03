import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/extensions/theme_extension.dart';
import 'package:hello_multlan/app/core/extensions/timeago.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/box_detail_button_sheet.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class OccurrenceDetailBottomSheet extends StatelessWidget {
  final OccurrenceModel occurrence;

  const OccurrenceDetailBottomSheet({
    super.key,
    required this.occurrence,
  });

  static Future<void> show(
    BuildContext context,
    OccurrenceModel occurrence,
  ) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OccurrenceDetailBottomSheet(
        occurrence: occurrence,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        image: DecorationImage(
          opacity: 0.1,
          image: Assets.images.background1.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    size: 28,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occurrence.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor().withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  _buildSection(
                    title: 'Descrição',
                    child: Text(
                      occurrence.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informações gerais
                  _buildSection(
                    title: 'Informações',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: 'Criado em',
                          value: occurrence.createdAt.toString().toTimeAgo(),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.update,
                          label: 'Atualizado em',
                          value: occurrence.updatedAt.toString().toTimeAgo(),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.tag,
                          label: 'ID',
                          value: '${occurrence.id.substring(0, 8)}...',
                        ),
                      ],
                    ),
                  ),

                  // Box associada (se existir)
                  if (occurrence.boxId != null) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Box Associada',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              color: colors.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Box ID',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${occurrence.boxId!.substring(0, 8)}...',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                BoxDetailsBottomSheet.showBottomSheetBoxById(
                                  occurrence.boxId!,
                                  context,
                                );
                              },
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Ver Box'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Motivo do cancelamento (se existir)
                  if (occurrence.status == OccurrenceStatus.CANCELED &&
                      occurrence.canceledReason != null) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Motivo do Cancelamento',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Colors.red[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                occurrence.canceledReason!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 80), // Espaço para os botões
                ],
              ),
            ),
          ),

          // Botões de ação (apenas para ocorrências criadas)
          if (occurrence.status == OccurrenceStatus.CREATED)
            Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCancelDialog(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showResolveDialog(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Resolver'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    return switch (occurrence.status) {
      OccurrenceStatus.CREATED => Colors.blue,
      OccurrenceStatus.RESOLVED => Colors.green,
      OccurrenceStatus.CANCELED => Colors.red,
    };
  }

  IconData _getStatusIcon() {
    return switch (occurrence.status) {
      OccurrenceStatus.CREATED => Icons.schedule,
      OccurrenceStatus.RESOLVED => Icons.check_circle,
      OccurrenceStatus.CANCELED => Icons.cancel,
    };
  }

  String _getStatusText() {
    return switch (occurrence.status) {
      OccurrenceStatus.CREATED => 'Em Andamento',
      OccurrenceStatus.RESOLVED => 'Resolvida',
      OccurrenceStatus.CANCELED => 'Cancelada',
    };
  }

  void _showResolveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver Ocorrência'),
        content: const Text('Deseja marcar esta ocorrência como resolvida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar resolveOccurrenceCommand
              // resolveOccurrenceCommand.execute(occurrence.id);
            },
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Ocorrência'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Informe o motivo do cancelamento:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo do cancelamento',
                hintText: 'Digite o motivo...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                // TODO: Implementar cancelOccurrenceCommand
                // cancelOccurrenceCommand.execute(occurrence.id, reasonController.text);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
