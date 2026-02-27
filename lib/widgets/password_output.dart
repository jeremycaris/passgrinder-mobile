import 'package:flutter/material.dart';

/// Displays the generated password with inline copy, reset, and visibility icons.
/// Mirrors the desktop app's PasswordField widget layout.
class PasswordOutput extends StatelessWidget {
  final String password;
  final bool showPassword;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onCopy;
  final VoidCallback? onReset;

  const PasswordOutput({
    super.key,
    required this.password,
    required this.showPassword,
    this.onToggleVisibility,
    this.onCopy,
    this.onReset,
  });

  String _maskPassword(String password) {
    return '\u2022' * password.length; // bullet character
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputTheme = theme.inputDecorationTheme;

    final borderColor =
        (inputTheme.enabledBorder as OutlineInputBorder?)?.borderSide.color ??
        Colors.grey.shade300;
    final panelColor = inputTheme.fillColor ?? colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final iconColor = colorScheme.onSurface;
    final disabledIconColor = colorScheme.onSurface.withValues(alpha: 0.35);

    final hasPassword = password.isNotEmpty;
    final bool copyEnabled = hasPassword && onCopy != null;
    final bool resetEnabled = onReset != null;
    final bool visibilityEnabled = hasPassword;

    final ButtonStyle iconBtnStyle = IconButton.styleFrom(
      hoverColor: Colors.transparent,
      focusColor: colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: colorScheme.primary.withValues(alpha: 0.15),
      splashFactory: InkRipple.splashFactory,
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44), // slightly larger for mobile touch
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                hasPassword
                    ? (showPassword ? password : _maskPassword(password))
                    : '',
                style: TextStyle(
                  fontFamily: 'SourceCodePro',
                  fontSize: 15,
                  letterSpacing: 1.0,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Copy icon
          SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(
                Icons.copy,
                size: 18,
                color: copyEnabled ? iconColor : disabledIconColor,
              ),
              onPressed: copyEnabled ? onCopy : null,
              tooltip: 'Copy password',
              style: iconBtnStyle,
              constraints: const BoxConstraints(minWidth: 44),
            ),
          ),
          // Reset icon
          SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(
                Icons.restart_alt,
                size: 20,
                color: resetEnabled ? iconColor : disabledIconColor,
              ),
              onPressed: resetEnabled ? onReset : null,
              tooltip: 'Reset fields',
              style: iconBtnStyle,
              constraints: const BoxConstraints(minWidth: 44),
            ),
          ),
          // Visibility toggle icon
          SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: visibilityEnabled ? iconColor : disabledIconColor,
              ),
              onPressed: visibilityEnabled ? onToggleVisibility : null,
              tooltip: showPassword ? 'Hide password' : 'Show password',
              style: iconBtnStyle,
              constraints: const BoxConstraints(minWidth: 44),
            ),
          ),
        ],
      ),
    );
  }
}
