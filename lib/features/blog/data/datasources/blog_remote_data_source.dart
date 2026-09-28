import 'dart:io';

import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
  Future<List<BlogModel>> getAllBlogs();
  Future<void> deleteBlogImage({required String filePath});
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient _sbClient;
  const BlogRemoteDataSourceImpl({required this._sbClient});

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final blogData = await _sbClient
          .from('blogs')
          .insert(blog.toJson())
          .select()
          .single();
      return BlogModel.fromJson(blogData);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      await _sbClient.storage.from('blog_images').upload(blog.id, image);
      return _sbClient.storage.from('blog_images').getPublicUrl(blog.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs = await _sbClient.from('blogs').select('*, profiles (name)');
      return (blogs)
          .map(
            (blog) =>
                BlogModel.fromJson(blog)
                    .copyWith(posterName: blog['profiles']['name']),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteBlogImage({required String filePath}) async {
    await _sbClient.storage.from('blog_images').remove([filePath]);
  }
}
