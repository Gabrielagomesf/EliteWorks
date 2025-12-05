import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/repositories/professional_repository.dart';
import '../widgets/cards/professional_card.dart';
import '../widgets/navigation/custom_bottom_nav.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/categories/category_chip.dart';
import '../widgets/sections/section_header.dart';
import '../models/professional_model.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import 'professional_profile_screen.dart';
import 'conversations_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  Map<String, String>? _currentUser;
  String _selectedCategory = '';
  
  // Busca
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  String? _selectedSearchCategory;
  double? _minRating;
  double? _maxPrice;
  int _currentPage = 0;
  final int _pageSize = 20;
  int _totalResults = 0;
  bool _hasMoreResults = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce - busca após 500ms sem digitar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text != _searchController.text) return;
      if (_searchController.text.isNotEmpty) {
        _performSearch();
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch({bool loadMore = false}) async {
    if (_isLoadingSearch) return;

    setState(() {
      _isLoadingSearch = true;
      if (!loadMore) {
        _currentPage = 0;
        _searchResults = [];
        _isSearching = true;
      }
    });

    try {
      await AuthService.initialize();

      final results = await ProfessionalRepository.searchWithUserInfo(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        category: _selectedSearchCategory,
        minRating: _minRating,
        maxPrice: _maxPrice,
        limit: _pageSize,
        skip: _currentPage * _pageSize,
      );

      _totalResults = await ProfessionalRepository.count(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        category: _selectedSearchCategory,
        minRating: _minRating,
        maxPrice: _maxPrice,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _searchResults.addAll(results);
          } else {
            _searchResults = results;
          }
          _currentPage++;
          _hasMoreResults = results.length == _pageSize;
          _isLoadingSearch = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSearch = false;
        });
      }
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setModalState(() {
                      _selectedSearchCategory = null;
                      _minRating = null;
                      _maxPrice = null;
                    });
                    Navigator.pop(context);
                    _performSearch();
                  },
                  child: const Text('Limpar'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Categoria',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.serviceCategories.map((category) {
                final isSelected = _selectedSearchCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setModalState(() {
                      _selectedSearchCategory = selected ? category : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Avaliação Mínima',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [1, 2, 3, 4, 5].map((rating) {
                final isSelected = _minRating == rating.toDouble();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text('$rating+'),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _minRating = selected ? rating.toDouble() : null;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Preço Máximo',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 500.00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setModalState(() {
                  _maxPrice = value.isEmpty ? null : double.tryParse(value);
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Localização',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ex: São Paulo, SP',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setModalState(() {
                  // Será usado na busca
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performSearch();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Aplicar Filtros'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isProfessional = _currentUser?['userType'] == 'profissional';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: CustomDrawer(
        userName: _currentUser?['name'],
        userEmail: _currentUser?['email'],
        userType: _currentUser?['userType'],
      ),
      body: _buildBody(isProfessional),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildBody(bool isProfessional) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(isProfessional);
      case 1:
        return _buildSearchTab(isProfessional);
      case 2:
        return _buildMessagesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab(isProfessional);
    }
  }

  Widget _buildHomeTab(bool isProfessional) {
    return Column(
      children: [
        MainHeader(
          title: AppStrings.home,
          subtitle: isProfessional
              ? AppStrings.manageServices
              : AppStrings.findProfessionals,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildCategoriesSection(),
                const SizedBox(height: 32),
                _buildFeaturedProfessionalsSection(),
                const SizedBox(height: 32),
                _buildNearbyProfessionalsSection(),
                const SizedBox(height: 32),
                _buildRecommendedSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.yellow,
      Colors.cyan,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categorias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AppConstants.serviceCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.serviceCategories[index];
              final icon = AppConstants.categoryIcons[category] ?? Icons.category;
              final color = colors[index % colors.length];
              
              return CategoryChip(
                title: category,
                icon: icon,
                color: color,
                isSelected: _selectedCategory == category,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProfessionalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Profissionais em Destaque',
          subtitle: 'Os mais bem avaliados',
          onSeeAll: () {},
        ),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ProfessionalCard(
                name: 'João Silva',
                rating: 4.9,
                totalReviews: 245,
                specialty: 'Especialista em Construção',
                professionalId: 'prof1',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof1',
                        professionalName: 'João Silva',
                        rating: 4.9,
                        totalReviews: 245,
                        specialty: 'Especialista em Construção',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Maria Santos',
                rating: 4.8,
                totalReviews: 189,
                specialty: 'Design de Interiores',
                professionalId: 'prof2',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof2',
                        professionalName: 'Maria Santos',
                        rating: 4.8,
                        totalReviews: 189,
                        specialty: 'Design de Interiores',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Pedro Costa',
                rating: 4.7,
                totalReviews: 156,
                specialty: 'Elétrica Residencial',
                professionalId: 'prof3',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof3',
                        professionalName: 'Pedro Costa',
                        rating: 4.7,
                        totalReviews: 156,
                        specialty: 'Elétrica Residencial',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Ana Oliveira',
                rating: 4.9,
                totalReviews: 203,
                specialty: 'Limpeza Profissional',
                professionalId: 'prof4',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof4',
                        professionalName: 'Ana Oliveira',
                        rating: 4.9,
                        totalReviews: 203,
                        specialty: 'Limpeza Profissional',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyProfessionalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Profissionais Próximos',
          subtitle: 'Na sua região',
          onSeeAll: () {},
        ),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ProfessionalCard(
                name: 'Carlos Mendes',
                rating: 4.6,
                totalReviews: 98,
                specialty: 'Encanamento',
                professionalId: 'prof5',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof5',
                        professionalName: 'Carlos Mendes',
                        rating: 4.6,
                        totalReviews: 98,
                        specialty: 'Encanamento',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Fernanda Lima',
                rating: 4.8,
                totalReviews: 134,
                specialty: 'Pintura',
                professionalId: 'prof6',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof6',
                        professionalName: 'Fernanda Lima',
                        rating: 4.8,
                        totalReviews: 134,
                        specialty: 'Pintura',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Roberto Alves',
                rating: 4.7,
                totalReviews: 112,
                specialty: 'Marcenaria',
                professionalId: 'prof7',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof7',
                        professionalName: 'Roberto Alves',
                        rating: 4.7,
                        totalReviews: 112,
                        specialty: 'Marcenaria',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recomendados para Você',
          subtitle: 'Baseado no seu perfil',
          onSeeAll: () {},
        ),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ProfessionalCard(
                name: 'Lucas Ferreira',
                rating: 4.9,
                totalReviews: 278,
                specialty: 'Tecnologia e TI',
                professionalId: 'prof8',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof8',
                        professionalName: 'Lucas Ferreira',
                        rating: 4.9,
                        totalReviews: 278,
                        specialty: 'Tecnologia e TI',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Juliana Rocha',
                rating: 4.8,
                totalReviews: 167,
                specialty: 'Organização de Eventos',
                professionalId: 'prof9',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof9',
                        professionalName: 'Juliana Rocha',
                        rating: 4.8,
                        totalReviews: 167,
                        specialty: 'Organização de Eventos',
                      ),
                    ),
                  );
                },
              ),
              ProfessionalCard(
                name: 'Ricardo Souza',
                rating: 4.7,
                totalReviews: 145,
                specialty: 'Jardinagem',
                professionalId: 'prof10',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionalProfileScreen(
                        professionalId: 'prof10',
                        professionalName: 'Ricardo Souza',
                        rating: 4.7,
                        totalReviews: 145,
                        specialty: 'Jardinagem',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab(bool isProfessional) {
    return Column(
      children: [
        MainHeader(
          title: AppStrings.search,
          subtitle: 'Encontre profissionais e serviços',
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _isSearching = false;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: AppColors.textSecondary),
                        onPressed: _showFilters,
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (_) => _performSearch(),
              ),
              if (_selectedSearchCategory != null || _minRating != null || _maxPrice != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedSearchCategory != null)
                      Chip(
                        label: Text(_selectedSearchCategory!),
                        onDeleted: () {
                          setState(() {
                            _selectedSearchCategory = null;
                          });
                          _performSearch();
                        },
                      ),
                    if (_minRating != null)
                      Chip(
                        label: Text('⭐ ${_minRating!.toStringAsFixed(0)}+'),
                        onDeleted: () {
                          setState(() {
                            _minRating = null;
                          });
                          _performSearch();
                        },
                      ),
                    if (_maxPrice != null)
                      Chip(
                        label: Text('R\$ ${_maxPrice!.toStringAsFixed(2)}'),
                        onDeleted: () {
                          setState(() {
                            _maxPrice = null;
                          });
                          _performSearch();
                        },
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Digite para buscar profissionais',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingSearch && _searchResults.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum profissional encontrado',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente outros termos de busca ou filtros',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_totalResults} resultado${_totalResults != 1 ? 's' : ''} encontrado${_totalResults != 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchResults.length + (_hasMoreResults ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _searchResults.length) {
                // Botão "Carregar mais"
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: _isLoadingSearch
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: () => _performSearch(loadMore: true),
                            child: const Text('Carregar mais'),
                          ),
                  ),
                );
              }

              final result = _searchResults[index];
              final professional = result['professional'] as ProfessionalModel;
              final user = result['user'] as UserModel;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProfessionalCard(
                  name: user.name,
                  rating: professional.rating,
                  totalReviews: professional.totalReviews,
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
                          professionalName: user.name,
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
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    return const ConversationsScreen();
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Toque no ícone de perfil para ver seu perfil',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
