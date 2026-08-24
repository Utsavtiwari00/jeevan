import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';

/// Formatted chat text widget that renders Markdown bold (**text**),
/// italic (*text*), code (`code`), headers (### Header), and bullet/numbered lists cleanly.
class FormattedChatText extends StatelessWidget {
  final String text;
  final bool isUser;
  final TextStyle? baseStyle;

  const FormattedChatText({
    super.key,
    required this.text,
    this.isUser = false,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = baseStyle ??
        TextStyle(
          color: isUser ? AppColors.surfaceWhite : AppColors.charcoalSoil,
          fontSize: 15,
          height: 1.45,
        );

    final lines = text.split('\n');
    final List<Widget> children = [];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        if (i > 0 && i < lines.length - 1 && lines[i - 1].trim().isNotEmpty) {
          children.add(const SizedBox(height: 6));
        }
        i++;
        continue;
      }

      // Check for headings (###, ##, #)
      if (trimmed.startsWith('### ')) {
        final headingText = trimmed.substring(4).trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 3.0),
            child: _buildRichText(
              headingText,
              defaultStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isUser ? AppColors.surfaceWhite : AppColors.charcoalSoil,
              ),
              isUser: isUser,
            ),
          ),
        );
        i++;
        continue;
      } else if (trimmed.startsWith('## ')) {
        final headingText = trimmed.substring(3).trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: _buildRichText(
              headingText,
              defaultStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUser ? AppColors.surfaceWhite : AppColors.charcoalSoil,
              ),
              isUser: isUser,
            ),
          ),
        );
        i++;
        continue;
      } else if (trimmed.startsWith('# ')) {
        final headingText = trimmed.substring(2).trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: _buildRichText(
              headingText,
              defaultStyle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isUser ? AppColors.surfaceWhite : AppColors.charcoalSoil,
              ),
              isUser: isUser,
            ),
          ),
        );
        i++;
        continue;
      }

      // Check for bullet list item (•, -, *)
      if (trimmed.startsWith('• ') || trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final content = trimmed.substring(2).trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, left: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: defaultStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUser ? AppColors.surfaceWhite : AppColors.accentGreen,
                  ),
                ),
                Expanded(
                  child: _buildRichText(content, defaultStyle, isUser: isUser),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Check for numbered list (1., 2., etc.)
      final numMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
      if (numMatch != null) {
        final numStr = numMatch.group(1) ?? '1';
        final content = numMatch.group(2) ?? '';
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, left: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$numStr. ',
                  style: defaultStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUser ? AppColors.surfaceWhite : AppColors.accentGreen,
                  ),
                ),
                Expanded(
                  child: _buildRichText(content, defaultStyle, isUser: isUser),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Normal paragraph line
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: _buildRichText(trimmed, defaultStyle, isUser: isUser),
        ),
      );
      i++;
    }

    if (children.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  static Widget _buildRichText(String text, TextStyle baseStyle, {required bool isUser}) {
    // Fast path: if no markdown formatting characters, render standard Text widget
    if (!text.contains('*') && !text.contains('_') && !text.contains('`')) {
      return Text(text, style: baseStyle);
    }

    final spans = _parseMarkdownSpans(text, baseStyle, isUser: isUser);
    return Text.rich(
      TextSpan(children: spans),
      style: baseStyle,
    );
  }

  /// Parses inline markdown elements (**bold**, *italic*, `code`) into TextSpans.
  static List<InlineSpan> _parseMarkdownSpans(String text, TextStyle baseStyle, {required bool isUser}) {
    final List<InlineSpan> spans = [];

    final pattern = RegExp(
      r'(\*\*\*[^*]+\*\*\*|\*\*[^*]+\*\*|__[^_]+__|\*[^*]+\*|_[^_]+_|`[^`]+`)',
    );

    int lastIndex = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      final fullMatch = match.group(0)!;
      if (fullMatch.startsWith('***') && fullMatch.endsWith('***') && fullMatch.length >= 6) {
        final content = fullMatch.substring(3, fullMatch.length - 3);
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if ((fullMatch.startsWith('**') && fullMatch.endsWith('**') && fullMatch.length >= 4) ||
          (fullMatch.startsWith('__') && fullMatch.endsWith('__') && fullMatch.length >= 4)) {
        final content = fullMatch.substring(2, fullMatch.length - 2);
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: isUser ? AppColors.surfaceWhite : (baseStyle.color ?? AppColors.charcoalSoil),
          ),
        ));
      } else if ((fullMatch.startsWith('*') && fullMatch.endsWith('*') && fullMatch.length >= 2) ||
          (fullMatch.startsWith('_') && fullMatch.endsWith('_') && fullMatch.length >= 2)) {
        final content = fullMatch.substring(1, fullMatch.length - 1);
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (fullMatch.startsWith('`') && fullMatch.endsWith('`') && fullMatch.length >= 2) {
        final content = fullMatch.substring(1, fullMatch.length - 1);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.black.withValues(alpha: 0.15)
                  : AppColors.paperBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isUser ? Colors.white24 : AppColors.divider,
                width: 0.5,
              ),
            ),
            child: Text(
              content,
              style: baseStyle.copyWith(
                fontFamily: 'monospace',
                fontSize: (baseStyle.fontSize ?? 14) * 0.9,
                color: isUser ? Colors.white : AppColors.charcoalSoil,
              ),
            ),
          ),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }
}
