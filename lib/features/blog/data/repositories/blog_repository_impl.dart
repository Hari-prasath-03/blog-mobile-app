import 'dart:io';

import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/core/error/failures.dart';
import 'package:blog_app/core/network/connection_checker.dart';
import 'package:blog_app/core/utils/run_with_rollback.dart';
import 'package:blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_app/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:blog_app/features/blog/domain/entities/blog.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final ConnectionChecker _connectionChecker;
  final BlogLocalDataSource _blogLocalDataSource;
  final BlogRemoteDataSource _blogRemoteDataSource;

  const BlogRepositoryImpl({
    required this._connectionChecker,
    required this._blogLocalDataSource,
    required this._blogRemoteDataSource,
  });

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await _connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionMessage));
      }

      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics,
        updatedAt: DateTime.now(),
      );

      final imageUrl = await _blogRemoteDataSource.uploadBlogImage(
        image: image,
        blog: blogModel,
      );

      final uploadedBlog = await runWithRollBack<Blog>(
        action: () => _blogRemoteDataSource.uploadBlog(
          blogModel.copyWith(imageUrl: imageUrl),
        ),
        rollback: () =>
            _blogRemoteDataSource.deleteBlogImage(filePath: blogModel.id),
      );

      return right(uploadedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await _connectionChecker.isConnected) {
        final blogs = _blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await _blogRemoteDataSource.getAllBlogs();
      _blogLocalDataSource.uploadLocalBlogs(blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
