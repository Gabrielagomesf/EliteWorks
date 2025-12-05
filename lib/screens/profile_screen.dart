import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/auth_service.dart';
import '../services/api/user_api_service.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../widgets/inputs/bank_dropdown.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../utils/validators.dart';
import '../services/cep_service.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'create_work_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  Map<String, String>? _currentUser;
  bool _isLoading = false;
  bool _isEditing = false;
  late TabController _tabController;
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _bankDataFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  bool _isLoadingCep = false;
  final _bankCodeController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountDigitController = TextEditingController();
  final _agencyController = TextEditingController();
  final _pixKeyController = TextEditingController();
  final _pixKeyTypeController = TextEditingController();
  String? _profileImagePath;
  File? _profileImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _zipCodeController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bankCodeController.dispose();
    _accountNumberController.dispose();
    _accountDigitController.dispose();
    _agencyController.dispose();
    _pixKeyController.dispose();
    _pixKeyTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
      }
    });
  }

  Future<void> _searchCep() async {
    final cep = _zipCodeController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cep.length != 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CEP deve ter 8 dígitos'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingCep = true;
    });

    final addressData = await CepService.getAddressByCep(cep);

    if (mounted) {
      setState(() {
        _isLoadingCep = false;
      });

      if (addressData != null) {
        setState(() {
          _addressController.text = addressData['street'] ?? '';
          _neighborhoodController.text = addressData['neighborhood'] ?? '';
          _cityController.text = addressData['city'] ?? '';
          _stateController.text = addressData['state'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CEP não encontrado'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      // Mostrar opções: Câmera ou Galeria
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _profileImageFile = File(image.path);
          _profileImagePath = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Imagem selecionada com sucesso!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleSave(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.initialize();
      final currentUser = await AuthService.getCurrentUserBasic();
      
      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Usuário não encontrado');
      }

      final updates = <String, dynamic>{};

      // Determinar qual aba está sendo salva baseado no formKey
      if (formKey == _personalInfoFormKey) {
        // Salvar informações pessoais
        updates['name'] = _nameController.text.trim();
        updates['phone'] = _phoneController.text.trim();
        if (_cpfController.text.isNotEmpty) {
          updates['cpf'] = _cpfController.text.trim();
        }
        if (_birthDateController.text.isNotEmpty) {
          updates['birthDate'] = _birthDateController.text.trim();
        }
        if (_genderController.text.isNotEmpty) {
          updates['gender'] = _genderController.text.trim();
        }
        if (_profileImagePath != null) {
          updates['profileImage'] = _profileImagePath;
        }
      } else if (formKey == _addressFormKey) {
        // Salvar endereço
        final addressData = <String, dynamic>{
          'zipCode': _zipCodeController.text.trim(),
          'address': _addressController.text.trim(),
          'number': _numberController.text.trim(),
          'complement': _complementController.text.trim(),
          'neighborhood': _neighborhoodController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
        };
        updates['address'] = addressData;
      } else if (formKey == _bankDataFormKey) {
        // Salvar dados bancários
        final bankData = <String, dynamic>{
          'bankCode': _bankCodeController.text.trim(),
          'accountNumber': _accountNumberController.text.trim(),
          'accountDigit': _accountDigitController.text.trim(),
          'agency': _agencyController.text.trim(),
          'pixKey': _pixKeyController.text.trim(),
          'pixKeyType': _pixKeyTypeController.text.trim(),
        };
        updates['bankData'] = bankData;
      }

      // Atualizar no banco de dados via API
      final response = await UserApiService.updateProfile(updates);
      final success = response['success'] == true;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        if (success) {
          // Recarregar dados do usuário
          await _loadUser();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao atualizar perfil. Tente novamente.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
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
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Sair',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sair',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: CustomDrawer(
        userName: _currentUser?['name'],
        userEmail: _currentUser?['email'],
        userType: _currentUser?['userType'],
      ),
      body: Column(
        children: [
          MainHeader(
            title: AppStrings.profile,
            subtitle: _currentUser?['name'] ?? 'Usuário',
          ),
          _buildProfileHeader(screenWidth),
          if (_currentUser?['userType'] == 'profissional') _buildProfessionalActions(),
          _buildTabs(),
          Expanded(
            child:             TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(),
                _buildAddressTab(),
                _buildBankDataTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWorkScreen(),
            ),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trabalho adicionado ao portfólio!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Criar Trabalho/Portfólio'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      color: Colors.white,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.12,
                backgroundColor: AppColors.primary,
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : null,
                child: _profileImageFile == null
                    ? Text(
                        _currentUser?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?['name'] ?? 'Usuário',
                  style: GoogleFonts.inter(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?['email'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentUser?['userType'] == 'profissional'
                        ? 'Profissional'
                        : 'Cliente',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Resetar campos se cancelar
                  _loadUser();
                }
              });
            },
          ),
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
          Tab(text: 'Informações Pessoais'),
          Tab(text: 'Endereço'),
          Tab(text: 'Dados Bancários'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _personalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Nome completo',
              controller: _nameController,
              prefixIcon: Icons.person,
              enabled: _isEditing,
              validator: _isEditing ? Validators.name : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              enabled: false, // Email não pode ser editado
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Telefone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              enabled: _isEditing,
              validator: _isEditing ? Validators.phone : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'CPF',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.badge_outlined,
              enabled: _isEditing,
              validator: _isEditing
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu CPF';
                      }
                      final cleanCpf = value.replaceAll(RegExp(r'[^\d]'), '');
                      if (cleanCpf.length != 11) {
                        return 'CPF deve ter 11 dígitos';
                      }
                      return null;
                    }
                  : null,
              onChanged: (value) {
                // Formatar CPF automaticamente
                final cleanCpf = value.replaceAll(RegExp(r'[^\d]'), '');
                if (cleanCpf.length <= 11) {
                  String formatted = '';
                  if (cleanCpf.length <= 3) {
                    formatted = cleanCpf;
                  } else if (cleanCpf.length <= 6) {
                    formatted = '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3)}';
                  } else if (cleanCpf.length <= 9) {
                    formatted = '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6)}';
                  } else {
                    formatted = '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
                  }
                  if (formatted != value) {
                    _cpfController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isEditing
                  ? () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          _birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    }
                  : null,
              child: CustomTextField(
                label: 'Data de Nascimento',
                controller: _birthDateController,
                prefixIcon: Icons.calendar_today_outlined,
                enabled: false,
                readOnly: true,
                validator: _isEditing
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione sua data de nascimento';
                        }
                        return null;
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _genderController.text.isEmpty ? null : _genderController.text,
              decoration: InputDecoration(
                labelText: 'Gênero',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: _isEditing,
              ),
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                DropdownMenuItem(value: 'Prefiro não informar', child: Text('Prefiro não informar')),
              ],
              onChanged: _isEditing
                  ? (value) {
                      setState(() {
                        _genderController.text = value ?? '';
                      });
                    }
                  : null,
              validator: _isEditing
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione seu gênero';
                      }
                      return null;
                    }
                  : null,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Salvar Alterações',
                isLoading: _isLoading,
                onPressed: () => _handleSave(_personalInfoFormKey),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _loadUser();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'CEP',
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_outlined,
                    enabled: _isEditing,
                    validator: _isEditing ? (value) => Validators.required(value, fieldName: 'CEP') : null,
                    onChanged: (value) {
                      // Formatar CEP automaticamente
                      if (value.length == 8 && !value.contains('-')) {
                        final formatted = '${value.substring(0, 5)}-${value.substring(5)}';
                        _zipCodeController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingCep ? null : _searchCep,
                      icon: _isLoadingCep
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search, size: 20),
                      label: Text(_isLoadingCep ? 'Buscando...' : 'Buscar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Logradouro',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
              enabled: _isEditing,
              validator: _isEditing ? (value) => Validators.required(value, fieldName: 'logradouro') : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Número',
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.numbers_outlined,
                    enabled: _isEditing,
                    validator: _isEditing ? (value) => Validators.required(value, fieldName: 'número') : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: 'Complemento',
                    controller: _complementController,
                    prefixIcon: Icons.home_outlined,
                    enabled: _isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Bairro',
              controller: _neighborhoodController,
              prefixIcon: Icons.location_city_outlined,
              enabled: _isEditing,
              validator: _isEditing ? (value) => Validators.required(value, fieldName: 'bairro') : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: 'Cidade',
                    controller: _cityController,
                    prefixIcon: Icons.location_city_outlined,
                    enabled: _isEditing,
                    validator: _isEditing ? (value) => Validators.required(value, fieldName: 'cidade') : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    label: 'UF',
                    controller: _stateController,
                    prefixIcon: Icons.map_outlined,
                    enabled: _isEditing,
                    validator: _isEditing ? (value) => Validators.required(value, fieldName: 'estado') : null,
                  ),
                ),
              ],
            ),
            if (_isEditing) ...[
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Salvar Endereço',
                isLoading: _isLoading,
                onPressed: () => _handleSave(_addressFormKey),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _loadUser();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _bankDataFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BankDropdown(
              value: _bankCodeController.text.isEmpty ? null : _bankCodeController.text,
              onChanged: _isEditing
                  ? (value) {
                      setState(() {
                        _bankCodeController.text = value ?? '';
                      });
                    }
                  : null,
              enabled: _isEditing,
              validator: _isEditing
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione o banco';
                      }
                      return null;
                    }
                  : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Agência',
              controller: _agencyController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.business_outlined,
              enabled: _isEditing,
              validator: _isEditing ? (value) => Validators.required(value, fieldName: 'agência') : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: 'Número da Conta',
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.credit_card_outlined,
                    enabled: _isEditing,
                    validator: _isEditing ? (value) => Validators.required(value, fieldName: 'número da conta') : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    label: 'Dígito',
                    controller: _accountDigitController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.numbers_outlined,
                    enabled: _isEditing,
                    validator: _isEditing
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Dígito obrigatório';
                            }
                            if (value.length != 1) {
                              return '1 dígito';
                            }
                            return null;
                          }
                        : null,
                    onChanged: (value) {
                      // Limitar a 1 dígito
                      if (value.length > 1) {
                        _accountDigitController.value = TextEditingValue(
                          text: value.substring(0, 1),
                          selection: TextSelection.collapsed(offset: 1),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Divider(
              color: AppColors.border,
              thickness: 1,
            ),
            const SizedBox(height: 20),
            Text(
              'Dados PIX',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _pixKeyTypeController.text.isEmpty ? null : _pixKeyTypeController.text,
              decoration: InputDecoration(
                labelText: 'Tipo de Chave PIX',
                prefixIcon: const Icon(Icons.qr_code_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: _isEditing,
              ),
              items: const [
                DropdownMenuItem(value: 'CPF', child: Text('CPF')),
                DropdownMenuItem(value: 'Email', child: Text('Email')),
                DropdownMenuItem(value: 'Telefone', child: Text('Telefone')),
                DropdownMenuItem(value: 'Chave Aleatória', child: Text('Chave Aleatória')),
              ],
              onChanged: _isEditing
                  ? (value) {
                      setState(() {
                        _pixKeyTypeController.text = value ?? '';
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Chave PIX',
              controller: _pixKeyController,
              prefixIcon: Icons.qr_code_2_outlined,
              enabled: _isEditing,
              validator: _isEditing
                  ? (value) {
                      if (_pixKeyTypeController.text.isNotEmpty && (value == null || value.isEmpty)) {
                        return 'Por favor, insira a chave PIX';
                      }
                      return null;
                    }
                  : null,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Salvar Dados Bancários',
                isLoading: _isLoading,
                onPressed: () => _handleSave(_bankDataFormKey),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _loadUser();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            if (!_isEditing) ...[
              const SizedBox(height: 24),
              Card(
                color: AppColors.warning.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Seus dados bancários são criptografados e seguros.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
