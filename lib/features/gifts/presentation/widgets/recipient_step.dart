import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/components/custom_text_form_field.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/send_gift_cubit.dart';
import '../controllers/send_gift_state.dart';

class RecipientStep extends StatefulWidget {
  const RecipientStep({super.key});

  @override
  State<RecipientStep> createState() => _RecipientStepState();
}

class _RecipientStepState extends State<RecipientStep> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SendGiftCubit>();
    _nameController = TextEditingController(text: cubit.state.recipientName);
    _phoneController = TextEditingController(text: cubit.state.recipientPhone);

    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<SendGiftCubit>().updateRecipient(
      _nameController.text,
      _phoneController.text,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendGiftCubit, SendGiftState>(
      buildWhen: (previous, current) =>
          false, // only built once, updates handled by controllers
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.gifts_recipient_info.tr(context: context)),
            SizedBox(height: context.sh(24)),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.gifts_card_recipient_name.tr(
                      context: context,
                    ),
                    style: AppTextStyles.medium16.copyWith(
                      fontSize: context.sw(16),
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.sh(8)),
            CustomTextFormField(
              controller: _nameController,
              label: '',
              keyboardType: TextInputType.name,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.sw(16)),
                child: Icon(Icons.person, color: context.colors.textPrimary),
              ),
            ),
            SizedBox(height: context.sh(24)),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.gifts_card_mobile_number.tr(
                      context: context,
                    ),
                    style: AppTextStyles.medium16.copyWith(
                      fontSize: context.sw(16),
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.sh(8)),
            CustomPhoneTextField(controller: _phoneController),
            SizedBox(height: context.sh(40)),
          ],
        );
      },
    );
  }
}
