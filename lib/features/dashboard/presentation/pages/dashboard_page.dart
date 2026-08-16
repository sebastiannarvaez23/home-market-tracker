import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/date_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_hero_button.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_playful_backdrop.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:home_market_tracker/features/dashboard/presentation/widgets/dashboard_efficiency_card.dart';
import 'package:home_market_tracker/features/dashboard/presentation/widgets/dashboard_insights.dart';
import 'package:home_market_tracker/features/dashboard/presentation/widgets/dashboard_kpi_grid.dart';
import 'package:home_market_tracker/features/dashboard/presentation/widgets/dashboard_shortcut_row.dart';
import 'package:home_market_tracker/features/dashboard/presentation/widgets/dashboard_trend_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.onOpenProducts,
    required this.onOpenHistory,
    required this.onStartShopping,
  });

  final VoidCallback onOpenProducts;
  final VoidCallback onOpenHistory;
  final VoidCallback onStartShopping;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        return AppScaffold(
          appBar: const AppAppBar(
            title: AppStrings.homeTitle,
            showBack: false,
          ),
          body: AppPlayfulBackdrop(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: AppHeroButton(
                    label: AppStrings.startShopping,
                    icon: AppIcons.fire,
                    subtitle: AppStrings.startShoppingHint,
                    onPressed: onStartShopping,
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    DashboardStatus.initial || DashboardStatus.loading =>
                      const AppLoading(),
                    DashboardStatus.error => AppError(
                        message: state.failure?.message ??
                            AppStrings.errorLoadDashboard,
                        onRetry: cubit.retried,
                      ),
                    DashboardStatus.data => _DashboardBody(
                        snapshot: state.snapshot!,
                        onOpenProducts: onOpenProducts,
                        onOpenHistory: onOpenHistory,
                      ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.snapshot,
    required this.onOpenProducts,
    required this.onOpenHistory,
  });

  final DashboardSnapshot snapshot;
  final VoidCallback onOpenProducts;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            DateFormatter.monthYear(snapshot.window.periodStart),
            variant: AppTextVariant.subtitle,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          DashboardShortcutRow(
            onOpenProducts: onOpenProducts,
            onOpenHistory: onOpenHistory,
          ),
          const SizedBox(height: AppSpacing.lg),
          DashboardEfficiencyCard(snapshot: snapshot),
          const SizedBox(height: AppSpacing.md),
          DashboardKpiGrid(snapshot: snapshot),
          const SizedBox(height: AppSpacing.lg),
          DashboardInsights(snapshot: snapshot),
          const SizedBox(height: AppSpacing.lg),
          DashboardTrendCard(snapshot: snapshot),
        ],
      ),
    );
  }
}
