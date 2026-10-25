import 'package:file_selector/file_selector.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Opens the photo library for one picture after asking first.
///
/// iPhone, Android and the web use the system photo picker, so only the
/// chosen picture reaches Lookin. Desktop builds keep the file dialog.
/// Returns null when the person cancels at any point.
Future<Uint8List?> pickLibraryPhoto(
  BuildContext context, {
  required String label,
  double maxSide = 1600,
  int quality = 86,
  // Replaces the system picker in tests.
  Future<Uint8List?> Function()? pick,
}) async {
  final allowed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: const Key('photo-access-dialog'),
      icon: const Icon(Icons.photo_library_outlined),
      title: Text(dialogContext.l10n.commonPhotoAccessTitle),
      content: Text(dialogContext.l10n.commonPhotoAccessBody),
      actions: [
        TextButton(
          key: const Key('photo-access-cancel'),
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(dialogContext.l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('photo-access-open'),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(dialogContext.l10n.commonPhotoAccessOpen),
        ),
      ],
    ),
  );
  if (allowed != true) return null;
  if (pick != null) return pick();
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
      requestFullMetadata: false,
    );
    return photo?.readAsBytes();
  }
  final file = await openFile(
    acceptedTypeGroups: [
      XTypeGroup(
        label: label,
        extensions: ['jpg', 'jpeg', 'png', 'webp'],
        mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
        uniformTypeIdentifiers: [
          'public.jpeg',
          'public.png',
          'org.webmproject.webp',
        ],
      ),
    ],
  );
  return file?.readAsBytes();
}
