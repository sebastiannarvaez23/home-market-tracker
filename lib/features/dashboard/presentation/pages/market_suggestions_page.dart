import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_empty.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_list.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_playful_backdrop.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_state.dart';
import 'package:home_market_tracker/features/dashboard/presentation/widgets/market_suggestion_group_card.dart';

class MarketSuggestionsPage extends StatelessWidget {
  const MarketSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketSuggestionsCubit, MarketSuggestionsState>(
      builder: (context, state) {
        final cubit = context.read<MarketSuggestionsCubit>();
        return AppScaffold(
          appBar: const AppAppBar(title: AppStrings.marketSuggestionsTitle),
          body: AppPlayfulBackdrop(
            child: switch (state.status) {
              MarketSuggestionsStatus.initial ||
              MarketSuggestionsStatus.loading =>
                const AppLoading(),
              MarketSuggestionsStatus.error => AppError(
                  message: state.failure?.message ??
                      AppStrings.errorLoadMarketSuggestions,
                  onRetry: cubit.retried,
                ),
              MarketSuggestionsStatus.empty => const AppEmpty(
                  message: AppStrings.emptyMarketSuggestions,
                ),
              MarketSuggestionsStatus.data => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.sm,
                        AppSpacing.xl,
                        0,
                      ),
                      child: AppText(
                        AppStrings.marketSuggestionsHint,
                        variant: AppTextVariant.subtitle,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: AppList<MarketSuggestionGroup>(
                        items: state.groups,
                        separatorHeight: AppSpacing.md,
                        itemBuilder: (context, group, index) =>
                            MarketSuggestionGroupCard(group: group),
                      ),
                    ),
                  ],
                ),
            },
          ),
        );
      },
    );
  }
}
