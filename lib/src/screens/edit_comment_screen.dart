import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// A screen for editing a [comment].
class EditCommentScreen extends StatefulWidget {
  /// Create an instance.
  const EditCommentScreen({
    required this.onChange,
    this.comment,
    this.title = 'Edit Comment',
    this.inputLabel = 'Comment',
    super.key,
  });

  /// The function to call when [comment] has been edited.
  ///
  /// If the `value` is `null`, then the comment should be removed.
  final ValueChanged<String?> onChange;

  /// The comment to edit.
  final String? comment;

  /// The title of the [Scaffold].
  final String title;

  /// The `labelText` for the [InputDecoration].
  final String inputLabel;

  /// Create state for this widget.
  @override
  EditCommentScreenState createState() => EditCommentScreenState();
}

/// State for [EditCommentScreen].
class EditCommentScreenState extends State<EditCommentScreen> {
  /// The text editing controller to use.
  late final TextEditingController _commentController;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    final comment = widget.comment ?? '';
    _commentController = TextEditingController()
      ..value = TextEditingValue(
        text: comment,
        composing: TextRange(start: 0, end: comment.length),
      );
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => PopScope(
    onPopInvokedWithResult: (_, _) {
      final comment = _commentController.text;
      widget.onChange(comment.isEmpty ? null : comment);
    },
    child: Cancel(
      child: SimpleScaffold(
        title: widget.title,
        body: TextField(
          autofocus: true,
          controller: _commentController,
          decoration: InputDecoration(labelText: widget.inputLabel),
          expands: true,
          maxLines: null,
        ),
      ),
    ),
  );
}
