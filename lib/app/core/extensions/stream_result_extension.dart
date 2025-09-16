import 'dart:async';

import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

typedef StreamResult<L extends AppException, R> = Stream<Either<L, R>>;

extension StreamResultExtension<L extends AppException, R>
    on StreamResult<L, R> {
  StreamResult<L, T> map<T>(T Function(R value) mapper) {
    return asyncMap((either) async {
      return either.when(
        onSuccess: (value) => Success<L, T>(mapper(value)),
        onFailure: (error) => Failure<L, T>(error),
      );
    });
  }

  StreamResult<L, T> flatMap<T>(
    StreamResult<L, T> Function(R value) mapper,
  ) {
    return asyncExpand((either) {
      return either.when(
        onSuccess: (value) => mapper(value),
        onFailure: (error) => Stream.value(Failure<L, T>(error)),
      );
    });
  }

  StreamResult<L, R> onSuccess(void Function(R value) action) {
    return map((value) {
      action(value);
      return value;
    });
  }

  StreamResult<L, R> onFailure(void Function(L error) action) {
    return asyncMap((either) async {
      return either.when(
        onSuccess: (value) => Success<L, R>(value),
        onFailure: (error) {
          action(error);
          return Failure<L, R>(error);
        },
      );
    });
  }
}
