import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/domain/usecases/get_shopping_detail.dart';
import 'package:home_market_tracker/features/history/domain/usecases/list_completed_shoppings.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_state.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryHistoryRepository repository;

  HistoryEntry entry() {
    return HistoryEntry(
      id: 's1',
      marketId: 'm1',
      marketNameSnapshot: 'Jumbo',
      completedAt: DateTime(2026, 8, 10).millisecondsSinceEpoch,
      total: const Money.cents(25000),
      itemCount: 3,
    );
  }

  group('HistoryListCubit', () {
    late HistoryListCubit cubit;

    setUp(() {
      repository = InMemoryHistoryRepository();
      cubit = HistoryListCubit(ListCompletedShoppings(repository));
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<HistoryListCubit, HistoryListState>(
      'emite empty cuando no hay compras completadas',
      build: () => cubit,
      act: (cubit) => cubit.started(),
      expect: () => [
        isA<HistoryListState>()
            .having((s) => s.status, 'status', HistoryListStatus.loading),
        isA<HistoryListState>()
            .having((s) => s.status, 'status', HistoryListStatus.empty),
      ],
    );

    blocTest<HistoryListCubit, HistoryListState>(
      'carga el historial de mercados',
      build: () {
        repository.entries = [entry()];
        return cubit;
      },
      act: (cubit) => cubit.started(),
      expect: () => [
        isA<HistoryListState>()
            .having((s) => s.status, 'status', HistoryListStatus.loading),
        isA<HistoryListState>()
            .having((s) => s.status, 'status', HistoryListStatus.data)
            .having((s) => s.entries, 'entries', hasLength(1)),
      ],
    );

    blocTest<HistoryListCubit, HistoryListState>(
      'emite error cuando falla el repositorio',
      build: () {
        repository.listFailure = const Failure.storage('falló');
        return cubit;
      },
      act: (cubit) => cubit.started(),
      expect: () => [
        isA<HistoryListState>()
            .having((s) => s.status, 'status', HistoryListStatus.loading),
        isA<HistoryListState>()
            .having((s) => s.status, 'status', HistoryListStatus.error),
      ],
    );
  });

  group('HistoryDetailCubit', () {
    late HistoryDetailCubit cubit;

    setUp(() {
      repository = InMemoryHistoryRepository();
      cubit = HistoryDetailCubit('s1', GetShoppingDetail(repository));
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<HistoryDetailCubit, HistoryDetailState>(
      'carga el detalle de una compra',
      build: () {
        repository.details['s1'] = HistoryDetail(
          id: 's1',
          marketId: 'm1',
          marketNameSnapshot: 'Jumbo',
          completedAt: DateTime(2026, 8, 10).millisecondsSinceEpoch,
          total: const Money.cents(25000),
          lines: const [],
        );
        return cubit;
      },
      act: (cubit) => cubit.started(),
      expect: () => [
        isA<HistoryDetailState>()
            .having((s) => s.status, 'status', HistoryDetailStatus.loading),
        isA<HistoryDetailState>()
            .having((s) => s.status, 'status', HistoryDetailStatus.data)
            .having((s) => s.detail?.marketNameSnapshot, 'market', 'Jumbo'),
      ],
    );
  });
}
