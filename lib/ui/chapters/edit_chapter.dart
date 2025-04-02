import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../models/chapter.dart';
import '../../models/novel.dart';
import 'package:provider/provider.dart';
import 'chapter_manager.dart';
import '../novels/novel_manager.dart';

class CreateChapterDialog extends StatefulWidget {
  const CreateChapterDialog({Key? key}) : super(key: key);

  @override
  State<CreateChapterDialog> createState() => _CreateChapterDialogState();
}

class _CreateChapterDialogState extends State<CreateChapterDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _filePath;
  String? _selectedNovelId;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null && result.files.single.path != null) {
      _filePath = result.files.single.path;
      try {
        final file = File(_filePath!);
        final content = await file.readAsString();
        setState(() => _contentController.text = content);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load file: $e')));
      }
    }
  }

  Future<void> _createChapter() async {
    if (_selectedNovelId == null ||
        _titleController.text.isEmpty ||
        _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all fields or pick a file')));
      return;
    }

    final selectedNovel =
        context.read<NovelManager>().findById(_selectedNovelId!);
    if (selectedNovel == null) return;

    final chapter = Chapter(
      id: '',
      title: _titleController.text,
      content: _contentController.text,
      novelId: selectedNovel.id,
      chapterNumber: (selectedNovel.chapter) + 1,
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    await context.read<ChapterManager>().addChapter(chapter);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter created successfully!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final novelManager = context.watch<NovelManager>();
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create new chapter',
                  style: TextStyle(
                      fontFamily: 'Lato', fontSize: 20, color: Colors.black)),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Novel'),
                items: novelManager.items.map((Novel novel) {
                  return DropdownMenuItem<String>(
                    value: novel.id,
                    child: Text(novel.title,
                        style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? newValue) =>
                    setState(() => _selectedNovelId = newValue),
                dropdownColor: Colors.white,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                style: const TextStyle(color: Colors.black),
                controller: _titleController,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Content'),
                  style: const TextStyle(color: Colors.black),
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label:
                    Text(_filePath != null ? 'File Loaded' : 'Pick .txt file'),
                onPressed: _pickFile,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('Create'),
                    onPressed: _createChapter,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
