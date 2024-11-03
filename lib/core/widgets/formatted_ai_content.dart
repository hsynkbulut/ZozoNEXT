import 'package:flutter/material.dart';

class FormattedAIContent extends StatelessWidget {
  final String content;
  final TextStyle? baseStyle;

  const FormattedAIContent({
    super.key,
    required this.content,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = baseStyle ?? theme.textTheme.bodyLarge!;
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Divider line (**)
      if (line.trim() == '**') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: theme.dividerColor,
            ),
          ),
        );
        continue;
      }

      // Main heading (#)
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(2),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      // Subheading (##)
      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      // Sub-subheading (###)
      if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet points (*) with sub-items
      if (line.startsWith('* ')) {
        final List<Widget> bulletGroup = [];

        // Add main bullet point
        bulletGroup.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•', style: defaultStyle),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFormattedText(
                    line.substring(2),
                    defaultStyle,
                  ),
                ),
              ],
            ),
          ),
        );

        // Look ahead for sub-items
        int nextIndex = i + 1;
        while (nextIndex < lines.length && lines[nextIndex].startsWith(' * ')) {
          bulletGroup.add(
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('▪️', style: defaultStyle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFormattedText(
                      lines[nextIndex].substring(3),
                      defaultStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
          i = nextIndex;
          nextIndex++;
        }

        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bulletGroup,
          ),
        );
        continue;
      }

      // Regular text with possible bold formatting
      if (line.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildFormattedText(line, defaultStyle),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int currentPosition = 0;

    // Find all bold text matches
    for (final match in boldPattern.allMatches(text)) {
      // Add text before the bold part
      if (match.start > currentPosition) {
        spans.add(TextSpan(
          text: text.substring(currentPosition, match.start),
          style: baseStyle,
        ));
      }

      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));

      currentPosition = match.end;
    }

    // Add any remaining text
    if (currentPosition < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPosition),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
