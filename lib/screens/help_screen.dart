import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../services/auth_service.dart';
import '../utils/email_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Map<String, String>? _currentUser;
  final List<Map<String, dynamic>> _faqs = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFAQs();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserBasic();
    setState(() {
      _currentUser = user;
    });
  }

  void _loadFAQs() {
    setState(() {
      _faqs.addAll([
        {
          'question': 'Como contratar um profissional?',
          'answer': 'Para contratar um profissional, navegue até o perfil dele e clique em "Contratar". Você poderá descrever o serviço necessário e aguardar a resposta do profissional.',
        },
        {
          'question': 'Como funciona o pagamento?',
          'answer': 'O pagamento pode ser feito através de PIX, cartão de crédito ou boleto. O valor é liberado para o profissional após a conclusão do serviço.',
        },
        {
          'question': 'Como avaliar um profissional?',
          'answer': 'Após a conclusão do serviço, você receberá uma solicitação para avaliar o profissional. Você pode dar uma nota de 1 a 5 estrelas e deixar um comentário.',
        },
        {
          'question': 'Como cancelar um serviço?',
          'answer': 'Você pode cancelar um serviço a qualquer momento através da tela de histórico. Se o serviço já foi iniciado, pode haver taxas de cancelamento.',
        },
        {
          'question': 'Como me tornar um profissional?',
          'answer': 'Ao se cadastrar, escolha a opção "Profissional". Complete seu perfil, adicione suas categorias de serviço e comece a receber propostas de clientes.',
        },
      ]);
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
            title: AppStrings.help,
            subtitle: 'Central de ajuda',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildContactCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Perguntas Frequentes'),
                ..._faqs.map((faq) => _buildFAQItem(faq)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.support_agent,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Precisa de ajuda?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Entre em contato conosco',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactButton(
                  Icons.email,
                  'Email',
                  () {},
                ),
                const SizedBox(width: 12),
                _buildContactButton(
                  Icons.chat,
                  'Chat',
                  () {},
                ),
                const SizedBox(width: 12),
                _buildContactButton(
                  Icons.phone,
                  'Telefone',
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.officialEmail,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () async {
          if (icon == Icons.email) {
            // Abrir email
            final launched = await EmailLauncher.launchEmail(
              email: AppStrings.officialEmail,
              subject: 'Contato - EliteWorks',
              body: 'Olá, preciso de ajuda com...',
            );
            
            if (!launched && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Não foi possível abrir o cliente de email'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          } else {
            onTap();
          }
        },
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          faq['question'] as String,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq['answer'] as String,
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
  }
}

