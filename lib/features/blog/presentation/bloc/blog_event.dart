part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {
  const BlogEvent();
}

final class BlogUploadEvent extends BlogEvent {
  final String title;
  final String content;
  final String posterId;
  final File image;
  final List<String> topics;

  const BlogUploadEvent({
    required this.title,
    required this.content,
    required this.posterId,
    required this.image,
    required this.topics,
  });
}

final class BlogFetchEvent extends BlogEvent {}
