import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_empty.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_list.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_state.dart';
import 'package:home_market_tracker/features/history/presentation/widgets/history_list_item.dart';

class HistoryListPage extends StatelessWidget {
  const HistoryListPage({
    super.key,
    required this.onEntrySelected,
  });

  final ValueChanged<String> onEntrySelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryListCubit, HistoryListState>(
      builder: (context, state) {
        final cubit = context.read<HistoryListCubit>();
        return AppScaffold(
          appBar: const AppAppBar(
            title: AppStrings.historyTitle,
            showBack: false,
          ),
          body: switch (state.status) {
            HistoryListStatus.initial || HistoryListStatus.loading =>
              const AppLoading(),
            HistoryListStatus.error => AppError(
                message: state.failure?.message ?? AppStrings.errorLoadHistory,
                onRetry: cubit.retried,
              ),
            HistoryListStatus.empty =>
              const AppEmpty(message: AppStrings.emptyHistory),
            HistoryListStatus.data => AppList<HistoryEntry>(
                items: state.entries,
                itemBuilder: (context, entry, index) => HistoryListItem(
                  entry: entry,
                  onTap: () => onEntrySelected(entry.id),
                ),
              ),
          },
        );
      },
    );
  }
}
