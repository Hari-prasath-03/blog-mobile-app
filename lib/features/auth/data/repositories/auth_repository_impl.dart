import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/core/error/failures.dart';
import 'package:blog_app/core/network/connection_checker.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ConnectionChecker _connectionChecker;
  final AuthRemoteDataSource _authRemoteDataSource;

  const AuthRepositoryImpl({
    required this._connectionChecker,
    required this._authRemoteDataSource,
  });

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!(await _connectionChecker.isConnected)) {
        left(Failure(Constants.noConnectionMessage));
      }
      final user = await _authRemoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (!(await _connectionChecker.isConnected)) {
        left(Failure(Constants.noConnectionMessage));
      }
      final user = await _authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!(await _connectionChecker.isConnected)) {
        final user = _authRemoteDataSource.session?.user;

        if (user == null) return left(Failure('You havn\'t logged in yet.'));
        return right(
          User(
            id: user.id,
            name: user.email ?? '',
            email: user.userMetadata?['name'] ?? '',
          ),
        );
      }
      final user = await _authRemoteDataSource.getCurrentUserData();
      if (user == null) return left(Failure('No current user found.'));
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
