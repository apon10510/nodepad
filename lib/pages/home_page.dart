import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late QuillController controller;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('editorData');
    if (savedData != null) {
      var myJSON = jsonDecode(savedData);
      controller = QuillController(
        document: Document.fromJson(myJSON),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      controller = QuillController.basic();
    }
    setState(() {
      controller.addListener(_saveData);
    });
  }

  void _saveData() {
    String json = jsonEncode(controller.document.toDelta().toJson());
    prefs.setString('editorData', json);
  }

  @override
  void dispose() {
    controller.removeListener(_saveData);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: controller,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('de'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                color: Colors.white,
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    padding: const EdgeInsets.all(8),
                    controller: controller,
                    // readOnly: false,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('de'),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
