import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/config/env.dart';
import 'package:hello_multlan/app/core/extensions/number_pad.dart';
import 'package:hello_multlan/app/core/extensions/timeago.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_model.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/box_field_detail.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map_detail/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class BoxMapDetailPage extends StatefulWidget {
  final String boxId;
  final GetBoxByIdCommand getBoxByIdCommand;
  const BoxMapDetailPage({
    super.key,
    required this.boxId,
    required this.getBoxByIdCommand,
  });

  @override
  State<BoxMapDetailPage> createState() => _BoxMapDetailPageState();
}

class _BoxMapDetailPageState extends State<BoxMapDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.getBoxByIdCommand.addListener(_getBoxListener);
    // Buscar a caixa quando a página for carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.getBoxByIdCommand.execute(widget.boxId);
    });
  }

  @override
  void dispose() {
    widget.getBoxByIdCommand.removeListener(_getBoxListener);
    super.dispose();
  }

  void _getBoxListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Caixa'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: widget.getBoxByIdCommand,
        builder: (context, child) {
          return switch (widget.getBoxByIdCommand.state) {
            CommandLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            CommandSuccess(value: final BoxModel box) => _buildBoxDetails(
              box,
              locale,
            ),
            CommandFailure(exception: final exception) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar caixa',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exception.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        widget.getBoxByIdCommand.execute(widget.boxId),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildBoxDetails(BoxModel box, Locale locale) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          opacity: 0.1,
          image: Assets.images.background1.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Imagem da caixa
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: width,
              height: 256,
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                child: Image.network(
                  '${Env.publicStorage}${box.imageUrl}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título da caixa
          Text(
            box.label,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Título da seção
          const Text(
            "Informações gerais",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 16),

          // Grid com informações
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              BoxFieldDetail(
                label: "Espaço Total:",
                value: box.freeSpace.toString().padZero(),
              ),
              BoxFieldDetail(
                label: "Clientes ativos:",
                value: box.filledSpace.toString().padZero(),
              ),
              BoxFieldDetail(
                label: "Clientes:",
                value: box.listUser
                    .toString()
                    .replaceFirst("[", "")
                    .replaceFirst("]", ""),
              ),
              BoxFieldDetail(
                label: "Sinal:",
                value: box.signal.toStringAsFixed(1),
              ),
              BoxFieldDetail(
                label: "Nota",
                value: box.note?.isEmpty ?? true
                    ? "Sem Atualização"
                    : box.note!,
              ),
              BoxFieldDetail(
                label: "Ultima Atualização",
                value: box.createdAt.toString().toTimeAgo(
                  locale: locale,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Botão de editar
          ElevatedButton(
            onPressed: () {
              // Navegar para a página de edição
              Navigator.pop(context);
              // Você pode implementar a navegação para edição aqui
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Editar",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
