import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const ImageSourceBottomSheet({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          const Text(
            'Selecionar Foto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            'Escolha de onde você deseja obter a foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Opções
          Column(
            children: [
              // Câmera
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Câmera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Tirar uma nova foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  Modular.to.pop();
                  onCameraPressed();
                },
              ),
              const SizedBox(height: 16),

              // Galeria
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Galeria',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Escolher da galeria de fotos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  Modular.to.pop();
                  onGalleryPressed();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botão cancelar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Modular.to.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          // Espaço para safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
