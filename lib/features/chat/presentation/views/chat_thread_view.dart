import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/chat_thread_cubit/chat_thread_cubit.dart';
import '../mappers/message_mapper.dart';
import '../widgets/chat_theme_builder.dart';

class ChatThreadView extends StatelessWidget {
  const ChatThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FetchUserData.getUserId() ?? '';

    final meLabel = LocaleKeys.chat_role_you.tr(context: context);
    final supportLabel = LocaleKeys.chat_role_support_agent.tr(
      context: context,
    );
    final workerLabel = LocaleKeys.chat_role_worker.tr(context: context);
    final systemLabel = LocaleKeys.chat_role_system.tr(context: context);

    Future<User?> resolveUser(UserID id) async {
      if (id == currentUserId) return User(id: id, name: meLabel);
      if (id == MessageMapper.supportAuthorId) {
        return User(id: id, name: supportLabel);
      }
      if (id == MessageMapper.workerAuthorId) {
        return User(id: id, name: workerLabel);
      }
      if (id == MessageMapper.systemAuthorId) {
        return User(id: id, name: systemLabel);
      }
      return User(id: id, name: supportLabel);
    }

    return BlocConsumer<ChatThreadCubit, ChatThreadState>(
      listenWhen: (_, s) => s is ChatThreadActionNotice,
      listener: (context, state) {
        if (state is ChatThreadActionNotice) {
          final text = _noticeText(context, state);
          if (state.isError) {
            context.showErrorSnackBar(text);
          } else {
            context.showSuccessSnackBar(text);
          }
        }
      },
      buildWhen: (_, s) => s is! ChatThreadActionNotice,
      builder: (context, state) {
        final cubit = context.read<ChatThreadCubit>();
        final title = state is ChatThreadLoaded
            ? state.thread.displaySubject(context)
            : LocaleKeys.chat_thread_title.tr(context: context);

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: GenericAppBar(title: title, centerTitle: false),
          body: _buildBody(context, state, cubit, currentUserId, resolveUser),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatThreadState state,
    ChatThreadCubit cubit,
    String currentUserId,
    ResolveUserCallback resolveUser,
  ) {
    if (state is ChatThreadLoading || state is ChatThreadInitial) {
      return const Center(child: CustomLoadingIndicator(size: 100));
    }
    if (state is ChatThreadError) {
      return ErrorRetryWidget(errorMessage: state.message, onRetry: cubit.open);
    }
    if (state is! ChatThreadLoaded) return const SizedBox.shrink();

    return Column(
      children: [
        if (state.thread.status.isReopenable) _ReopenBanner(),
        if (state.isUploading) const _UploadingBar(),
        Expanded(
          child: Chat(
            chatController: cubit.chatController,
            currentUserId: currentUserId,
            resolveUser: resolveUser,
            theme: buildChatTheme(context),
            onMessageSend: (text) => cubit.sendText(text),
            onAttachmentTap: () => _pickAttachment(context, cubit),
            onMessageLongPress:
                (ctx, message, {required index, required details}) {
                  _confirmReport(context, cubit, message, currentUserId);
                },
            builders: Builders(
              composerBuilder: (context) => Composer(
                hintText: LocaleKeys.chat_type_a_message.tr(),

                sendIcon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(
                    context.locale.languageCode == 'ar' ? -1.0 : 1.0,
                    1.0,
                    1.0,
                  ),
                  child: SvgPicture.asset(
                    AppAssets.chatSend,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      context.colors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                attachmentIcon: SvgPicture.asset(
                  AppAssets.chatAttach,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    context.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              emptyChatListBuilder: (context) =>
                  EmptyChatList(text: LocaleKeys.chat_no_messages_yet.tr()),

              chatAnimatedListBuilder: (context, itemBuilder) =>
                  ChatAnimatedListReversed(
                    itemBuilder: itemBuilder,
                    onEndReached: () => cubit.loadOlder(),
                  ),

              textMessageBuilder:
                  (
                    context,
                    message,
                    index, {
                    required isSentByMe,
                    groupStatus,
                  }) {
                    final bubble = SimpleTextMessage(
                      message: message,
                      index: index,
                    );
                    if (message.resolvedStatus != MessageStatus.error) {
                      return bubble;
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        bubble,
                        _ResendAffordance(
                          onTap: () => cubit.resendMessage(message),
                        ),
                      ],
                    );
                  },

              imageMessageBuilder:
                  (
                    context,
                    message,
                    index, {
                    required isSentByMe,
                    groupStatus,
                  }) => _AttachmentBubble(
                    isSentByMe: isSentByMe,
                    caption: message.text,
                    onResend: message.resolvedStatus == MessageStatus.error
                        ? () => cubit.resendMessage(message)
                        : null,
                    child: _RemoteImage(
                      url: message.source,
                      cacheKey: message.id,
                    ),
                  ),
              fileMessageBuilder:
                  (
                    context,
                    message,
                    index, {
                    required isSentByMe,
                    groupStatus,
                  }) => _AttachmentBubble(
                    isSentByMe: isSentByMe,
                    onResend: message.resolvedStatus == MessageStatus.error
                        ? () => cubit.resendMessage(message)
                        : null,
                    child: _FileRow(
                      name: message.name,
                      sizeBytes: message.size,
                    ),
                  ),
              systemMessageBuilder:
                  (
                    context,
                    message,
                    index, {
                    required isSentByMe,
                    groupStatus,
                  }) => _SystemBubble(text: message.text),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAttachment(
    BuildContext context,
    ChatThreadCubit cubit,
  ) async {
    final File? file = await ImagePickerHelper.showImageSourceDialog(
      context,
      withCropping: false,
    );
    if (file != null) {
      cubit.sendAttachment(file);
    }
  }

  void _confirmReport(
    BuildContext context,
    ChatThreadCubit cubit,
    Message message,
    String currentUserId,
  ) {
    // Only real (persisted) messages authored by someone else can be reported.
    if (message.id.startsWith('temp_')) return;
    if (message.authorId == currentUserId) return;

    context.showWarningAlert(
      title: LocaleKeys.chat_report_title.tr(context: context),
      message: LocaleKeys.chat_report_confirm.tr(context: context),
      primaryButtonText: LocaleKeys.chat_report_action.tr(context: context),
      mainButtonColor: context.colors.error,
      mainButtonTextColor: context.colors.themeColor,
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        cubit.reportMessage(message.id);
      },
      secondaryButtonText: LocaleKeys.cancel.tr(context: context),
      onSecondaryPressed: () => Navigator.of(context).pop(),
    );
  }

  String _noticeText(BuildContext context, ChatThreadActionNotice notice) {
    switch (notice.code) {
      case ChatNoticeCode.reportSucceeded:
        return LocaleKeys.chat_report_success.tr(context: context);
      case ChatNoticeCode.reportFailed:
        return notice.detail ??
            LocaleKeys.chat_report_failed.tr(context: context);
      case ChatNoticeCode.sendFailed:
        return notice.detail ??
            LocaleKeys.chat_send_failed.tr(context: context);
      case ChatNoticeCode.uploadFailed:
        return notice.detail ??
            LocaleKeys.chat_attachment_failed.tr(context: context);
    }
  }
}

class _ReopenBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.colors.brandSubtle,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LocaleKeys.chat_resolved_banner.tr(context: context),
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadingBar extends StatelessWidget {
  const _UploadingBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.colors.defaultSubtle,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            LocaleKeys.chat_uploading_attachment.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendAffordance extends StatelessWidget {
  final VoidCallback onTap;
  const _ResendAffordance({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 2, bottom: 6, end: 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 14, color: context.colors.error),
            const SizedBox(width: 4),
            Text(
              LocaleKeys.chat_resend.tr(context: context),
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentBubble extends StatelessWidget {
  final bool isSentByMe;
  final Widget child;
  final String? caption;
  final VoidCallback? onResend;

  const _AttachmentBubble({
    required this.isSentByMe,
    required this.child,
    this.caption,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final hasCaption = caption != null && caption!.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSentByMe
                ? context.colors.chatPrimary
                : context.colors.chatSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              if (hasCaption)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Text(
                    caption!,
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (onResend != null) _ResendAffordance(onTap: onResend!),
      ],
    );
  }
}

class _RemoteImage extends StatelessWidget {
  final String url;
  final String cacheKey;
  const _RemoteImage({required this.url, required this.cacheKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => _ImageViewer(url: url, cacheKey: cacheKey),
        ),
      ),
      child: Hero(
        tag: cacheKey,
        child: CachedNetworkImage(
          imageUrl: url,
          cacheKey: cacheKey,
          fit: BoxFit.cover,
          placeholder: (context, _) => const SizedBox(
            height: 180,
            width: double.infinity,
            child: Center(child: CustomLoadingIndicator()),
          ),
          errorWidget: (context, _, _) => SizedBox(
            height: 180,
            width: double.infinity,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String url;
  final String cacheKey;
  const _ImageViewer({required this.url, required this.cacheKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Hero(
          tag: cacheKey,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: CachedNetworkImage(
              imageUrl: url,
              cacheKey: cacheKey,
              fit: BoxFit.contain,
              placeholder: (context, _) =>
                  const Center(child: CustomLoadingIndicator()),
              errorWidget: (context, _, _) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A non-image attachment — shown as a labelled row rather than a preview.
class _FileRow extends StatelessWidget {
  final String name;
  final int? sizeBytes;
  const _FileRow({required this.name, this.sizeBytes});

  static String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 20,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                if (sizeBytes != null)
                  Text(
                    _humanSize(sizeBytes!),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  final String text;
  const _SystemBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.defaultSubtle,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
