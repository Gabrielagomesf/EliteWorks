const multer = require('multer');
const path = require('path');
const fs = require('fs');

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
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas!'));
    }
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
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas!'));
    }
  },
}).array('images', 10);

class UploadController {
  async uploadProfileImage(req, res) {
    uploadSingle(req, res, (err) => {
      if (err) {
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

      const imageUrl = `/uploads/${req.file.filename}`;
      
      res.json({
        success: true,
        imageUrl: imageUrl,
        filename: req.file.filename,
      });
    });
  }

  async uploadMultipleImages(req, res) {
    uploadMultiple(req, res, (err) => {
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

      const uploadType = req.body.type || 'portfolio';
      const imageUrls = req.files.map(file => `/uploads/${uploadType}/${file.filename}`);
      
      res.json({
        success: true,
        imageUrls: imageUrls,
        count: imageUrls.length,
      });
    });
  }
}

module.exports = new UploadController();

