import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/utils/app_assets.dart';

class SupportChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const SupportChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
  });

  @override
  State<SupportChatInputField> createState() => _SupportChatInputFieldState();
}

class _SupportChatInputFieldState extends State<SupportChatInputField> {
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textListener);
    _showSendButton = widget.controller.text.trim().isNotEmpty;
  }

  void _textListener() {
    final isNotEmpty = widget.controller.text.trim().isNotEmpty;
    if (isNotEmpty != _showSendButton) {
      setState(() {
        _showSendButton = isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sw(12)),
      color: context.colors.screenBG,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: sw(48),
                decoration: BoxDecoration(
                  color: context.colors.fields,
                  borderRadius: BorderRadius.circular(sw(24)),
                  border: Border.all(
                    color: context.colors.borderSecondary.withValues(
                      alpha: 0.1,
                    ),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: sw(6)),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw(8)),
                        child: TextField(
                          controller: widget.controller,
                          style: AppTextStyles.regular14.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: LocaleKeys.write_here.tr(
                              context: context,
                            ),
                            hintStyle: AppTextStyles.regular14.copyWith(
                              color: context.colors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw(8)),

                    if (_showSendButton)
                      GestureDetector(
                        onTap: widget.onSend,
                        child: Container(
                          width: sw(50),
                          margin: EdgeInsets.symmetric(
                            horizontal: sw(6),
                            vertical: sw(6),
                          ),
                          padding: EdgeInsets.all(sw(4)),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: SvgPicture.asset(AppAssets.chat),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: widget.onAttach,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw(10)),
                          child: Transform.rotate(
                            angle: context.isEn
                                ? 0.785
                                : -0.785, // Rotate paperclip slightly
                            child: Icon(
                              Icons.attach_file_rounded,
                              color: context.colors.textTertiary,
                              size: sw(22),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
