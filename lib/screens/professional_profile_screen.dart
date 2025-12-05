import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/review_model.dart';
import '../models/work_model.dart';
import '../models/ad_model.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../services/auth_service.dart';
import '../services/repositories/professional_repository.dart';
import '../services/repositories/service_repository.dart';
import '../services/repositories/review_repository.dart';
import '../services/repositories/ad_repository.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final String professionalId;
  final String professionalName;
  final double? rating;
  final int? totalReviews;
  final String? specialty;

  const ProfessionalProfileScreen({
    super.key,
    required this.professionalId,
    required this.professionalName,
    this.rating,
    this.totalReviews,
    this.specialty,
  });

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, String>? _currentUser;
  List<ReviewModel> _reviews = [];
  List<WorkModel> _works = [];
  List<AdModel> _ads = [];
  bool _isLoading = true;
  String? _bio;
  List<String> _categories = [];
  String? _coverageArea;
  bool _isVerified = false;
  String? _professionalName;
  double? _professionalRating;
  int? _professionalTotalReviews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
    _loadProfessionalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadProfessionalData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.initialize();
      
      // Buscar dados do profissional com informações do usuário
      final data = await ProfessionalRepository.findByIdWithUser(widget.professionalId);
      
      if (data != null) {
        final professionalData = data['professional'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>?;
        
        setState(() {
          _bio = professionalData['bio'];
          _categories = professionalData['categories'] != null
              ? List<String>.from(professionalData['categories'])
              : [];
          _coverageArea = professionalData['coverageArea'];
          _isVerified = professionalData['isVerified'] ?? false;
          
          // Atualizar informações do usuário se disponíveis
          if (userData != null) {
            _professionalName = userData['name'];
          }
          
          _professionalRating = professionalData['rating'] != null
              ? (professionalData['rating'] as num).toDouble()
              : null;
          _professionalTotalReviews = professionalData['totalReviews'];
        });
      }

      // Buscar serviços do profissional (para usar como "trabalhos")
      try {
        final services = await ServiceRepository.findByProfessionalId(widget.professionalId);
        setState(() {
          _works = services.where((s) => s.status == 'completed').map((s) {
            return WorkModel(
              id: s.id,
              professionalId: s.professionalId,
              title: s.title,
              description: s.description ?? '',
              images: [],
              category: s.category ?? 'Geral',
              completedAt: s.completedDate ?? s.createdAt,
              price: s.price,
              clientName: s.professionalName ?? 'Cliente',
            );
          }).toList();
        });
      } catch (e) {
        // Se não conseguir buscar serviços, deixa vazio
        setState(() {
          _works = [];
        });
      }

      // Buscar reviews reais
      try {
        final reviews = await ReviewRepository.getByProfessionalId(widget.professionalId);
        setState(() {
          _reviews = reviews;
        });
      } catch (e) {
        setState(() {
          _reviews = [];
        });
      }

      // Buscar ads reais
      try {
        final ads = await AdRepository.getByProfessionalId(widget.professionalId, isActive: true);
        setState(() {
          _ads = ads;
        });
      } catch (e) {
        setState(() {
          _ads = [];
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: CustomDrawer(
        userName: _currentUser?['name'],
        userEmail: _currentUser?['email'],
        userType: _currentUser?['userType'],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Column(
              children: [
                MainHeader(
                  title: _professionalName ?? widget.professionalName,
                  subtitle: _categories.isNotEmpty ? _categories.first : (widget.specialty ?? 'Profissional'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(screenWidth),
                        _buildInfoSection(screenWidth),
                        _buildTabs(),
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.12,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person,
                  size: screenWidth * 0.15,
                  color: Colors.white,
                ),
              ),
              if (_isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _professionalName ?? widget.professionalName,
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (_professionalRating != null || widget.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  (_professionalRating ?? widget.rating ?? 0.0).toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_professionalTotalReviews != null || widget.totalReviews != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${_professionalTotalReviews ?? widget.totalReviews ?? 0} avaliações)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _categories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppConstants.categoryIcons[category] ?? Icons.category,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(screenWidth * 0.05),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_bio != null) ...[
            Text(
              'Sobre',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _bio!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_coverageArea != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  _coverageArea!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Avaliações'),
          Tab(text: 'Trabalhos'),
          Tab(text: 'Anúncios'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      height: 600,
      color: AppColors.background,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewsTab(),
          _buildWorksTab(),
          _buildAdsTab(),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Nenhuma avaliação ainda',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        review.clientName.isNotEmpty 
                            ? review.clientName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.clientName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < review.rating ? Icons.star : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    review.comment,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorksTab() {
    if (_works.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Nenhum trabalho publicado ainda',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _works.length,
      itemBuilder: (context, index) {
        final work = _works[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    AppConstants.categoryIcons[work.category] ?? Icons.work,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            work.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (work.price != null)
                          Text(
                            'R\$ ${NumberFormat('#,##0.00').format(work.price)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      work.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          work.category,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MM/yyyy').format(work.completedAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdsTab() {
    if (_ads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Nenhum anúncio ativo',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ads.length,
      itemBuilder: (context, index) {
        final ad = _ads[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppConstants.categoryIcons[ad.category] ?? Icons.campaign,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ad.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ad.category,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ad.price > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'R\$ ${NumberFormat('#,##0.00').format(ad.price)}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  ad.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}


