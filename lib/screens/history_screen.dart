import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../services/auth_service.dart';
import '../services/repositories/service_repository.dart';
import '../services/repositories/professional_repository.dart';
import '../models/service_model.dart';
import 'service_detail_screen.dart';
import 'service_detail_professional_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, String>? _currentUser;
  String _selectedFilter = 'all';
  bool _isLoading = true;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadHistory();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.initialize();
      final user = await AuthService.getCurrentUserBasic();
      
      if (user != null && user['id'] != null) {
        List<ServiceModel> services = [];
        
        if (user['userType'] == 'profissional') {
          final professional = await ProfessionalRepository.findByUserId(user['id']!);
          if (professional != null) {
            services = await ServiceRepository.findByProfessionalId(professional.id);
          }
        } else {
          services = await ServiceRepository.findByClientId(user['id']!);
        }
        
        setState(() {
          _services = services;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
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
            title: AppStrings.history,
            subtitle: _currentUser?['userType'] == 'profissional'
                ? 'Histórico de serviços recebidos'
                : 'Seu histórico de serviços',
          ),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['all', 'pending', 'in_progress', 'completed', 'cancelled'];
    final filterLabels = {
      'all': 'Todos',
      'pending': 'Pendentes',
      'in_progress': 'Em Andamento',
      'completed': 'Concluídos',
      'cancelled': 'Cancelados',
    };

    void applyFilter(String filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filterLabels[filter]!),
              selected: isSelected,
              onSelected: (selected) {
                applyFilter(filter);
              },
              selectedColor: AppColors.primary,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    // Filtrar serviços baseado no filtro selecionado
    List<ServiceModel> filteredServices = _services;
    if (_selectedFilter != 'all') {
      filteredServices = _services.where((s) {
        switch (_selectedFilter) {
          case 'pending':
            return s.status == 'pending';
          case 'in_progress':
            return s.status == 'in_progress' || s.status == 'accepted';
          case 'completed':
            return s.status == 'completed';
          case 'cancelled':
            return s.status == 'cancelled';
          default:
            return true;
        }
      }).toList();
    }

    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Nenhum histórico ainda',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final service = filteredServices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _currentUser?['userType'] == 'profissional'
                      ? ServiceDetailProfessionalScreen(serviceId: service.id)
                      : ServiceDetailScreen(serviceId: service.id),
                ),
              );
              if (result == true) {
                _loadHistory();
              }
            },
            child: ListTile(
              leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(service.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(service.status),
                color: _getStatusColor(service.status),
              ),
            ),
            title: Text(
              service.title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentUser?['userType'] == 'profissional') ...[
                  if (service.clientName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.clientName!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ] else ...[
                  if (service.professionalName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.professionalName!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
                if (service.description != null && service.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(service.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (service.price != null)
                  Text(
                    'R\$ ${NumberFormat('#,##0.00').format(service.price)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(service.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(service.status),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _getStatusColor(service.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
      case 'accepted':
        return AppColors.warning;
      case 'pending':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
      case 'accepted':
        return Icons.hourglass_empty;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Concluído';
      case 'in_progress':
      case 'accepted':
        return 'Em Andamento';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }
}


