import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/repositories/professional_repository.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../utils/validators.dart';

class EditProfessionalProfileScreen extends StatefulWidget {
  const EditProfessionalProfileScreen({super.key});

  @override
  State<EditProfessionalProfileScreen> createState() => _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState extends State<EditProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _coverageAreaController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _professionalId;
  List<String> _selectedCategories = [];
  List<String> _certifications = [];
  Map<String, bool> _availability = {
    'monday': true,
    'tuesday': true,
    'wednesday': true,
    'thursday': true,
    'friday': true,
    'saturday': false,
    'sunday': false,
  };

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _coverageAreaController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionalData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      await AuthService.initialize();
      final user = await AuthService.getCurrentUserBasic();
      
      if (user != null && user['id'] != null) {
        final professional = await ProfessionalRepository.findByUserId(user['id']!);
        if (professional != null) {
          setState(() {
            _professionalId = professional.id;
            _bioController.text = professional.bio ?? '';
            _coverageAreaController.text = professional.coverageArea ?? '';
            _selectedCategories = List<String>.from(professional.categories);
            _experienceController.text = professional.experience ?? '';
            _certifications = List<String>.from(professional.certifications ?? []);
            
            if (professional.availability != null) {
              _availability = Map<String, bool>.from(professional.availability!);
            }
            
            if (professional.hourlyRate != null) {
              _hourlyRateController.text = professional.hourlyRate!.toStringAsFixed(2);
            } else if (professional.servicePrices != null && professional.servicePrices!.isNotEmpty) {
              _hourlyRateController.text = professional.servicePrices!.values.first.toStringAsFixed(2);
            }
          });
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
          _isLoadingData = false;
        });
      }
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _addCertification() {
    if (_certificationController.text.trim().isNotEmpty) {
      setState(() {
        _certifications.add(_certificationController.text.trim());
        _certificationController.clear();
      });
    }
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma categoria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_professionalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Profissional não encontrado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updates = <String, dynamic>{
        'categories': _selectedCategories,
        'bio': _bioController.text.trim(),
        'coverageArea': _coverageAreaController.text.trim(),
        'availability': _availability,
      };

      if (_hourlyRateController.text.trim().isNotEmpty) {
        final rate = double.tryParse(_hourlyRateController.text.trim().replaceAll(',', '.'));
        if (rate != null && rate > 0) {
          updates['hourlyRate'] = rate;
        }
      }

      if (_experienceController.text.trim().isNotEmpty) {
        updates['experience'] = _experienceController.text.trim();
      }

      if (_certifications.isNotEmpty) {
        updates['certifications'] = _certifications;
      }

      final success = await ProfessionalRepository.update(_professionalId!, updates);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Erro ao atualizar perfil');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: ${e.toString()}'),
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Perfil Profissional'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Categorias',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.serviceCategories.map((category) {
                        final isSelected = _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _toggleCategory(category),
                          selectedColor: AppColors.primary,
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _bioController,
                      label: 'Bio/Descrição',
                      hintText: 'Descreva seu trabalho e experiência...',
                      prefixIcon: Icons.description,
                      maxLines: 5,
                      validator: Validators.bio,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _coverageAreaController,
                      label: 'Área de Cobertura',
                      hintText: 'Ex: São Paulo - SP',
                      prefixIcon: Icons.location_on,
                      validator: Validators.coverageArea,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _hourlyRateController,
                      label: 'Taxa por Hora (R\$)',
                      hintText: '0,00',
                      prefixIcon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.price,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _experienceController,
                      label: 'Experiência',
                      hintText: 'Descreva sua experiência...',
                      prefixIcon: Icons.work_history,
                      maxLines: 3,
                      validator: Validators.experience,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Certificações',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _certificationController,
                            label: 'Adicionar Certificação',
                            hintText: 'Nome da certificação',
                            prefixIcon: Icons.card_membership,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addCertification,
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    if (_certifications.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _certifications.asMap().entries.map((entry) {
                          final index = entry.key;
                          final cert = entry.value;
                          return Chip(
                            label: Text(cert),
                            onDeleted: () => _removeCertification(index),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Disponibilidade',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          _buildDayCheckbox('Segunda-feira', 'monday'),
                          _buildDayCheckbox('Terça-feira', 'tuesday'),
                          _buildDayCheckbox('Quarta-feira', 'wednesday'),
                          _buildDayCheckbox('Quinta-feira', 'thursday'),
                          _buildDayCheckbox('Sexta-feira', 'friday'),
                          _buildDayCheckbox('Sábado', 'saturday'),
                          _buildDayCheckbox('Domingo', 'sunday'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Salvar Alterações',
                      onPressed: _isLoading ? null : _saveProfile,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDayCheckbox(String label, String key) {
    return CheckboxListTile(
      title: Text(label),
      value: _availability[key] ?? false,
      onChanged: (value) {
        setState(() {
          _availability[key] = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

