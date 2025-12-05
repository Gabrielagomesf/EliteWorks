import '../config/database_config.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';
import '../models/professional_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DatabaseService {
  static DbCollection get _usersCollection =>
      DatabaseConfig.getCollection('users');
  
  static DbCollection get _servicesCollection =>
      DatabaseConfig.getCollection('services');
  
  static DbCollection get _professionalsCollection =>
      DatabaseConfig.getCollection('professionals');

  static Future<UserModel?> findUserByEmail(String email) async {
    try {
      final user = await _usersCollection.findOne(where.eq('email', email));
      if (user != null) {
        return UserModel.fromJson(user);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel?> findUserById(String id) async {
    try {
      final user = await _usersCollection.findOne(where.id(ObjectId.fromHexString(id)));
      if (user != null) {
        return UserModel.fromJson(user);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> createUser(UserModel user, {String? password}) async {
    try {
      final userJson = user.toJson();
      if (password != null) {
        userJson['password'] = password;
      }
      final result = await _usersCollection.insertOne(userJson);
      if (result.isSuccess && result.id != null) {
        return result.id.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      var modifier = modify;
      updates.forEach((key, value) {
        if (value != null) {
          modifier = modifier.set(key, value);
        }
      });
      
      final result = await _usersCollection.updateOne(
        where.id(ObjectId.fromHexString(id)),
        modifier,
      );
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> createService(ServiceModel service) async {
    try {
      final serviceJson = service.toJson();
      final result = await _servicesCollection.insertOne(serviceJson);
      if (result.isSuccess && result.id != null) {
        return result.id.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ServiceModel>> getServicesByClientId(String clientId) async {
    try {
      final services = await _servicesCollection
          .find(where.eq('clientId', clientId))
          .toList();
      return services.map((s) => ServiceModel.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<ServiceModel>> getServicesByProfessionalId(String professionalId) async {
    try {
      final services = await _servicesCollection
          .find(where.eq('professionalId', professionalId))
          .toList();
      return services.map((s) => ServiceModel.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateService(String id, Map<String, dynamic> updates) async {
    try {
      final result = await _servicesCollection.updateOne(
        where.id(ObjectId.fromHexString(id)),
        modify.set('', updates),
      );
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> createProfessional(ProfessionalModel professional) async {
    try {
      final professionalJson = professional.toJson();
      final result = await _professionalsCollection.insertOne(professionalJson);
      if (result.isSuccess && result.id != null) {
        return result.id.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ProfessionalModel?> getProfessionalByUserId(String userId) async {
    try {
      final professional = await _professionalsCollection.findOne(
        where.eq('userId', userId),
      );
      if (professional != null) {
        return ProfessionalModel.fromJson(professional);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ProfessionalModel>> getFeaturedProfessionals() async {
    try {
      final professionals = await _professionalsCollection
          .find(where)
          .toList();
      // Ordenar por avaliação (melhores primeiro)
      professionals.sort((a, b) {
        final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
        final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
      return professionals.take(10).map((p) => ProfessionalModel.fromJson(p)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateProfessional(String id, Map<String, dynamic> updates) async {
    try {
      final result = await _professionalsCollection.updateOne(
        where.id(ObjectId.fromHexString(id)),
        modify.set('', updates),
      );
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final result = await _usersCollection.deleteOne(
        where.id(ObjectId.fromHexString(id)),
      );
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProfessionalByUserId(String userId) async {
    try {
      final result = await _professionalsCollection.deleteOne(
        where.eq('userId', userId),
      );
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Busca profissionais com filtros
  /// 
  /// [query] - Texto de busca (nome, categoria, bio)
  /// [category] - Categoria específica (opcional)
  /// [minRating] - Avaliação mínima (opcional)
  /// [maxPrice] - Preço máximo (opcional)
  /// [location] - Localização/área de cobertura (opcional)
  /// [limit] - Limite de resultados
  /// [skip] - Quantidade de resultados para pular (paginação)
  static Future<List<ProfessionalModel>> searchProfessionals({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    String? location,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      SelectorBuilder selector = where;

      // Filtro por categoria
      if (category != null && category.isNotEmpty) {
        selector = selector.eq('categories', category);
      }

      // Filtro por avaliação mínima
      if (minRating != null) {
        selector = selector.gte('rating', minRating);
      }

      // Filtro por localização (área de cobertura)
      if (location != null && location.isNotEmpty) {
        selector = selector.match('coverageArea', location, caseInsensitive: true);
      }

      // Busca por texto (categoria, bio)
      // Nota: MongoDB não suporta OR direto com outros filtros facilmente
      // Vamos fazer busca simples primeiro e filtrar depois
      bool hasTextSearch = query != null && query.isNotEmpty;

      // Buscar profissionais
      List<Map<String, dynamic>> allProfessionals;
      
      if (hasTextSearch) {
        // Se tem busca de texto, buscar todos e filtrar depois
        allProfessionals = await _professionalsCollection.find(selector).toList();
        
        // Filtrar por texto (categoria ou bio)
        final queryLower = query.toLowerCase();
        allProfessionals = allProfessionals.where((p) {
          final categories = (p['categories'] as List?)?.map((e) => e.toString().toLowerCase()).join(' ') ?? '';
          final bio = (p['bio'] as String?)?.toLowerCase() ?? '';
          return categories.contains(queryLower) || bio.contains(queryLower);
        }).toList();
      } else {
        allProfessionals = await _professionalsCollection.find(selector).toList();
      }
      
      // Ordenar por avaliação (melhores primeiro)
      allProfessionals.sort((a, b) {
        final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
        final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
      
      // Aplicar paginação
      final professionals = allProfessionals.skip(skip).take(limit).toList();

      // Converter para modelos
      final results = professionals.map((p) {
        // Buscar dados do usuário associado
        return ProfessionalModel.fromJson(p);
      }).toList();

      // Filtrar por preço se especificado (após buscar, pois preços estão em servicePrices)
      if (maxPrice != null) {
        return results.where((p) {
          if (p.servicePrices == null || p.servicePrices!.isEmpty) {
            return true; // Incluir se não tiver preços definidos
          }
          // Verificar se algum serviço tem preço menor que maxPrice
          return p.servicePrices!.values.any((price) => price <= maxPrice);
        }).toList();
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Busca profissionais e retorna com informações do usuário
  static Future<List<Map<String, dynamic>>> searchProfessionalsWithUserInfo({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    String? location,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final professionals = await searchProfessionals(
        query: query,
        category: category,
        minRating: minRating,
        maxPrice: maxPrice,
        location: location,
        limit: limit,
        skip: skip,
      );

      // Buscar informações dos usuários e filtrar por nome se houver query
      final results = <Map<String, dynamic>>[];
      for (final professional in professionals) {
        final user = await findUserById(professional.userId);
        if (user != null) {
          // Se houver query, verificar se o nome do usuário corresponde
          bool shouldInclude = true;
          if (query != null && query.isNotEmpty) {
            final queryLower = query.toLowerCase();
            final userNameLower = user.name.toLowerCase();
            // Incluir se corresponder ao nome OU já foi incluído pela busca de categoria/bio
            shouldInclude = userNameLower.contains(queryLower) || true;
          }
          
          if (shouldInclude) {
            results.add({
              'professional': professional,
              'user': user,
            });
          }
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Conta total de profissionais que correspondem aos filtros
  static Future<int> countProfessionals({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    String? location,
  }) async {
    try {
      SelectorBuilder selector = where;

      if (category != null && category.isNotEmpty) {
        selector = selector.eq('categories', category);
      }

      if (minRating != null) {
        selector = selector.gte('rating', minRating);
      }

      if (location != null && location.isNotEmpty) {
        selector = selector.match('coverageArea', location, caseInsensitive: true);
      }

      // Para count, buscar todos e filtrar depois se tiver query
      if (query != null && query.isNotEmpty) {
        final allProfessionals = await _professionalsCollection.find(selector).toList();
        final queryLower = query.toLowerCase();
        final filtered = allProfessionals.where((p) {
          final categories = (p['categories'] as List?)?.map((e) => e.toString().toLowerCase()).join(' ') ?? '';
          final bio = (p['bio'] as String?)?.toLowerCase() ?? '';
          return categories.contains(queryLower) || bio.contains(queryLower);
        }).toList();
        return filtered.length;
      }

      return await _professionalsCollection.count(selector);
    } catch (e) {
      return 0;
    }
  }
}

