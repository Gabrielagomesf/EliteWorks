import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/service_model.dart';
import '../services/repositories/service_repository.dart';
import '../services/repositories/professional_repository.dart';
import '../services/auth_service.dart';
import '../widgets/buttons/primary_button.dart';
import 'chat_screen.dart';

class ServiceDetailProfessionalScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailProfessionalScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailProfessionalScreen> createState() => _ServiceDetailProfessionalScreenState();
}

class _ServiceDetailProfessionalScreenState extends State<ServiceDetailProfessionalScreen> {
  ServiceModel? _service;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _currentUserId;
  String? _professionalId;
  String? _clientUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.initialize();
      final user = await AuthService.getCurrentUserBasic();
      setState(() {
        _currentUserId = user?['id'];
      });

      if (user != null && user['id'] != null) {
        final professional = await ProfessionalRepository.findByUserId(user['id']!);
        if (professional != null) {
          setState(() {
            _professionalId = professional.id;
          });
        }
      }

      final service = await ServiceRepository.findById(widget.serviceId);
      if (service != null) {
        setState(() {
          _service = service;
          _clientUserId = service.clientId;
        });
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

  Future<void> _updateStatus(String newStatus) async {
    if (_service == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getStatusActionTitle(newStatus),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _getStatusActionMessage(newStatus),
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirmar',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updates = {'status': newStatus};
      
      if (newStatus == 'completed') {
        updates['completedDate'] = DateTime.now().toIso8601String();
      }

      final success = await ServiceRepository.update(widget.serviceId, updates);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getStatusSuccessMessage(newStatus)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        await _loadData();
      } else {
        throw Exception('Erro ao atualizar status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar serviço: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  String _getStatusActionTitle(String status) {
    switch (status) {
      case 'accepted':
        return 'Aceitar Solicitação';
      case 'rejected':
        return 'Rejeitar Solicitação';
      case 'in_progress':
        return 'Iniciar Serviço';
      case 'completed':
        return 'Completar Serviço';
      case 'cancelled':
        return 'Cancelar Serviço';
      default:
        return 'Alterar Status';
    }
  }

  String _getStatusActionMessage(String status) {
    switch (status) {
      case 'accepted':
        return 'Tem certeza que deseja aceitar esta solicitação de serviço? O cliente será notificado.';
      case 'rejected':
        return 'Tem certeza que deseja rejeitar esta solicitação? Esta ação não pode ser desfeita.';
      case 'in_progress':
        return 'Tem certeza que deseja iniciar este serviço? O cliente será notificado.';
      case 'completed':
        return 'Tem certeza que deseja marcar este serviço como concluído?';
      case 'cancelled':
        return 'Tem certeza que deseja cancelar este serviço? O cliente será notificado.';
      default:
        return 'Tem certeza que deseja alterar o status deste serviço?';
    }
  }

  String _getStatusSuccessMessage(String status) {
    switch (status) {
      case 'accepted':
        return 'Solicitação aceita com sucesso!';
      case 'in_progress':
        return 'Serviço iniciado com sucesso!';
      case 'completed':
        return 'Serviço marcado como concluído!';
      case 'cancelled':
        return 'Serviço cancelado com sucesso!';
      default:
        return 'Status atualizado com sucesso!';
    }
  }

  void _openChat() {
    if (_clientUserId == null || _service?.clientName == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: _clientUserId!,
          otherUserName: _service!.clientName ?? 'Cliente',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detalhes do Serviço'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (_service == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detalhes do Serviço'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Serviço não encontrado',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPending = _service!.status == 'pending';
    final isAccepted = _service!.status == 'accepted';
    final isInProgress = _service!.status == 'in_progress';
    final isCompleted = _service!.status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_service!.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(_service!.status),
                            style: GoogleFonts.inter(
                              color: _getStatusColor(_service!.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _service!.title,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_service!.description != null)
                      Text(
                        _service!.description!,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    if (_service!.price != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Valor: R\$ ${NumberFormat('#,##0.00').format(_service!.price)}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações do Cliente',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (_service!.clientName?.isNotEmpty ?? false)
                                ? _service!.clientName![0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _service!.clientName ?? 'Cliente',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openChat,
                      icon: const Icon(Icons.message),
                      label: const Text('Conversar com Cliente'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_service!.location != null && _service!.location!.address != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Localização',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _service!.location!.address ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_service!.location!.city != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_service!.location!.city}${_service!.location!.state != null ? ', ${_service!.location!.state}' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (_service!.scheduledDate != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agendado para',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(_service!.scheduledDate!),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Aceitar',
                      onPressed: _isUpdating ? null : () => _updateStatus('accepted'),
                      isLoading: _isUpdating,
                      backgroundColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('cancelled'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Rejeitar',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isAccepted) ...[
              PrimaryButton(
                text: 'Iniciar Serviço',
                onPressed: _isUpdating ? null : () => _updateStatus('in_progress'),
                isLoading: _isUpdating,
              ),
            ],
            if (isInProgress) ...[
              PrimaryButton(
                text: 'Marcar como Concluído',
                onPressed: _isUpdating ? null : () => _updateStatus('completed'),
                isLoading: _isUpdating,
                backgroundColor: AppColors.success,
              ),
            ],
            if (isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Serviço concluído com sucesso!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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

