import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/core/extension/app_extension.dart';
import 'package:blog_app/core/theme/app_pallet.dart';
import 'package:blog_app/core/utils/show_snackbar.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final colors = [
    [AppPallet.gradient1, null],
    [AppPallet.gradient3, Colors.black87],
    [AppPallet.gradient2, null],
  ];

  @override
  void initState() {
    super.initState();
    context.read<BlogBloc>().add(BlogFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            onPressed: () {
              context.nav.push(const AddNewBlogPage());
            },
            icon: const Icon(CupertinoIcons.add_circled),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          } else if (state is BlogDisplaySuccess) {
            final blogs = state.blogs;
            return Padding(
              padding: const EdgeInsets.all(14),
              child: ListView.builder(
                itemCount: blogs.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () {
                    context.nav.push(BlogViewerPage(blog: blogs[index]));
                  },
                  child: BlogCard(blog: blogs[index], color: colors[index % 3]),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
