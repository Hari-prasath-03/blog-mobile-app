import 'package:blog_app/core/error/failures.dart';
import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/features/blog/domain/entities/blog.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogs implements UseCase<List<Blog>, NoParams> {
  final BlogRepository _blogRepository;
  GetAllBlogs({required this._blogRepository});

  @override
  Future<Either<Failure, List<Blog>>> call(NoParams params) {
    return _blogRepository.getAllBlogs();
  }
}
