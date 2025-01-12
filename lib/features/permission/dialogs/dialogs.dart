import 'package:flutter/material.dart';
import 'package:photo_app/features/permission/dialogs/widgets/access_dialog.dart';

import 'widgets/permission_bottom_sheet.dart';

Future<bool?> showAccessDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const AccessDialog(),
  );
}

Future<void> showPermissionBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => const PopScope(
      canPop: false,
      child: PermissionBottomSheet(),
    ),
  );
}
