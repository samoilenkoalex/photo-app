import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isAllowButton;

  const DialogButton({
    required this.text,
    required this.onPressed,
    this.isAllowButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: buttonTextStyle.copyWith(fontWeight: isAllowButton ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
