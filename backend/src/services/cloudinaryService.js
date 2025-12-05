const cloudinary = require('cloudinary').v2;
const { Readable } = require('stream');
const fs = require('fs');

// Configurar Cloudinary (só se as credenciais estiverem disponíveis)
if (process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY && process.env.CLOUDINARY_API_SECRET) {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
  console.log('Cloudinary configurado com sucesso');
} else {
  console.warn('Cloudinary não configurado. Usando armazenamento local.');
}

class CloudinaryService {
  /**
   * Faz upload de uma imagem para o Cloudinary
   * @param {Buffer|string} file - Buffer do arquivo ou caminho do arquivo
   * @param {Object} options - Opções adicionais (folder, transformation, etc)
   * @returns {Promise<Object>} URL e informações da imagem
   */
  async uploadImage(file, options = {}) {
    try {
      // Verificar se Cloudinary está configurado
      if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
        return {
          success: false,
          error: 'Cloudinary não está configurado. Configure as variáveis de ambiente.',
        };
      }

      // Separar opções do Cloudinary das opções customizadas
      const { publicIdPrefix, ...cloudinaryOptions } = options;
      
      const uploadOptions = {
        folder: cloudinaryOptions.folder || 'eliteworks',
        resource_type: 'auto',
        quality: 'auto',
        fetch_format: 'auto',
        ...cloudinaryOptions,
      };
      
      let result;
      
      // Se for Buffer, fazer upload via stream
      if (Buffer.isBuffer(file)) {
        return new Promise((resolve, reject) => {
          const uploadStream = cloudinary.uploader.upload_stream(
            uploadOptions,
            (error, uploadResult) => {
              if (error) {
                console.error('Erro no upload stream do Cloudinary:', error);
                reject(error);
              } else {
                resolve({
                  success: true,
                  url: uploadResult.secure_url,
                  publicId: uploadResult.public_id,
                  format: uploadResult.format,
                  width: uploadResult.width,
                  height: uploadResult.height,
                  bytes: uploadResult.bytes,
                });
              }
            }
          );

          Readable.from(file).pipe(uploadStream);
        });
      } else {
        // Se for caminho do arquivo (string)
        if (!fs.existsSync(file)) {
          return {
            success: false,
            error: 'Arquivo não encontrado: ' + file,
          };
        }
        result = await cloudinary.uploader.upload(file, uploadOptions);
      }

      return {
        success: true,
        url: result.secure_url,
        publicId: result.public_id,
        format: result.format,
        width: result.width,
        height: result.height,
        bytes: result.bytes,
      };
    } catch (error) {
      console.error('Erro ao fazer upload para Cloudinary:', error);
      return {
        success: false,
        error: error.message || 'Erro ao fazer upload da imagem',
        details: error.toString(),
      };
    }
  }

  /**
   * Faz upload de múltiplas imagens
   * @param {Array<Buffer|string>} files - Array de Buffers ou caminhos
   * @param {Object} options - Opções adicionais
   * @returns {Promise<Array>} Array com URLs das imagens
   */
  async uploadMultipleImages(files, options = {}) {
    try {
      const publicIdPrefix = options.publicIdPrefix;
      delete options.publicIdPrefix; // Remover para não passar para uploadImage
      
      const uploadPromises = files.map((file, index) => {
        const fileOptions = {
          ...options,
          folder: options.folder || 'eliteworks',
          public_id: publicIdPrefix 
            ? `${publicIdPrefix}_${Date.now()}_${index}_${Math.round(Math.random() * 1E9)}` 
            : undefined,
        };
        return this.uploadImage(file, fileOptions);
      });

      const results = await Promise.all(uploadPromises);
      
      const successful = results.filter(r => r.success);
      const failed = results.filter(r => !r.success);

      return {
        success: failed.length === 0,
        urls: successful.map(r => r.url),
        publicIds: successful.map(r => r.publicId),
        failed: failed.length,
        total: results.length,
      };
    } catch (error) {
      console.error('Erro ao fazer upload múltiplo para Cloudinary:', error);
      return {
        success: false,
        error: error.message || 'Erro ao fazer upload das imagens',
      };
    }
  }

  /**
   * Deleta uma imagem do Cloudinary
   * @param {string} publicId - Public ID da imagem no Cloudinary
   * @returns {Promise<Object>} Resultado da deleção
   */
  async deleteImage(publicId) {
    try {
      const result = await cloudinary.uploader.destroy(publicId);
      return {
        success: result.result === 'ok',
        result: result.result,
      };
    } catch (error) {
      console.error('Erro ao deletar imagem do Cloudinary:', error);
      return {
        success: false,
        error: error.message || 'Erro ao deletar imagem',
      };
    }
  }
}

module.exports = new CloudinaryService();

