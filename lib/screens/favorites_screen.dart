import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/cards/professional_card.dart';
import '../services/auth_service.dart';
import '../services/repositories/favorite_repository.dart';
import 'professional_profile_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, String>? _currentUser;
  bool _isLoading = true;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFavorites();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.initialize();
      final favorites = await FavoriteRepository.getFavorites();
      
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: CustomDrawer(
        userName: _currentUser?['name'],
        userEmail: _currentUser?['email'],
        userType: _currentUser?['userType'],
      ),
      body: Column(
        children: [
          MainHeader(
            title: AppStrings.favorites,
            subtitle: '${_favorites.length} profissionais favoritos',
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : _favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 64, color: AppColors.textTertiary),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum favorito ainda',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicione profissionais aos favoritos para encontrá-los facilmente',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final favorite = _favorites[index];
                          return ProfessionalCard(
                            name: favorite['name'] as String? ?? 'Nome não disponível',
                            rating: (favorite['rating'] as num?)?.toDouble() ?? 0.0,
                            totalReviews: favorite['totalReviews'] as int? ?? 0,
                            specialty: () {
                              if (favorite['specialty'] != null) {
                                return favorite['specialty'] as String;
                              }
                              final categories = favorite['categories'] as List?;
                              if (categories != null && categories.isNotEmpty) {
                                return categories.first as String;
                              }
                              return 'Profissional';
                            }(),
                            professionalId: favorite['id'] as String? ?? favorite['professionalId'] as String? ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfessionalProfileScreen(
                                    professionalId: favorite['id'] as String? ?? favorite['professionalId'] as String? ?? '',
                                    professionalName: favorite['name'] as String? ?? 'Profissional',
                                    rating: (favorite['rating'] as num?)?.toDouble(),
                                    totalReviews: favorite['totalReviews'] as int?,
                                    specialty: favorite['specialty'] as String?,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}


