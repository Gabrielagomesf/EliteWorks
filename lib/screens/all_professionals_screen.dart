import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/repositories/professional_repository.dart';
import '../widgets/cards/professional_card.dart';
import '../models/professional_model.dart';
import '../models/user_model.dart';
import 'professional_profile_screen.dart';

class AllProfessionalsScreen extends StatefulWidget {
  final String? initialCategory;
  final String? filterType; // 'featured', 'nearby', 'recommended'

  const AllProfessionalsScreen({
    super.key,
    this.initialCategory,
    this.filterType,
  });

  @override
  State<AllProfessionalsScreen> createState() => _AllProfessionalsScreenState();
}

class _AllProfessionalsScreenState extends State<AllProfessionalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _professionals = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  // Filtros
  String? _selectedCategory;
  double? _minRating;
  double? _maxPrice;
  String _sortBy = 'rating'; // 'rating', 'reviews', 'price'
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadProfessionals();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreProfessionals();
      }
    }
  }

  void _onSearchChanged() {
    // Debounce - recarrega após 500ms sem digitar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchController.text && mounted) {
        _currentPage = 0;
        _hasMore = true;
        _professionals.clear();
        _loadProfessionals();
      }
    });
  }

  Future<void> _loadProfessionals({bool loadMore = false}) async {
    if (_isLoading && !loadMore) return;
    if (_isLoadingMore && loadMore) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 0;
        _professionals.clear();
      }
    });

    try {
      await AuthService.initialize();

      List<Map<String, dynamic>> results = [];

      // Aplicar filtro baseado no tipo
      if (widget.filterType == 'featured') {
        results = await ProfessionalRepository.getFeaturedWithUserInfo(limit: 100);
        _hasMore = false; // Featured não tem paginação
      } else {
        results = await ProfessionalRepository.searchWithUserInfo(
          query: _searchController.text.isEmpty ? null : _searchController.text,
          category: _selectedCategory,
          minRating: _minRating,
          maxPrice: _maxPrice,
          limit: _pageSize,
          skip: _currentPage * _pageSize,
        );
      }

      // Ordenar resultados
      _sortResults(results);

      if (mounted) {
        setState(() {
          if (loadMore) {
            _professionals.addAll(results);
          } else {
            _professionals = results;
          }
          _hasMore = results.length == _pageSize;
          _currentPage++;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _sortResults(List<Map<String, dynamic>> results) {
    results.sort((a, b) {
      final professionalA = ProfessionalModel.fromJson(a['professional']);
      final professionalB = ProfessionalModel.fromJson(b['professional']);

      switch (_sortBy) {
        case 'rating':
          final ratingA = professionalA.rating ?? 0;
          final ratingB = professionalB.rating ?? 0;
          return ratingB.compareTo(ratingA);
        case 'reviews':
          final reviewsA = professionalA.totalReviews ?? 0;
          final reviewsB = professionalB.totalReviews ?? 0;
          return reviewsB.compareTo(reviewsA);
        case 'price':
          final priceA = professionalA.servicePrices?.values.first ?? double.infinity;
          final priceB = professionalB.servicePrices?.values.first ?? double.infinity;
          return priceA.compareTo(priceB);
        default:
          return 0;
      }
    });
  }

  Future<void> _loadMoreProfessionals() async {
    await _loadProfessionals(loadMore: true);
  }

  void _applyFilters() {
    setState(() {
      _showFilters = false;
      _currentPage = 0;
      _hasMore = true;
      _professionals.clear();
    });
    _loadProfessionals();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _minRating = null;
      _maxPrice = null;
      _currentPage = 0;
      _hasMore = true;
      _professionals.clear();
    });
    _loadProfessionals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.filterType == 'featured'
              ? 'Profissionais em Destaque'
              : widget.filterType == 'nearby'
                  ? 'Profissionais Próximos'
                  : widget.filterType == 'recommended'
                      ? 'Recomendados para Você'
                      : 'Todos os Profissionais',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFiltersPanel(),
          _buildSortBar(),
          Expanded(
            child: _buildProfessionalsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar profissionais...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _loadProfessionals();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.background,
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Limpar',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Categoria
          Text(
            'Categoria',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.serviceCategories.take(12).map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Avaliação Mínima
          Text(
            'Avaliação Mínima',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3.0, 4.0, 4.5, 5.0].map((rating) {
              final isSelected = _minRating == rating;
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' $rating+'),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _minRating = selected ? rating : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Preço Máximo
          Text(
            'Preço Máximo',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ex: 500.00',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _maxPrice = value.isEmpty ? null : double.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Aplicar Filtros',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Ordenar por:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Avaliação', 'rating', Icons.star),
                  const SizedBox(width: 8),
                  _buildSortChip('Avaliações', 'reviews', Icons.rate_review),
                  const SizedBox(width: 8),
                  _buildSortChip('Preço', 'price', Icons.attach_money),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = value;
            _sortResults(_professionals);
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 12,
      ),
    );
  }

  Widget _buildProfessionalsList() {
    if (_isLoading && _professionals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_professionals.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum profissional encontrado',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou buscar por outros termos',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _professionals.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _professionals.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = _professionals[index];
        final professional = ProfessionalModel.fromJson(item['professional']);
        final userData = item['user'] as Map<String, dynamic>?;

        if (userData == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProfessionalCard(
            name: userData['name'] ?? 'Profissional',
            rating: professional.rating ?? 0,
            totalReviews: professional.totalReviews ?? 0,
            specialty: professional.categories.isNotEmpty
                ? professional.categories.first
                : 'Profissional',
            professionalId: professional.id,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfessionalProfileScreen(
                    professionalId: professional.id,
                    professionalName: userData['name'] ?? 'Profissional',
                    rating: professional.rating ?? 0,
                    totalReviews: professional.totalReviews ?? 0,
                    specialty: professional.categories.isNotEmpty
                        ? professional.categories.first
                        : 'Profissional',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

