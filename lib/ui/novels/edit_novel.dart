import 'dart:io';

import 'package:ct312h_project/models/tags.dart';
import 'package:ct312h_project/services/tags_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/novel.dart';
import '../shared/dialog_utils.dart';

import '../novels/novel_manager.dart';

class EditNovelScreen extends StatefulWidget {
  static const routeName = '/edit_novel';

  EditNovelScreen(
    Novel? novel, {
    super.key,
  }) {
    if (novel == null) {
      this.novel = Novel(
        id: '',
        title: '',
        description: '',
        chapter: 0,
        tags: [],
        view: 0,
        created: DateTime.now().toIso8601String(),
        updated: DateTime.now().toIso8601String(),
      );
    } else {
      this.novel = novel;
    }
  }

  late final Novel novel;

  @override
  State<EditNovelScreen> createState() => _EditNovelScreenState();
}

class _EditNovelScreenState extends State<EditNovelScreen> {
  final _editForm = GlobalKey<FormState>();
  late Novel _editedNovel;
  late List<Tags> _availableTags = [];

  @override
  void initState() {
    _editedNovel = widget.novel;
    _fetchTags();
    super.initState();
  }

  Future<void> _fetchTags() async {
    final tagsService = TagsService();
    final fetchedTags = await tagsService.fetchTags();
    setState(() {
      _availableTags = fetchedTags;
    });
  }

  Future<void> _saveForm() async {
    final isValid =
        _editForm.currentState!.validate() && _editedNovel.hasFeaturedImage();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    try {
      final novelsManager = context.read<NovelManager>();

      if (_editedNovel.id.isNotEmpty) {
        await novelsManager.updateNovel(_editedNovel, _editedNovel.tags);
      } else {
        await novelsManager.addNovel(_editedNovel, _editedNovel.tags);
      }
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, 'Something went wrong.');
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Novel'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _editForm,
          child: ListView(
            children: <Widget>[
              _buildTitleField(),
              _buildDescriptionField(),
              if (_editedNovel.id.isEmpty)
                _buildTagsField(), // Chỉ hiển thị khi tạo mới
              _buildNovelPreview(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTitleField() {
    return TextFormField(
      initialValue: _editedNovel.title,
      decoration: const InputDecoration(labelText: 'Title'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a title.';
        }
        return null;
      },
      onSaved: (value) {
        _editedNovel = _editedNovel.copyWith(title: value);
      },
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      initialValue: _editedNovel.description,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a description.';
        }
        if (value.length < 10) {
          return 'Should be at least 10 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _editedNovel = _editedNovel.copyWith(description: value);
      },
    );
  }

  Widget _buildTagsField() {
    return Wrap(
      spacing: 8.0,
      children: _availableTags.map((tag) {
        final isSelected = _editedNovel.tags.contains(tag.id);
        return ChoiceChip(
          label: Text(tag.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _editedNovel.tags.add(tag.id);
              } else {
                _editedNovel.tags.remove(tag.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildNovelPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: !_editedNovel.hasFeaturedImage()
              ? const Center(
                  child: Text('No Image'),
                )
              : FittedBox(
                  child: _editedNovel.featuredImage == null
                      ? Image.network(
                          _editedNovel.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _editedNovel.featuredImage!,
                          fit: BoxFit.cover,
                        ),
                ),
        ),
        Expanded(
          child: SizedBox(height: 100, child: _buildImagePickerButton()),
        ),
      ],
    );
  }

  TextButton _buildImagePickerButton() {
    return TextButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Pick Image'),
      onPressed: () async {
        final imagePicker = ImagePicker();
        try {
          final imageFile =
              await imagePicker.pickImage(source: ImageSource.gallery);
          if (imageFile == null) {
            return;
          }

          _editedNovel = _editedNovel.copyWith(
            featuredImage: File(imageFile.path),
          );

          setState(() {});
        } catch (error) {
          if (mounted) {
            showErrorDialog(context, 'Something went wrong.');
          }
        }
      },
    );
  }
}
