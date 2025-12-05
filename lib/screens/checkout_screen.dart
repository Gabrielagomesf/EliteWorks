import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_colors.dart';
import '../services/repositories/payment_repository.dart';
import '../services/api/api_service.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  final String serviceId;
  final double amount;
  final String serviceTitle;

  const CheckoutScreen({
    super.key,
    required this.serviceId,
    required this.amount,
    required this.serviceTitle,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isProcessing = false;

  // PIX
  String? _pixQrCode;
  String? _pixCopyPaste;

  // Cartão
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardCpfController = TextEditingController();
  int _installments = 1;
  String? _selectedPaymentMethod;
  String? _cardToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cardExpiryController.addListener(() => _formatExpiry(_cardExpiryController.text));
    _cardNumberController.addListener(() => _formatCardNumber(_cardNumberController.text));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardCpfController.dispose();
    super.dispose();
  }

  void _formatCardNumber(String value) {
    final text = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length <= 16) {
      String formatted = '';
      for (int i = 0; i < text.length; i++) {
        if (i > 0 && i % 4 == 0) formatted += ' ';
        formatted += text[i];
      }
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _formatExpiry(String value) {
    final text = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length <= 4) {
      String formatted = text;
      if (text.length >= 2) {
        formatted = '${text.substring(0, 2)}/${text.substring(2)}';
      }
      _cardExpiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _createPixPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payment = await PaymentRepository.create(
        serviceId: widget.serviceId,
        amount: widget.amount,
        method: 'PIX',
      );

      if (payment != null) {
        setState(() {
          _pixQrCode = payment.pixQrCode;
          _pixCopyPaste = payment.pixCopyPaste;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao criar pagamento PIX'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createCardToken() async {
    if (_cardNumberController.text.isEmpty ||
        _cardNameController.text.isEmpty ||
        _cardExpiryController.text.isEmpty ||
        _cardCvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os dados do cartão'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final expiry = _cardExpiryController.text.split('/');
      if (expiry.length != 2) {
        throw Exception('Data de validade inválida');
      }

      final response = await ApiService.post(
        '/payments/card-token',
        {
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'cardholderName': _cardNameController.text,
          'cardExpirationMonth': expiry[0],
          'cardExpirationYear': expiry[1],
          'securityCode': _cardCvvController.text,
          'identificationType': 'CPF',
          'identificationNumber': _cardCpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        },
        requiresAuth: true,
      );

      if (response['success'] == true && response['token'] != null) {
        setState(() {
          _cardToken = response['token'];
        });
        await _processCardPayment();
      } else {
        throw Exception(response['error'] ?? 'Erro ao processar cartão');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar cartão: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processCardPayment() async {
    if (_cardToken == null || _selectedPaymentMethod == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      final payment = await PaymentRepository.create(
        serviceId: widget.serviceId,
        amount: widget.amount,
        method: _selectedPaymentMethod!,
        cardToken: _cardToken!,
        installments: _installments,
      );

      if (payment != null) {
        setState(() {
          _isProcessing = false;
        });

        if (mounted) {
          if (payment.status == 'completed') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pagamento aprovado!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pagamento pendente. Aguardando confirmação...'),
              ),
            );
          }
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar pagamento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _copyPixCode() {
    if (_pixCopyPaste != null) {
      Clipboard.setData(ClipboardData(text: _pixCopyPaste!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pagamento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'PIX', icon: Icon(Icons.qr_code)),
            Tab(text: 'Cartão', icon: Icon(Icons.credit_card)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPixTab(),
          _buildCardTab(),
        ],
      ),
    );
  }

  Widget _buildPixTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceTitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valor: R\$ ${widget.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_pixQrCode == null && !_isLoading)
            PrimaryButton(
              text: 'Gerar QR Code PIX',
              onPressed: _createPixPayment,
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_pixQrCode != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    QrImageView(
                      data: _pixCopyPaste ?? '',
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    if (_pixCopyPaste != null) ...[
                      Text(
                        'Código PIX (Copiar e Colar)',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _pixCopyPaste!,
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _copyPixCode,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar Código'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceTitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valor: R\$ ${widget.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _cardNumberController,
            label: 'Número do Cartão',
            hintText: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.credit_card,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cardNameController,
            label: 'Nome no Cartão',
            hintText: 'Nome completo',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cardExpiryController,
                  label: 'Validade',
                  hintText: 'MM/AA',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _cardCvvController,
                  label: 'CVV',
                  hintText: '123',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cardCpfController,
            label: 'CPF do Titular',
            hintText: '000.000.000-00',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.badge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo de Cartão',
              prefixIcon: const Icon(Icons.payment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Cartão de Crédito', child: Text('Cartão de Crédito')),
              DropdownMenuItem(value: 'Cartão de Débito', child: Text('Cartão de Débito')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          if (_selectedPaymentMethod == 'Cartão de Crédito') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Parcelas',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _installments,
              items: List.generate(12, (index) {
                final installments = index + 1;
                return DropdownMenuItem(
                  value: installments,
                  child: Text('${installments}x ${installments > 1 ? 'sem juros' : ''}'),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _installments = value ?? 1;
                });
              },
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: _isProcessing ? 'Processando...' : 'Pagar',
            onPressed: _isProcessing ? null : _createCardToken,
            isLoading: _isProcessing,
          ),
        ],
      ),
    );
  }
}

