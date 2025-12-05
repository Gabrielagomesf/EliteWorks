import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/headers/main_header.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../services/auth_service.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
            title: 'Termos de Serviço',
            subtitle: 'Condições de uso da plataforma',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '1. Aceitação dos Termos',
                    'Ao utilizar o EliteWorks, você concorda com estes Termos de Serviço. Se não concordar, não utilize nossa plataforma.',
                  ),
                  _buildSection(
                    '2. Descrição do Serviço',
                    'O EliteWorks é uma plataforma que conecta profissionais autônomos com clientes que necessitam de serviços diversos. Atuamos como intermediário, facilitando a conexão e o pagamento.',
                  ),
                  _buildSection(
                    '3. Cadastro e Conta',
                    'Para usar nossos serviços, você precisa:\n\n'
                    '• Ter pelo menos 18 anos\n'
                    '• Fornecer informações verdadeiras\n'
                    '• Manter suas credenciais seguras\n'
                    '• Ser responsável por todas as atividades da sua conta\n'
                    '• Notificar imediatamente sobre uso não autorizado',
                  ),
                  _buildSection(
                    '4. Responsabilidades dos Usuários',
                    'Você concorda em:\n\n'
                    '• Usar o serviço apenas para fins legais\n'
                    '• Não publicar conteúdo ofensivo ou ilegal\n'
                    '• Respeitar outros usuários\n'
                    '• Não tentar acessar áreas restritas\n'
                    '• Não usar o serviço para atividades fraudulentas',
                  ),
                  _buildSection(
                    '5. Serviços e Pagamentos',
                    'O EliteWorks facilita transações entre usuários:\n\n'
                    '• Pagamentos são processados de forma segura\n'
                    '• Taxas podem ser aplicadas conforme descrito\n'
                    '• Reembolsos seguem nossa política específica\n'
                    '• Disputas serão mediadas pela plataforma',
                  ),
                  _buildSection(
                    '6. Propriedade Intelectual',
                    'Todo conteúdo da plataforma, incluindo design, logos e textos, é propriedade do EliteWorks e protegido por leis de direitos autorais.',
                  ),
                  _buildSection(
                    '7. Limitação de Responsabilidade',
                    'O EliteWorks não se responsabiliza por:\n\n'
                    '• Qualidade dos serviços prestados\n'
                    '• Disputas entre usuários\n'
                    '• Danos diretos ou indiretos\n'
                    '• Interrupções no serviço',
                  ),
                  _buildSection(
                    '8. Modificações do Serviço',
                    'Reservamos o direito de modificar, suspender ou descontinuar qualquer aspecto do serviço a qualquer momento, com ou sem aviso prévio.',
                  ),
                  _buildSection(
                    '9. Rescisão',
                    'Podemos suspender ou encerrar sua conta se você violar estes termos. Você pode solicitar encerramento da conta a qualquer momento.',
                  ),
                  _buildSection(
                    '10. Lei Aplicável',
                    'Estes termos são regidos pelas leis brasileiras. Disputas serão resolvidas nos tribunais competentes do Brasil.',
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

