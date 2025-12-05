import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../services/auth_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
            title: 'Política de Privacidade',
            subtitle: 'Como protegemos seus dados',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '1. Introdução',
                    'O EliteWorks valoriza a privacidade de seus usuários e está comprometido em proteger suas informações pessoais. Esta Política de Privacidade descreve como coletamos, usamos, armazenamos e protegemos seus dados quando você utiliza nossos serviços.',
                  ),
                  _buildSection(
                    '2. Informações que Coletamos',
                    'Coletamos informações que você nos fornece diretamente, incluindo:\n\n'
                    '• Nome, email e telefone\n'
                    '• Dados de perfil e documentos\n'
                    '• Informações de pagamento\n'
                    '• Endereço e localização\n'
                    '• Mensagens e comunicações\n'
                    '• Imagens de perfil e portfólio',
                  ),
                  _buildSection(
                    '3. Como Usamos suas Informações',
                    'Utilizamos suas informações para:\n\n'
                    '• Prestar e melhorar nossos serviços\n'
                    '• Facilitar conexões entre profissionais e clientes\n'
                    '• Processar pagamentos e transações\n'
                    '• Enviar notificações importantes\n'
                    '• Personalizar sua experiência\n'
                    '• Garantir segurança e prevenir fraudes',
                  ),
                  _buildSection(
                    '4. Compartilhamento de Dados',
                    'Não vendemos suas informações pessoais. Podemos compartilhar dados apenas:\n\n'
                    '• Com profissionais/clientes para facilitar serviços\n'
                    '• Com prestadores de serviços que nos auxiliam\n'
                    '• Quando exigido por lei ou autoridades\n'
                    '• Para proteger direitos e segurança',
                  ),
                  _buildSection(
                    '5. Segurança dos Dados',
                    'Implementamos medidas de segurança técnicas e organizacionais:\n\n'
                    '• Criptografia de dados sensíveis\n'
                    '• Autenticação segura\n'
                    '• Armazenamento em servidores protegidos\n'
                    '• Acesso restrito a informações\n'
                    '• Monitoramento contínuo de segurança',
                  ),
                  _buildSection(
                    '6. Seus Direitos (LGPD)',
                    'De acordo com a Lei Geral de Proteção de Dados, você tem direito a:\n\n'
                    '• Acessar seus dados pessoais\n'
                    '• Corrigir dados incompletos ou inexatos\n'
                    '• Solicitar exclusão de dados\n'
                    '• Revogar consentimento\n'
                    '• Portabilidade de dados\n'
                    '• Oposição ao tratamento',
                  ),
                  _buildSection(
                    '7. Cookies e Tecnologias',
                    'Utilizamos cookies e tecnologias similares para:\n\n'
                    '• Melhorar funcionalidade do app\n'
                    '• Personalizar conteúdo\n'
                    '• Analisar uso e performance\n'
                    '• Garantir segurança',
                  ),
                  _buildSection(
                    '8. Retenção de Dados',
                    'Mantemos suas informações pelo tempo necessário para:\n\n'
                    '• Prestar nossos serviços\n'
                    '• Cumprir obrigações legais\n'
                    '• Resolver disputas\n'
                    '• Aplicar nossos termos',
                  ),
                  _buildSection(
                    '9. Alterações nesta Política',
                    'Podemos atualizar esta Política periodicamente. Notificaremos sobre mudanças significativas através do app ou por email.',
                  ),
                  _buildSection(
                    '10. Contato',
                    'Para questões sobre privacidade ou exercer seus direitos, entre em contato:\n\n'
                    'Email: contato@eliteworks.com.br\n'
                    'Horário: Segunda a Sexta, 9h às 18h',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Última atualização: ${DateTime.now().year}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

