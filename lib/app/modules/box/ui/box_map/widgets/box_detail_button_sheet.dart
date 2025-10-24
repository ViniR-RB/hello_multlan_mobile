import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/config/env.dart';
import 'package:hello_multlan/app/core/extensions/number_pad.dart';
import 'package:hello_multlan/app/core/extensions/timeago.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_model.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/box_field_detail.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map_detail/box_map_detail_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map_detail/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

sealed class BoxDetailsBottomSheet {
  static void showBottomSheetBoxById(String boxId, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BoxDetailBottomSheetWidget(boxId: boxId),
    );
  }
}

class BoxDetailBottomSheetWidget extends StatefulWidget {
  final String boxId;

  const BoxDetailBottomSheetWidget({super.key, required this.boxId});

  @override
  State<BoxDetailBottomSheetWidget> createState() =>
      _BoxDetailBottomSheetWidgetState();
}

class _BoxDetailBottomSheetWidgetState
    extends State<BoxDetailBottomSheetWidget> {
  late final BoxMapDetailController controller;
  late final GetBoxByIdCommand getBoxByIdCommand;

  @override
  void initState() {
    super.initState();
    getBoxByIdCommand = Modular.get<GetBoxByIdCommand>();
    controller = BoxMapDetailController(getBoxByIdCommand: getBoxByIdCommand);

    // Buscar os dados da box quando o widget for inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getBoxById(widget.boxId);
    });

    getBoxByIdCommand.addListener(_onBoxDataChanged);
  }

  @override
  void dispose() {
    getBoxByIdCommand.removeListener(_onBoxDataChanged);
    super.dispose();
  }

  void _onBoxDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);

    return SizedBox(
      child: Container(
        height: height,
        padding: const EdgeInsets.only(top: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
          image: DecorationImage(
            opacity: 0.1,
            image: Assets.images.background1.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: ListenableBuilder(
          listenable: getBoxByIdCommand,
          builder: (context, child) {
            return switch (getBoxByIdCommand.state) {
              CommandLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              CommandSuccess(value: final BoxModel box) => _buildBoxContent(
                box,
                width,
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
                      'Erro ao carregar detalhes da caixa',
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
                      onPressed: () => controller.getBoxById(widget.boxId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildBoxContent(BoxModel box, double width) {
    final locale = Localizations.localeOf(context);

    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: width,
              height: 256,
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                child: CachedNetworkImage(
                  imageUrl: '${Env.publicStorage}${box.imageUrl}',

                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  errorWidget: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Text(
            "Informações gerais",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.blueAccent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.count(
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
                value: box.note ?? "Sem Atualização",
              ),
              BoxFieldDetail(
                label: "Ultima Atualização",
                value: box.createdAt.toString().toTimeAgo(
                  locale: locale,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: () => {
              Modular.to.pop(),
              Modular.to.pushNamed(
                "/box/edit/${box.id}",
                arguments: box,
              ),
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Editar",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
