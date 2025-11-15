import 'package:flutter/material.dart';

class ExportImportDialog extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onExportToFile;

  const ExportImportDialog({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.onExportToFile,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export & Import'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose an option:'),
          SizedBox(height: 16),
          Icon(Icons.info_outline, size: 16),
          Text('Exported files contain all your todos in JSON format.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onExport();
          },
          icon: const Icon(Icons.share),
          label: const Text('Share JSON'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onExportToFile();
          },
          icon: const Icon(Icons.save_alt),
          label: const Text('Save to File'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onImport();
          },
          icon: const Icon(Icons.download),
          label: const Text('Import from File'),
        ),
      ],
    );
  }
}