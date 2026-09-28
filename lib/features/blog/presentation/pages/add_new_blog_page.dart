import 'dart:io';

import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/extension/app_extension.dart';
import 'package:blog_app/core/theme/app_pallet.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/core/utils/show_snackbar.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final Set<String> selectedTopics = {};
  File? selectedImage;

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  void toggleTopicSelection(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
    } else {
      selectedTopics.add(topic);
    }
    setState(() {});
  }

  bool isTopicSelected(String topic) {
    return selectedTopics.contains(topic);
  }

  void submitBlog() {
    if (formKey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        selectedImage != null) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

      context.read<BlogBloc>().add(
        BlogUploadEvent(
          title: titleController.text,
          content: contentController.text,
          posterId: posterId,
          image: selectedImage!,
          topics: selectedTopics.toList(),
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: submitBlog,
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogUploadSuccess) {
            showSnackBar(context, 'Blog uploaded successfully');
            context.nav.pushAndRemoveUntil(const BlogPage());
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) return const Loader();
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    selectedImage == null
                        ? GestureDetector(
                            onTap: selectImage,
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                color: AppPallet.borderColor,
                                dashPattern: const [10, 4],
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                                radius: const Radius.circular(8),
                                borderPadding: const EdgeInsets.all(6),
                              ),
                              child: SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open_rounded, size: 40),
                                    SizedBox(height: 6),
                                    Text(
                                      'Upload Image',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: selectImage,
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 14),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: Constants.topics
                            .map(
                              (topic) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => toggleTopicSelection(topic),
                                  child: Chip(
                                    label: Text(topic),
                                    color: isTopicSelected(topic)
                                        ? const MaterialStatePropertyAll(
                                            AppPallet.gradient1,
                                          )
                                        : null,
                                    side: isTopicSelected(topic)
                                        ? null
                                        : const BorderSide(
                                            color: AppPallet.borderColor,
                                          ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    BlogEditor(
                      hintText: 'Blog Title',
                      controller: titleController,
                    ),
                    const SizedBox(height: 10),
                    BlogEditor(
                      hintText: 'Blog Content',
                      controller: contentController,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
