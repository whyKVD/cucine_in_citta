import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_theme.dart';
import '../bloc/city_bloc.dart';
import '../bloc/city_event.dart';
import '../bloc/city_state.dart';
import '../widgets/cuisine_card.dart';
import '../widgets/error_widget.dart' as err_widget;
import '../widgets/italy_map_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/suggestion_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CityBloc, CityState>(
        builder: (context, state) {
          return SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: state.showingCuisines
                  ? _CuisinesView(key: const ValueKey('cuisines'), state: state)
                  : _SearchView(key: const ValueKey('search'), state: state),
            ),
          );
        },
      ),
    );
  }
}

class _SearchView extends StatelessWidget {
  final CityState state;

  const _SearchView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CityBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Text(
              'Cucine in città',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBarWidget(
            initialValue: state.term,
            onChanged: (t) => bloc.add(SearchTermChanged(t)),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildBody(context, state, bloc)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, CityState state, CityBloc bloc) {
    switch (state.searchPhase) {
      case SearchPhase.idle:
        return _IdleState();

      case SearchPhase.searching:
        return _buildLoadingShimmer();

      case SearchPhase.suggestions:
        return _buildSuggestions(state, bloc);

      case SearchPhase.noResults:
        return _NoResults(term: state.term);

      case SearchPhase.error:
        return err_widget.ErrorRetryWidget(
          message: state.errorMessage ?? 'Errore durante la ricerca.',
          onRetry: () => bloc.add(const RetryRequested()),
        );
    }
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(CityState state, CityBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: state.suggestions.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider,
              indent: 20,
            ),
            itemBuilder: (_, i) {
              final s = state.suggestions[i];
              return SuggestionTile(
                suggestion: s,
                isLast: i == state.suggestions.length - 1,
                onTap: () => bloc.add(CitySelected(s)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CuisinesView extends StatelessWidget {
  final CityState state;

  const _CuisinesView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CityBloc>();
    final city = state.selectedCity!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => bloc.add(const BackToSearch()),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded,
                    color: AppColors.accent, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city.mainText,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                      decorationThickness: 2.0)),
              const SizedBox(height: 2),
              if (city.secondaryText.isNotEmpty)
                Text(
                  city.secondaryText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildCuisineBody(context, state, bloc)),
      ],
    );
  }

  Widget _buildCuisineBody(
      BuildContext context, CityState state, CityBloc bloc) {
    switch (state.cuisinePhase) {
      case CuisinePhase.loading:
        return const Center(
          child: CircularProgressIndicator(
              color: AppColors.accent, strokeWidth: 2.5),
        );

      case CuisinePhase.shown:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${state.cuisines.length} cucine disponibili',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: state.cuisines.length,
                itemBuilder: (_, i) => CuisineCard(cuisine: state.cuisines[i]),
              ),
            ),
          ],
        );

      case CuisinePhase.empty:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Nessuna cucina trovata per questa città.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ),
        );

      case CuisinePhase.error:
        return err_widget.ErrorRetryWidget(
          message: state.errorMessage ?? 'Errore nel caricamento delle cucine.',
          onRetry: () => bloc.add(const RetryRequested()),
        );

      case null:
        return const SizedBox.shrink();
    }
  }
}

class _IdleState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ItalyMapWidget(size: 200),
          SizedBox(height: 32),
          Text(
            'Inizia a cercare una città per\nscoprire le cucine disponibili',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String term;

  const _NoResults({required this.term});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              'Nessuna città trovata\nper "$term"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
