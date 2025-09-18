import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum SnackType { error, success, info }

class LoaderMessageNotifier extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  SnackType? _type;
  // ignore: prefer_final_fields
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get message => _message;
  SnackType? get type => _type;

  void showLoader() {
    _isLoading = true;
    _safeNotify();
  }

  void hideLoader() {
    _isLoading = false;
    _safeNotify();
  }

  void showMessage(String message, SnackType type) {
    _message = message;
    _type = type;
    _safeNotify();

    Future.microtask(() {
      _message = null;
      _type = null;
    });
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }
}

mixin LoaderMessageMixin<T extends StatefulWidget> on State<T> {
  late final LoaderMessageNotifier notifier;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    notifier = LoaderMessageNotifier();
    notifier.addListener(_handleNotifier);
  }

  void _handleNotifier() {
    if (!mounted) return;

    // Loader
    if (notifier.isLoading && !_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        builder: (_) => LoadingAnimationWidget.threeArchedCircle(
          color: Colors.blue,
          size: 60,
        ),
        barrierDismissible: false,
      );
    } else if (!notifier.isLoading && _isDialogOpen) {
      _isDialogOpen = false;
      Modular.to.pop();
    }

    if (notifier.message != null && notifier.type != null) {
      final overlay = Overlay.of(context);

      switch (notifier.type!) {
        case SnackType.error:
          showTopSnackBar(
            overlay,
            CustomSnackBar.error(message: notifier.message!),
          );
          break;
        case SnackType.success:
          showTopSnackBar(
            overlay,
            CustomSnackBar.success(message: notifier.message!),
          );
          break;
        case SnackType.info:
          showTopSnackBar(
            overlay,
            CustomSnackBar.info(
              message: notifier.message!,
            ),
          );
          break;
      }
    }
  }

  @override
  void dispose() {
    notifier.removeListener(_handleNotifier);
    notifier.dispose();
    super.dispose();
  }
}
