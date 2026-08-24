import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';
import 'package:home_market_tracker/features/dashboard/domain/services/market_suggestion_assembler.dart';
import 'package:home_market_tracker/features/dashboard/domain/usecases/get_market_price_suggestions.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_state.dart';

import '../../helpers/fakes.dart';

BestPriceOffer offer({
  required String productId,
  required String productName,
  required String marketId,
  required String marketName,
  required int cents,
  int purchasedAt = 1,
}) {
  return BestPriceOffer(
    productId: productId,
    productName: productName,
    marketId: marketId,
    marketName: marketName,
    unitPrice: Money.cents(cents),
    uom: UnitOfMeasure.unit,
    purchasedAt: purchasedAt,
  );
}

void main() {
  test('agrupa por mercado y deja un producto en el más reciente si empatan', () {
    final groups = MarketSuggestionAssembler.group([
      offer(
        productId: 'leche',
        productName: 'Leche',
        marketId: 'exito',
        marketName: 'Éxito',
        cents: 400000,
        purchasedAt: 10,
      ),
      offer(
        productId: 'leche',
        productName: 'Leche',
        marketId: 'jumbo',
        marketName: 'Jumbo',
        cents: 400000,
        purchasedAt: 20,
      ),
      offer(
        productId: 'arroz',
        productName: 'Arroz',
        marketId: 'exito',
        marketName: 'Éxito',
        cents: 250000,
      ),
      offer(
        productId: 'pan',
        productName: 'Pan',
        marketId: 'jumbo',
        marketName: 'Jumbo',
        cents: 150000,
      ),
    ]);

    expect(groups.map((group) => group.marketName), ['Jumbo', 'Éxito']);
    expect(
      groups.first.items.map((item) => item.productName),
      ['Leche', 'Pan'],
    );
    expect(groups.last.items.map((item) => item.productName), ['Arroz']);
  });

  test('el use case agrupa las ofertas del repositorio', () async {
    final repository = InMemoryMarketSuggestionRepository()
      ..offers = [
        offer(
          productId: 'p1',
          productName: 'Huevos',
          marketId: 'm1',
          marketName: 'Jumbo',
          cents: 1800000,
        ),
      ];

    final result = await GetMarketPriceSuggestions(repository)(const NoParams());
    final groups = (result as Success<List<MarketSuggestionGroup>>).value;
    expect(groups, hasLength(1));
    expect(groups.single.marketName, 'Jumbo');
    expect(groups.single.items.single.productName, 'Huevos');
  });

  group('MarketSuggestionsCubit', () {
    late InMemoryMarketSuggestionRepository repository;
    late MarketSuggestionsCubit cubit;

    setUp(() {
      repository = InMemoryMarketSuggestionRepository();
      cubit = MarketSuggestionsCubit(GetMarketPriceSuggestions(repository));
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<MarketSuggestionsCubit, MarketSuggestionsState>(
      'emite empty cuando no hay historial',
      build: () => cubit,
      act: (cubit) => cubit.started(),
      expect: () => [
        isA<MarketSuggestionsState>().having(
          (s) => s.status,
          'status',
          MarketSuggestionsStatus.loading,
        ),
        isA<MarketSuggestionsState>().having(
          (s) => s.status,
          'status',
          MarketSuggestionsStatus.empty,
        ),
      ],
    );

    blocTest<MarketSuggestionsCubit, MarketSuggestionsState>(
      'carga grupos por mercado',
      build: () {
        repository.offers = [
          offer(
            productId: 'p1',
            productName: 'Café',
            marketId: 'm1',
            marketName: 'D1',
            cents: 800000,
          ),
        ];
        return cubit;
      },
      act: (cubit) => cubit.started(),
      verify: (cubit) {
        expect(cubit.state.status, MarketSuggestionsStatus.data);
        expect(cubit.state.groups.single.marketName, 'D1');
      },
    );

    blocTest<MarketSuggestionsCubit, MarketSuggestionsState>(
      'emite error cuando falla el repositorio',
      build: () {
        repository.failure = const Failure.storage('disk');
        return cubit;
      },
      act: (cubit) => cubit.started(),
      expect: () => [
        isA<MarketSuggestionsState>().having(
          (s) => s.status,
          'status',
          MarketSuggestionsStatus.loading,
        ),
        isA<MarketSuggestionsState>().having(
          (s) => s.status,
          'status',
          MarketSuggestionsStatus.error,
        ),
      ],
    );
  });
}
