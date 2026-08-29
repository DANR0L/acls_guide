import 'dart:io';

void main() {
  var file = File(r'c:\Users\danro\Desktop\acls_guide_backup\acls_guide\lib\ui\screens\algorithm_screen.dart');
  var content = file.readAsStringSync();

  var widgetCode = '''
// ── Rich Text with DSD Link ───────────────────────────────────────────────
class _RichTextWithDsdLink extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _RichTextWithDsdLink({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final RegExp dsdRegex = RegExp(r'(desfibrilação dupla sequencial \\(dsd\\)|choque sequencial duplo \\(dsd\\)|dupla cardioversão sequencial \\(double sequential\\)|double sequential|dsd)', caseSensitive: false);
    final matches = dsdRegex.allMatches(text).toList();
    
    if (matches.isEmpty) {
      return Text(text, style: style);
    }
    
    final spans = <TextSpan>[];
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.info,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              showDialog(
                context: context,
                builder: (_) => const _DSDExplanationDialog(),
              );
            },
        ),
      );
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: spans,
      ),
    );
  }
}
''';

  content = content.replaceAll('// ── Bullet List', widgetCode + '\n// ── Bullet List');

  var oldBulletList = '''
        children: bullets.map((bullet) {
          final RegExp dsdRegex = RegExp(r'(desfibrilação dupla sequencial \\(dsd\\)|choque sequencial duplo \\(dsd\\)|dupla cardioversão sequencial \\(double sequential\\)|double sequential|dsd)', caseSensitive: false);
          final matches = dsdRegex.allMatches(bullet).toList();

          Widget bulletWidget;
          
          if (matches.isNotEmpty) {
            final spans = <TextSpan>[];
            int lastIndex = 0;
            for (final match in matches) {
              if (match.start > lastIndex) {
                spans.add(TextSpan(text: bullet.substring(lastIndex, match.start)));
              }
              spans.add(
                TextSpan(
                  text: bullet.substring(match.start, match.end),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showDialog(
                        context: context,
                        builder: (_) => const _DSDExplanationDialog(),
                      );
                    },
                ),
              );
              lastIndex = match.end;
            }
            if (lastIndex < bullet.length) {
              spans.add(TextSpan(text: bullet.substring(lastIndex)));
            }

            bulletWidget = RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                children: spans,
              ),
            );
          } else {
            bulletWidget = Text(
              bullet,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: bulletWidget),
              ],
            ),
          );
        }).toList(),''';

  var newBulletList = '''
        children: bullets.map((bullet) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _RichTextWithDsdLink(
                    text: bullet,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),''';

  content = content.replaceAll(oldBulletList.trim(), newBulletList.trim());

  content = content.replaceAll('''
                    Text(
                      option.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),''', '''
                    _RichTextWithDsdLink(
                      text: option.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),''');

  content = content.replaceAll('''
            Text(
              node.title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),''', '''
            _RichTextWithDsdLink(
              text: node.title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),''');

  content = content.replaceAll('''
                      Text(
                        option.sublabel!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),''', '''
                      _RichTextWithDsdLink(
                        text: option.sublabel!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),''');

  content = content.replaceAll('''
              Text(
                node.subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),''', '''
              _RichTextWithDsdLink(
                text: node.subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),''');

  file.writeAsStringSync(content);
  print('Done');
}
