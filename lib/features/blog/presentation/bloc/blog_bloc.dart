import 'dart:io';

import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/features/blog/domain/entities/blog.dart';
import 'package:blog_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;

  BlogBloc({required this._uploadBlog, required this._getAllBlogs})
    : super(BlogInitial()) {
    on<BlogEvent>((_, emit) => emit(BlogLoading()));
    on<BlogUploadEvent>(_onBlogUpload);
    on<BlogFetchEvent>(_onBlogFetch);
  }

  void _onBlogUpload(BlogUploadEvent event, Emitter<BlogState> emit) async {
    try {
      final res = await _uploadBlog(
        UploadBlogParams(
          title: event.title,
          content: event.content,
          posterId: event.posterId,
          image: event.image,
          topics: event.topics,
        ),
      );

      res.fold(
        (failure) => emit(BlogFailure(failure.message)),
        (success) => emit(BlogUploadSuccess()),
      );
    } catch (e) {
      emit(BlogFailure(e.toString()));
    }
  }

  void _onBlogFetch(BlogFetchEvent event, Emitter<BlogState> emit) async {
    try {
      final res = await _getAllBlogs(NoParams());

      res.fold(
        (failure) => emit(BlogFailure(failure.message)),
        (success) => emit(BlogDisplaySuccess(blogs: success)),
      );
    } catch (e) {
      emit(BlogFailure(e.toString()));
    }
  }
}
