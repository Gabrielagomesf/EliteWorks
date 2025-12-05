import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../services/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  Map<String, String>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
    });
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
            title: 'Segurança',
            subtitle: 'Proteção de dados e privacidade',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityCard(
                    Icons.lock_outline,
                    'Criptografia',
                    'Todos os dados sensíveis são criptografados usando padrões da indústria. Suas senhas são armazenadas de forma segura e nunca são compartilhadas.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityCard(
                    Icons.verified_user_outlined,
                    'Autenticação Segura',
                    'Utilizamos autenticação baseada em tokens JWT para garantir que apenas você tenha acesso à sua conta.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityCard(
                    Icons.cloud_done_outlined,
                    'Armazenamento Seguro',
                    'Suas informações são armazenadas em servidores seguros com backups regulares e monitoramento 24/7.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityCard(
                    Icons.shield_outlined,
                    'Proteção contra Fraude',
                    'Monitoramos continuamente atividades suspeitas e implementamos medidas para prevenir fraudes.',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Boas Práticas de Segurança'),
                  _buildTipItem(
                    'Use senhas fortes',
                    'Combine letras, números e símbolos. Evite informações pessoais óbvias.',
                  ),
                  _buildTipItem(
                    'Não compartilhe suas credenciais',
                    'Nunca compartilhe sua senha com ninguém, nem mesmo com nossa equipe.',
                  ),
                  _buildTipItem(
                    'Mantenha o app atualizado',
                    'Atualizações incluem correções de segurança importantes.',
                  ),
                  _buildTipItem(
                    'Verifique transações regularmente',
                    'Monitore seu histórico de pagamentos e notifique sobre atividades suspeitas.',
                  ),
                  _buildTipItem(
                    'Use conexões seguras',
                    'Evite usar Wi-Fi público ao acessar informações sensíveis.',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('LGPD - Lei Geral de Proteção de Dados'),
                  _buildSecurityCard(
                    Icons.gavel_outlined,
                    'Conformidade com LGPD',
                    'Estamos em total conformidade com a Lei Geral de Proteção de Dados (Lei 13.709/2018). Você tem controle total sobre seus dados pessoais.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityCard(
                    Icons.assignment_outlined,
                    'Seus Direitos',
                    'Você pode acessar, corrigir, excluir ou solicitar portabilidade de seus dados a qualquer momento através das configurações.',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(IconData icon, String title, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

