import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

sealed class Either<L extends AppException, R> {
  R getOrThrow();

  bool get isSuccess => this is Success<L, R>;
  bool get isFailure => this is Failure<L, R>;

  Success<L, R>? get asSuccess =>
      this is Success<L, R> ? this as Success<L, R> : null;
  Failure<L, R>? get asFailure =>
      this is Failure<L, R> ? this as Failure<L, R> : null;

  W when<W>({
    required W Function(R value) onSuccess,
    required W Function(L exception) onFailure,
  });

  Either<L, T> map<T>(T Function(R value) fn);

  Either<L, R> onFailure(void Function(L failure) onFailure);

  Either<L, R> onSuccess(void Function(R success) onSuccess);
}

final class Success<L extends AppException, R> extends Either<L, R> {
  final R _value;

  Success(this._value);

  @override
  W when<W>({
    required W Function(R value) onSuccess,
    required W Function(L exception) onFailure,
  }) {
    return onSuccess(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R value) fn) {
    return Success<L, T>(fn(_value));
  }

  @override
  Either<L, R> onFailure(void Function(L failure) onFailure) {
    return this;
  }

  @override
  Either<L, R> onSuccess(void Function(R success) onSuccess) {
    onSuccess(_value);
    return this;
  }

  @override
  R getOrThrow() {
    return _value;
  }
}

final class Failure<L extends AppException, R> extends Either<L, R> {
  final L _exception;

  Failure(this._exception);

  @override
  W when<W>({
    required W Function(R value) onSuccess,
    required W Function(L exception) onFailure,
  }) {
    return onFailure(_exception);
  }

  @override
  Either<L, T> map<T>(T Function(R value) fn) {
    return Failure<L, T>(_exception);
  }

  @override
  Either<L, R> onFailure(void Function(L failure) onFailure) {
    onFailure(_exception);
    return this;
  }

  @override
  Either<L, R> onSuccess(void Function(R success) onSuccess) {
    return this;
  }

  @override
  R getOrThrow() {
    throw _exception;
  }
}
