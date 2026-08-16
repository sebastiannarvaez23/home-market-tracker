import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_photo_capture.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_text_field.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_state.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/product_uom_ladder_editor.dart';

class CreateProductSheet extends StatefulWidget {
  const CreateProductSheet({super.key});

  @override
  State<CreateProductSheet> createState() => _CreateProductSheetState();
}

class _CreateProductSheetState extends State<CreateProductSheet> {
  late final TextEditingController _name;
  final _ladderKey = GlobalKey<ProductUomLadderEditorState>();
  String? _photoPath;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _hasPhoto => _photoPath != null && _photoPath!.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_hasPhoto) {
      setState(() => _photoError = AppStrings.productPhotoRequired);
      return;
    }
    final cubit = context.read<ProductsListCubit>();
    final created = await cubit.createProduct(
      name: _name.text,
      photoSourcePath: _photoPath!,
      uomLadder: _ladderKey.currentState?.draft,
    );
    if (created && mounted) {
      AppBottomSheet.close(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsListCubit, ProductsListState>(
      builder: (context, state) {
        final photoError = _photoError ??
            (!_hasPhoto ? state.createFailure?.message : null);
        return AppSheetScaffold(
          glyph: AppPhotoCapture(
            imagePath: _photoPath,
            onCaptured: (path) {
              setState(() {
                _photoPath = path;
                _photoError = null;
              });
            },
          ),
          title: AppStrings.createProductTitle,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                _hasPhoto
                    ? AppStrings.productPhotoRetake
                    : AppStrings.productPhotoHint,
                variant: AppTextVariant.caption,
                color: AppColors.iconOnGradient,
                align: TextAlign.center,
              ),
              if (photoError != null && photoError.isNotEmpty) ...[
                const SizedBox(height: 4),
                AppText(
                  photoError,
                  variant: AppTextVariant.caption,
                  color: AppColors.danger,
                  align: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _name,
                hint: AppStrings.createProductHint,
                onDark: true,
                autofocus: true,
                errorText: _hasPhoto ? state.createFailure?.message : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              ProductUomLadderEditor(key: _ladderKey),
            ],
          ),
          actions: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AppStrings.cancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: state.isCreating
                      ? null
                      : () => AppBottomSheet.close(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: AppStrings.create,
                  onPressed: state.isCreating || !_hasPhoto ? null : _submit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
