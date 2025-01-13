import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/theme.dart';
import '../../constants/strings.dart';
import '../../cubit/permission_cubit.dart';
import '../dialogs.dart';

class AccessDialog extends StatelessWidget {
  const AccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PermissionStrings.accessTitle,
              style: headerTextStyle,
            ),
            const SizedBox(height: 16),
            Text(
              PermissionStrings.accessDescription,
              style: regularTextStyle,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => _handleAllowPress(context),
                  child: const Text(
                    PermissionStrings.allowButtonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _handleCancelPress(context),
                  child: const Text(
                    PermissionStrings.cancelButtonText,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAllowPress(BuildContext context) async {
    await context.read<PermissionCubit>().checkCameraPermission();

    if (context.mounted) {
      await context.read<PermissionCubit>().useAccessDialog();
    }

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleCancelPress(BuildContext context) async {
    Navigator.of(context).pop();
    await context.read<PermissionCubit>().useAccessDialog();
    if (context.mounted) {
      await context.read<PermissionCubit>().checkCameraPermission();
    }
    if (context.mounted) {
      showPermissionBottomSheet(context);
    }
  }
}
