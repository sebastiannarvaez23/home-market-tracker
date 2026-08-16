import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/date_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_gradient_icon.dart';
import 'package:home_market_tracker/core/widgets/app_list.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_price_text.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_line.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_state.dart';
import 'package:home_market_tracker/features/history/presentation/widgets/history_line_item.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryDetailCubit, HistoryDetailState>(
      builder: (context, state) {
        final cubit = context.read<HistoryDetailCubit>();
        return AppScaffold(
          appBar: AppAppBar(
            title: state.detail?.marketNameSnapshot ??
                AppStrings.historyDetailTitle,
          ),
          body: switch (state.status) {
            HistoryDetailStatus.initial || HistoryDetailStatus.loading =>
              const AppLoading(),
            HistoryDetailStatus.error => AppError(
                message:
                    state.failure?.message ?? AppStrings.errorLoadHistoryDetail,
                onRetry: cubit.retried,
              ),
            HistoryDetailStatus.data => _HistoryDetailBody(detail: state.detail!),
          },
        );
      },
    );
  }
}

class _HistoryDetailBody extends StatelessWidget {
  const _HistoryDetailBody({required this.detail});

  final HistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppCard(
            child: Row(
              children: [
                const AppGradientIcon(
                  gradient: AppColors.tealGlyph,
                  icon: AppIcons.store,
                  size: 64,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        detail.marketNameSnapshot,
                        variant: AppTextVariant.display,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        DateFormatter.dayMonthYear(detail.completedAt),
                        variant: AppTextVariant.subtitle,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      AppPriceText(
                        detail.total,
                        variant: AppTextVariant.title,
                        color: AppColors.tealDeep,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: AppText(
            AppStrings.historyItemsTitle,
            variant: AppTextVariant.title,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: AppList<HistoryLine>(
            items: detail.lines,
            itemBuilder: (context, line, index) => HistoryLineItem(line: line),
          ),
        ),
      ],
    );
  }
}
