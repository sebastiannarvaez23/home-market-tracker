import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_gradient_icon.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_text_field.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_cubit.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_state.dart';

class PickMarketSheet extends StatefulWidget {
  const PickMarketSheet({super.key});

  @override
  State<PickMarketSheet> createState() => _PickMarketSheetState();
}

class _PickMarketSheetState extends State<PickMarketSheet> {
  late final TextEditingController _name;

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

  Future<void> _create() async {
    final cubit = context.read<PickMarketCubit>();
    final created = await cubit.createMarket(name: _name.text);
    if (created != null && mounted) {
      AppBottomSheet.close<String>(context, created.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickMarketCubit, PickMarketState>(
      builder: (context, state) {
        final cubit = context.read<PickMarketCubit>();
        return AppSheetScaffold(
          glyph: AppGradientIcon.fire(),
          title: AppStrings.pickMarketTitle,
          body: switch (state.status) {
            PickMarketStatus.initial || PickMarketStatus.loading =>
              const AppLoading(),
            PickMarketStatus.error => AppError(
                message: state.failure?.message ?? AppStrings.errorLoadMarkets,
                onRetry: cubit.retried,
              ),
            PickMarketStatus.empty || PickMarketStatus.data => _body(state, cubit),
          },
          actions: _actions(state),
        );
      },
    );
  }

  Widget _body(PickMarketState state, PickMarketCubit cubit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.markets.isEmpty)
          const AppText(
            AppStrings.pickMarketEmpty,
            variant: AppTextVariant.body,
            color: AppColors.iconOnGradient,
            align: TextAlign.center,
          ),
        for (final market in state.markets) ...[
          _MarketTile(
            market: market,
            onTap: () => AppBottomSheet.close<String>(context, market.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.showCreateForm) ...[
          if (state.markets.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _name,
            hint: AppStrings.createMarketHint,
            onDark: true,
            autofocus: state.markets.isEmpty,
            errorText: state.createFailure?.message,
            onSubmitted: (_) => _create(),
          ),
        ],
      ],
    );
  }

  Widget _actions(PickMarketState state) {
    if (state.status == PickMarketStatus.loading ||
        state.status == PickMarketStatus.initial ||
        state.status == PickMarketStatus.error) {
      return const SizedBox.shrink();
    }
    if (state.showCreateForm) {
      return AppButton(
        label: AppStrings.createAndStart,
        icon: AppIcons.fire,
        onPressed: state.isCreating ? null : _create,
      );
    }
    return AppButton(
      label: AppStrings.newMarket,
      variant: AppButtonVariant.outline,
      icon: AppIcons.add,
      onPressed: () => context.read<PickMarketCubit>().createFormOpened(),
    );
  }
}

class _MarketTile extends StatelessWidget {
  const _MarketTile({required this.market, required this.onTap});

  final Market market;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              AppGradientIcon.market(seed: market.id.hashCode, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  market.name,
                  variant: AppTextVariant.title,
                  color: AppColors.iconOnGradient,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
