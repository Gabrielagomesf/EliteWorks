import 'package:flutter/material.dart';

class AppConstants {
  static const int minPasswordLength = 6;
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultCardElevation = 2.0;
  
  static const List<String> serviceCategories = [
    'Construção',
    'Limpeza',
    'Elétrica',
    'Encanamento',
    'Design',
    'Tecnologia',
    'Pintura',
    'Marcenaria',
    'Jardinagem',
    'Diarista',
    'Encanador',
    'Eletricista',
    'Pedreiro',
    'Carpinteiro',
    'Vidraceiro',
    'Soldador',
    'Serralheiro',
    'Arquiteto',
    'Engenheiro',
    'Designer de Interiores',
    'Fotógrafo',
    'Videomaker',
    'Organizador de Eventos',
    'Personal Trainer',
    'Nutricionista',
    'Massagista',
    'Cabeleireiro',
    'Manicure',
    'Esteticista',
    'Mecânico',
    'Técnico de Informática',
    'Professor Particular',
  ];
  
  static const Map<String, IconData> categoryIcons = {
    'Construção': Icons.build,
    'Limpeza': Icons.cleaning_services,
    'Elétrica': Icons.electrical_services,
    'Encanamento': Icons.plumbing,
    'Design': Icons.palette,
    'Tecnologia': Icons.computer,
    'Pintura': Icons.format_paint,
    'Marcenaria': Icons.carpenter,
    'Jardinagem': Icons.local_florist,
    'Diarista': Icons.home_work,
    'Encanador': Icons.plumbing,
    'Eletricista': Icons.electrical_services,
    'Pedreiro': Icons.construction,
    'Carpinteiro': Icons.carpenter,
    'Vidraceiro': Icons.window,
    'Soldador': Icons.whatshot,
    'Serralheiro': Icons.hardware,
    'Arquiteto': Icons.architecture,
    'Engenheiro': Icons.engineering,
    'Designer de Interiores': Icons.home,
    'Fotógrafo': Icons.camera_alt,
    'Videomaker': Icons.videocam,
    'Organizador de Eventos': Icons.event,
    'Personal Trainer': Icons.fitness_center,
    'Nutricionista': Icons.restaurant,
    'Massagista': Icons.spa,
    'Cabeleireiro': Icons.content_cut,
    'Manicure': Icons.face,
    'Esteticista': Icons.face_retouching_natural,
    'Mecânico': Icons.build_circle,
    'Técnico de Informática': Icons.computer,
    'Professor Particular': Icons.school,
  };
  
  static const List<String> serviceStatuses = [
    'pending',
    'accepted',
    'in_progress',
    'completed',
    'cancelled',
  ];
}

