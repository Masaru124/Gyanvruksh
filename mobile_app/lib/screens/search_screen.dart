import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../theme/futuristic_theme.dart';
import '../widgets/enhanced_futuristic_card.dart';
import '../widgets/loading_states.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load initial search results or suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FuturisticColors.background,
      appBar: AppBar(
        title: const Text('Search & Discover'),
        backgroundColor: FuturisticColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: FuturisticColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search courses, lessons, topics...',
                hintStyle: TextStyle(color: FuturisticColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: FuturisticColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: FuturisticColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchViewModel>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: FuturisticColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: FuturisticColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<SearchViewModel>().search(value);
                } else {
                  context.read<SearchViewModel>().clearSearch();
                }
              },
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Courses'),
                const SizedBox(width: 8),
                _buildFilterChip('Lessons'),
                const SizedBox(width: 8),
                _buildFilterChip('Quizzes'),
                const SizedBox(width: 8),
                _buildFilterChip('Topics'),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return LoadingStates.fullScreenLoading(context);
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: FuturisticColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Search Error',
                          style: FuturisticTextStyles.headline3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.error!,
                          style: FuturisticTextStyles.body2,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (_searchController.text.isEmpty) {
                  return _buildSuggestions(viewModel);
                }

                if (viewModel.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: FuturisticColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: FuturisticTextStyles.headline3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords or filters',
                          style: FuturisticTextStyles.body2,
                        ),
                      ],
                    ),
                  );
                }

                return _buildSearchResults(viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
        if (_searchController.text.isNotEmpty) {
          context.read<SearchViewModel>().search(_searchController.text);
        }
      },
      backgroundColor: FuturisticColors.surface,
      selectedColor: FuturisticColors.primary.withOpacity(0.2),
      checkmarkColor: FuturisticColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? FuturisticColors.primary : FuturisticColors.textPrimary,
      ),
    );
  }

  Widget _buildSuggestions(SearchViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Popular Searches',
          style: FuturisticTextStyles.headline3,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Flutter Development',
            'Machine Learning',
            'Web Development',
            'Data Science',
            'Mobile Apps',
            'Python Programming',
          ].map((suggestion) => ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  context.read<SearchViewModel>().search(suggestion);
                },
                backgroundColor: FuturisticColors.surface,
                labelStyle: const TextStyle(color: FuturisticColors.textPrimary),
              )).toList(),
        ),
        const SizedBox(height: 32),
        Text(
          'Recent Searches',
          style: FuturisticTextStyles.headline3,
        ),
        const SizedBox(height: 16),
        ...viewModel.recentSearches.map((search) => ListTile(
              title: Text(search['query'] ?? '', style: const TextStyle(color: FuturisticColors.textPrimary)),
              leading: const Icon(Icons.history, color: FuturisticColors.primary),
              onTap: () {
                _searchController.text = search['query'] ?? '';
                context.read<SearchViewModel>().search(search['query'] ?? '');
              },
            )),
      ],
    );
  }

  Widget _buildSearchResults(SearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final result = viewModel.searchResults[index];
        return EnhancedFuturisticCard(
          child: ListTile(
            title: Text(
              result['title'] ?? 'Untitled',
              style: const TextStyle(color: FuturisticColors.textPrimary),
            ),
            subtitle: Text(
              result['description'] ?? '',
              style: TextStyle(color: FuturisticColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(
              _getIconForType(result['type']),
              color: FuturisticColors.primary,
            ),
            trailing: Text(
              result['type'] ?? '',
              style: TextStyle(color: FuturisticColors.accent),
            ),
            onTap: () {
              // Navigate to the specific item
              _navigateToResult(result);
            },
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
      },
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'course':
        return Icons.school;
      case 'lesson':
        return Icons.book;
      case 'quiz':
        return Icons.quiz;
      case 'topic':
        return Icons.topic;
      default:
        return Icons.search;
    }
  }

  void _navigateToResult(Map<String, dynamic> result) {
    // Implement navigation based on result type
    switch (result['type']) {
      case 'course':
        // Navigate to course details
        break;
      case 'lesson':
        // Navigate to lesson
        break;
      case 'quiz':
        // Navigate to quiz
        break;
    }
  }
}
