import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/thread_model.dart';
import '../controllers/chat_threads_cubit/chat_threads_cubit.dart';
import '../widgets/chat_thread_card.dart';
import '../widgets/new_ticket_sheet.dart';

class ChatInboxView extends StatefulWidget {
  const ChatInboxView({super.key});

  @override
  State<ChatInboxView> createState() => _ChatInboxViewState();
}

class _ChatInboxViewState extends State<ChatInboxView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatThreadsCubit>().loadMore();
    }
  }

  void _openNewTicket() {
    NewTicketSheet.show(
      context,
      onSubmit: (category, subject) {
        context.read<ChatThreadsCubit>().createTicket(
          category: category,
          subject: subject,
        );
      },
    );
  }

  void _openThread(
    BuildContext context,
    String threadId,
    ThreadModel? initialThread,
  ) {
    // Capture the cubit before navigating so the post-return refresh does not
    // touch a possibly-stale BuildContext across the async gap.
    final cubit = context.read<ChatThreadsCubit>();
    context
        .pushNamed(
          Routes.chatThread,
          arguments: ChatThreadArgs(
            threadId: threadId,
            initialThread: initialThread,
          ),
        )
        .then((_) {
          if (mounted) cubit.refresh();
        });
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.chat_inbox_title.tr(context: context),
        centerTitle: false,
      ),
      floatingActionButton: BlocBuilder<ChatThreadsCubit, ChatThreadsState>(
        buildWhen: (_, s) => s is ChatThreadsLoaded,
        builder: (context, state) {
          if (state is! ChatThreadsLoaded || state.threads.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: _openNewTicket,
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.contentBlack,
            icon: const Icon(Icons.add),
            label: Text(
              LocaleKeys.chat_new_ticket.tr(context: context),
              style: AppTextStyles.medium14.copyWith(
                color: context.colors.contentBlack,
              ),
            ),
          );
        },
      ),
      body: BlocConsumer<ChatThreadsCubit, ChatThreadsState>(
        listenWhen: (_, s) =>
            s is ChatThreadCreating ||
            s is ChatThreadCreated ||
            s is ChatThreadCreateError,
        listener: (context, state) {
          if (state is ChatThreadCreating) {
            context.showLoadingOverlay();
          } else {
            context.hideLoadingOverlay();
          }
          if (state is ChatThreadCreated) {
            _openThread(context, state.thread.id, state.thread);
          } else if (state is ChatThreadCreateError) {
            context.showErrorSnackBar(state.message);
          }
        },
        buildWhen: (_, s) =>
            s is ChatThreadsInitial ||
            s is ChatThreadsLoading ||
            s is ChatThreadsLoaded ||
            s is ChatThreadsError,
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(height: sh(16)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(sw(24)),
                      topRight: Radius.circular(sw(24)),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: sw(24),
                    vertical: sh(24),
                  ),
                  child: _buildBody(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatThreadsState state) {
    double sh(double height) => context.sh(height);

    if (state is ChatThreadsLoading || state is ChatThreadsInitial) {
      return const Center(child: CustomLoadingIndicator(size: 100));
    }
    if (state is ChatThreadsError) {
      return ErrorRetryWidget(
        errorMessage: state.message,
        onRetry: () => context.read<ChatThreadsCubit>().loadThreads(),
      );
    }
    if (state is ChatThreadsLoaded) {
      if (state.threads.isEmpty) {
        return _buildEmptyState(context);
      }
      return RefreshIndicator(
        onRefresh: () => context.read<ChatThreadsCubit>().refresh(),
        child: ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: state.threads.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: sh(12)),
          itemBuilder: (context, index) {
            if (index >= state.threads.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CustomLoadingIndicator(size: 48)),
              );
            }
            final thread = state.threads[index];
            return ChatThreadCard(
              thread: thread,
              onTap: () => _openThread(context, thread.id, thread),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.messages,
                  width: 96,
                  height: 96,
                  colorFilter: ColorFilter.mode(
                    context.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.chat_inbox_empty_title.tr(context: context),
                  style: AppTextStyles.medium16.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.chat_inbox_empty_subtitle.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: LocaleKeys.chat_new_ticket.tr(context: context),
                  onPressed: _openNewTicket,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
