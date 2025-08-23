sealed class CommandState<T extends dynamic, AppException> {}

final class CommandInitial<T extends dynamic, AppException>
    extends CommandState<T, AppException> {
  final T value;

  CommandInitial(this.value);
}

final class CommandLoading<T extends dynamic, AppException>
    extends CommandState<T, AppException> {
  CommandLoading();
}

final class CommandSuccess<T extends dynamic, AppException>
    extends CommandState<T, AppException> {
  final T value;

  CommandSuccess(this.value);
}

final class CommandFailure<T extends dynamic, AppException>
    extends CommandState<T, AppException> {
  final AppException exception;

  CommandFailure(this.exception);
}
