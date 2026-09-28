import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

abstract interface class BlogLocalDataSource {
  void uploadLocalBlogs(List<BlogModel> blogs);
  List<BlogModel> loadBlogs();
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box box;
  const BlogLocalDataSourceImpl({required this.box});

  @override
  void uploadLocalBlogs(List<BlogModel> blogs) {
    box.clear();
    final blogMap = {for (var blog in blogs) blog.id.toString(): blog};
    box.putAll(blogMap);
  }

  @override
  List<BlogModel> loadBlogs() {
    return box.values.cast<BlogModel>().toList();
  }
}
