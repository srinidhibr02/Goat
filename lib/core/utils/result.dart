import '../errors/failures.dart';

/// Placeholder type for void-equivalent [Result] returns.
///
/// Use [Unit.instance] to create a successful void result:
/// ```dart
/// return Ok(Unit.instance);
/// ```
final class Unit {
  const Unit._();
  static const Unit instance = Unit._();
}

/// Lightweight result type used at repository boundaries.
///
/// Repositories return [Ok<T>] on success and [Err<T>] on failure,
/// so the presentation layer never catches raw exceptions.
///
/// ```dart
/// final result = await repo.signIn(email, password);
/// switch (result) {
///   case Ok(:final value)  => /* use value */;
///   case Err(:final failure) => /* show error */;
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Successful result wrapping [value].
final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

/// Failed result wrapping a [Failure] describing what went wrong.
final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
