# EliteWorks Backend API

Backend separado para a aplicação EliteWorks usando Node.js, Express e MongoDB.

## Estrutura do Projeto

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # Configuração do MongoDB
│   ├── models/
│   │   ├── User.js              # Model de Usuário
│   │   ├── Professional.js      # Model de Profissional
│   │   ├── Service.js           # Model de Serviço
│   │   └── PasswordResetToken.js # Model de Token de Reset
│   ├── repositories/
│   │   ├── userRepository.js    # Operações de usuário
│   │   ├── professionalRepository.js # Operações de profissional
│   │   ├── serviceRepository.js # Operações de serviço
│   │   └── passwordResetTokenRepository.js # Operações de token
│   ├── controllers/
│   │   ├── authController.js    # Autenticação
│   │   ├── userController.js   # Usuários
│   │   └── professionalController.js # Profissionais
│   ├── middleware/
│   │   └── auth.js              # Middleware de autenticação
│   ├── routes/
│   │   ├── authRoutes.js        # Rotas de autenticação
│   │   ├── userRoutes.js        # Rotas de usuário
│   │   └── professionalRoutes.js # Rotas de profissional
│   └── server.js                # Servidor principal
├── .env.example                 # Exemplo de variáveis de ambiente
├── package.json
└── README.md
```

## Instalação

1. Instale as dependências:
```bash
npm install
```

2. Configure as variáveis de ambiente:
```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais:
```
PORT=3000
MONGODB_CONNECTION_STRING=mongodb+srv://usuario:senha@cluster.mongodb.net/database
JWT_SECRET=seu_jwt_secret_aqui
GMAIL_USERNAME=seu_email@gmail.com
GMAIL_APP_PASSWORD=sua_senha_app
```

## Executar

### Modo Desenvolvimento
```bash
npm run dev
```

### Modo Produção
```bash
npm start
```

## Endpoints

### Autenticação
- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Fazer login

### Usuários
- `GET /api/users/profile` - Buscar perfil (requer autenticação)
- `PUT /api/users/profile` - Atualizar perfil (requer autenticação)
- `DELETE /api/users/account` - Deletar conta (requer autenticação)

### Profissionais
- `GET /api/professionals/search` - Buscar profissionais
- `GET /api/professionals/featured` - Profissionais em destaque
- `GET /api/professionals/:id` - Buscar profissional por ID

## Autenticação

Use o token JWT no header:
```
Authorization: Bearer <token>
```


