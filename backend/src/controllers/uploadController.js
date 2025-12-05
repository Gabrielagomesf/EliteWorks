const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cloudinaryService = require('../services/cloudinaryService');

const uploadDir = path.join(__dirname, '../../uploads');

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
  },
});

const uploadSingle = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg', '.heic', '.heif', '.jfif', '.ico'];
    const allowedMimeTypes = /^image\//i;
    
    const extname = path.extname(file.originalname).toLowerCase();
    const extValid = allowedExtensions.includes(extname);
    const mimeValid = file.mimetype && allowedMimeTypes.test(file.mimetype);

    console.log('=== VALIDAÇÃO DE ARQUIVO ===');
    console.log('Nome do arquivo:', file.originalname);
    console.log('MIME type:', file.mimetype || 'NÃO FORNECIDO');
    console.log('Extensão:', extname || 'NENHUMA');
    console.log('Extensão válida?', extValid);
    console.log('MIME válido?', mimeValid);
    console.log('Field name:', file.fieldname);
    console.log('Encoding:', file.encoding);
    console.log('===========================');

    if (extValid || mimeValid) {
      console.log('✅ Arquivo ACEITO');
      return cb(null, true);
    }
    
    console.log('❌ Arquivo REJEITADO');
    console.log('Motivo: Extensão e MIME type não são de imagem');
    cb(new Error(`Apenas imagens são permitidas! Recebido: MIME type "${file.mimetype || 'desconhecido'}", extensão "${extname || 'nenhuma'}", nome: "${file.originalname}". Extensões aceitas: ${allowedExtensions.join(', ')}`));
  },
}).single('image');

const uploadMultiple = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      const uploadType = req.body.type || 'portfolio';
      const typeDir = path.join(uploadDir, uploadType);
      if (!fs.existsSync(typeDir)) {
        fs.mkdirSync(typeDir, { recursive: true });
      }
      cb(null, typeDir);
    },
    filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const uploadType = req.body.type || 'portfolio';
      cb(null, `${uploadType}-${uniqueSuffix}${path.extname(file.originalname)}`);
    },
  }),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedExtensions = /\.(jpg|jpeg|png|gif|webp|bmp|svg|heic|heif|jfif|ico)$/i;
    const allowedMimeTypes = /^image\//i;
    
    const extname = path.extname(file.originalname).toLowerCase();
    const extValid = allowedExtensions.test(extname);
    const mimeValid = allowedMimeTypes.test(file.mimetype || '');

    console.log('=== VALIDAÇÃO DE ARQUIVO MÚLTIPLO ===');
    console.log('Nome do arquivo:', file.originalname);
    console.log('MIME type:', file.mimetype);
    console.log('Extensão:', extname);
    console.log('Extensão válida?', extValid);
    console.log('MIME válido?', mimeValid);
    console.log('=====================================');

    if (extValid || mimeValid) {
      console.log('✅ Arquivo múltiplo ACEITO');
      return cb(null, true);
    } else {
      console.log('❌ Arquivo múltiplo REJEITADO');
      cb(new Error(`Apenas imagens são permitidas! Recebido: MIME type "${file.mimetype || 'desconhecido'}", extensão "${extname || 'nenhuma'}"`));
    }
  },
}).array('images', 10);

class UploadController {
  async uploadProfileImage(req, res) {
    console.log('=== INÍCIO DO UPLOAD ===');
    console.log('Headers:', req.headers);
    console.log('Content-Type:', req.headers['content-type']);
    console.log('========================');
    
    uploadSingle(req, res, async (err) => {
      if (err) {
        console.error('❌ ERRO NO MULTER:', err.message);
        console.error('Stack:', err.stack);
        return res.status(400).json({
          success: false,
          error: err.message,
        });
      }

      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'Nenhuma imagem enviada',
        });
      }

      try {
        // Verificar se Cloudinary está configurado
        const useCloudinary = process.env.CLOUDINARY_CLOUD_NAME && 
                             process.env.CLOUDINARY_API_KEY && 
                             process.env.CLOUDINARY_API_SECRET;

        if (useCloudinary) {
          console.log('Fazendo upload para Cloudinary...');
          
          // Verificar se o arquivo existe
          if (!fs.existsSync(req.file.path)) {
            return res.status(400).json({
              success: false,
              error: 'Arquivo não encontrado após upload',
            });
          }

          // Fazer upload para Cloudinary usando o caminho do arquivo
          const uploadResult = await cloudinaryService.uploadImage(req.file.path, {
            folder: 'eliteworks/profiles',
            public_id: `profile_${Date.now()}_${Math.round(Math.random() * 1E9)}`,
          });

          console.log('Resultado do upload Cloudinary:', uploadResult.success ? 'Sucesso' : 'Falhou');

          // Deletar arquivo local temporário após upload
          try {
            if (fs.existsSync(req.file.path)) {
              fs.unlinkSync(req.file.path);
            }
          } catch (unlinkError) {
            console.warn('Aviso: Não foi possível deletar arquivo temporário:', unlinkError);
          }

          if (uploadResult.success) {
            return res.json({
              success: true,
              imageUrl: uploadResult.url,
              publicId: uploadResult.publicId,
            });
          } else {
            console.error('Erro no upload Cloudinary:', uploadResult.error);
            return res.status(500).json({
              success: false,
              error: uploadResult.error || 'Erro ao fazer upload para Cloudinary',
              details: uploadResult.details || null,
            });
          }
        } else {
          console.log('Usando armazenamento local (Cloudinary não configurado)');
          // Fallback: usar sistema local
          const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
          const imageUrl = `${baseUrl}/uploads/${req.file.filename}`;
          
          return res.json({
            success: true,
            imageUrl: imageUrl,
            filename: req.file.filename,
          });
        }
      } catch (error) {
        console.error('Erro ao processar upload:', error);
        
        // Tentar deletar arquivo local se existir
        if (req.file && req.file.path && fs.existsSync(req.file.path)) {
          try {
            fs.unlinkSync(req.file.path);
          } catch (unlinkError) {
            console.error('Erro ao deletar arquivo temporário:', unlinkError);
          }
        }

        return res.status(500).json({
          success: false,
          error: 'Erro ao processar upload da imagem: ' + error.message,
        });
      }
    });
  }

  async uploadMultipleImages(req, res) {
    uploadMultiple(req, res, async (err) => {
      if (err) {
        return res.status(400).json({
          success: false,
          error: err.message,
        });
      }

      if (!req.files || req.files.length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Nenhuma imagem enviada',
        });
      }

      try {
        // Verificar se Cloudinary está configurado
        const useCloudinary = process.env.CLOUDINARY_CLOUD_NAME && 
                             process.env.CLOUDINARY_API_KEY && 
                             process.env.CLOUDINARY_API_SECRET;

        if (useCloudinary) {
          // Fazer upload múltiplo para Cloudinary usando os caminhos dos arquivos
          const uploadType = req.body.type || 'portfolio';
          const filePaths = req.files.map(file => file.path);
          
          const uploadResult = await cloudinaryService.uploadMultipleImages(filePaths, {
            folder: `eliteworks/${uploadType}`,
            publicIdPrefix: uploadType,
          });

          // Deletar arquivos locais temporários
          req.files.forEach(file => {
            try {
              if (fs.existsSync(file.path)) {
                fs.unlinkSync(file.path);
              }
            } catch (unlinkError) {
              console.error('Erro ao deletar arquivo temporário:', unlinkError);
            }
          });

          if (uploadResult.success) {
            return res.json({
              success: true,
              imageUrls: uploadResult.urls,
              count: uploadResult.urls.length,
            });
          } else {
            return res.status(500).json({
              success: false,
              error: uploadResult.error || 'Erro ao fazer upload para Cloudinary',
            });
          }
        } else {
          // Fallback: usar sistema local
          const uploadType = req.body.type || 'portfolio';
          const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
          const imageUrls = req.files.map(file => `${baseUrl}/uploads/${uploadType}/${file.filename}`);
          
          return res.json({
            success: true,
            imageUrls: imageUrls,
            count: imageUrls.length,
          });
        }
      } catch (error) {
        console.error('Erro ao processar upload múltiplo:', error);
        
        // Tentar deletar arquivos locais se existirem
        if (req.files) {
          req.files.forEach(file => {
            try {
              if (file.path && fs.existsSync(file.path)) {
                fs.unlinkSync(file.path);
              }
            } catch (unlinkError) {
              console.error('Erro ao deletar arquivo temporário:', unlinkError);
            }
          });
        }

        return res.status(500).json({
          success: false,
          error: 'Erro ao processar upload das imagens: ' + error.message,
        });
      }
    });
  }
}

module.exports = new UploadController();

