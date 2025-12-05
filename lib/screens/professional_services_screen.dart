import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/repositories/service_repository.dart';
import '../services/repositories/professional_repository.dart';
import '../models/service_model.dart';
import '../widgets/headers/main_header.dart';
import 'service_detail_screen.dart';
import 'service_detail_professional_screen.dart';

class ProfessionalServicesScreen extends StatefulWidget {
  final String? initialFilter;

  const ProfessionalServicesScreen({super.key, this.initialFilter});

  @override
  State<ProfessionalServicesScreen> createState() => _ProfessionalServicesScreenState();
}

class _ProfessionalServicesScreenState extends State<ProfessionalServicesScreen> {
  Map<String, String>? _currentUser;
  String? _professionalId;
  bool _isLoading = true;
  String _selectedFilter = 'all';
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.initialize();
      final user = await AuthService.getCurrentUserBasic();
      
      if (user != null && user['id'] != null) {
        setState(() {
          _currentUser = user;
        });

        final professional = await ProfessionalRepository.findByUserId(user['id']!);
        if (professional != null) {
          setState(() {
            _professionalId = professional.id;
          });

          await _loadServices();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadServices() async {
    if (_professionalId == null) return;

    try {
      final services = await ServiceRepository.findByProfessionalId(_professionalId!);
      
      if (mounted) {
        setState(() {
          _services = services;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar serviços: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<ServiceModel> get _filteredServices {
    if (_selectedFilter == 'all') {
      return _services;
    }
    return _services.where((s) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          MainHeader(
            title: 'Meus Serviços',
            subtitle: 'Gerencie suas solicitações',
          ),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadServices,
                    child: _filteredServices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return _buildServiceCard(service);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'key': 'all', 'label': 'Todos'},
      {'key': 'pending', 'label': 'Pendentes'},
      {'key': 'in_progress', 'label': 'Em Andamento'},
      {'key': 'completed', 'label': 'Concluídos'},
      {'key': 'cancelled', 'label': 'Cancelados'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter['key']!;
                  });
                }
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

  Widget _buildEmptyState() {
    String message = 'Nenhum serviço encontrado';
    IconData icon = Icons.inbox_outlined;

    switch (_selectedFilter) {
      case 'pending':
        message = 'Nenhuma solicitação pendente';
        icon = Icons.pending_outlined;
        break;
      case 'in_progress':
        message = 'Nenhum serviço em andamento';
        icon = Icons.work_outline;
        break;
      case 'completed':
        message = 'Nenhum serviço concluído';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'Nenhum serviço cancelado';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailProfessionalScreen(serviceId: service.id),
          ),
        );
          if (result == true) {
            _loadServices();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(service.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(service.status),
                  color: _getStatusColor(service.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (service.clientName != null) ...[
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            service.clientName!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(service.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (service.price != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.attach_money, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'R\$ ${NumberFormat('#,##0.00').format(service.price)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(service.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(service.status),
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
      case 'accepted':
        return AppColors.primary;
      case 'pending':
        return AppColors.warning;
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
        return Icons.work;
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
      case 'pending':
        return 'Pendente';
      case 'accepted':
        return 'Aceito';
      case 'in_progress':
        return 'Em Andamento';
      case 'completed':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }
}

