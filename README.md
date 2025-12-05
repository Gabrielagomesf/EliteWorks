# 🚀 EliteWorks

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/MongoDB-7.0+-47A248?logo=mongodb&logoColor=white" alt="MongoDB" />
  <img src="https://img.shields.io/badge/License-ISC-blue" alt="License" />
</div>

<br>

> **EliteWorks** é uma plataforma completa que conecta clientes aos melhores profissionais do mercado. Sistema gratuito e open-source com funcionalidades completas de agendamento, pagamentos, chat e avaliações.

---

## 🎯 Sobre o Projeto

EliteWorks é uma aplicação mobile desenvolvida em Flutter com backend Node.js/Express, que oferece uma solução completa para conectar clientes e profissionais autônomos. A plataforma permite que profissionais se cadastrem, exibam seus serviços e sejam encontrados por clientes que precisam de serviços diversos.

### Principais Diferenciais

- ✅ **100% Gratuito** - Sem taxas ou comissões
- ✅ **Interface Moderna** - Design limpo e intuitivo
- ✅ **Pagamento Integrado** - Mercado Pago com PIX e cartão
- ✅ **Chat em Tempo Real** - Comunicação direta entre cliente e profissional
- ✅ **Sistema de Avaliações** - Feedback para garantir qualidade
- ✅ **Notificações** - Acompanhamento em tempo real de serviços

---

## ✨ Funcionalidades

### 🔐 Autenticação e Usuários
- [x] Registro de usuários (Cliente e Profissional)
- [x] Login com JWT
- [x] Recuperação de senha por email
- [x] Perfil completo com edição de dados
- [x] Upload de foto de perfil
- [x] Gestão de dados bancários

### 👨‍💼 Profissionais
- [x] Cadastro completo com especialidade e categorias
- [x] Busca avançada com filtros (categoria, avaliação, preço, localização)
- [x] Perfil detalhado com portfólio e anúncios
- [x] Sistema de favoritos
- [x] Avaliações automáticas baseadas em reviews

### 📋 Serviços
- [x] Criação e solicitação de serviços
- [x] Controle de status (pendente, aceito, em andamento, concluído, cancelado)
- [x] Agendamento com data e hora
- [x] Histórico completo de serviços
- [x] Avaliação com upload de fotos
- [x] Geração de pagamentos

### 💰 Pagamentos
- [x] Integração completa com Mercado Pago
- [x] Pagamento PIX (QR Code e código copia-e-cola)
- [x] Pagamento com cartão de crédito/débito
- [x] Checkout completo e intuitivo
- [x] Histórico de pagamentos
- [x] Status em tempo real

### 💬 Mensagens
- [x] Sistema de conversas individuais
- [x] Chat em tempo real
- [x] Marcação de mensagens como lidas
- [x] Contador de mensagens não lidas
- [x] Notificações de novas mensagens

### 🔔 Notificações
- [x] Sistema completo de notificações
- [x] Notificações automáticas para mudanças de status
- [x] Alertas de novas mensagens e avaliações
- [x] Histórico de notificações
- [x] Marcar como lida / marcar todas como lidas

### ⭐ Avaliações e Reviews
- [x] Sistema de avaliação com estrelas
- [x] Comentários e reviews
- [x] Upload de fotos nas avaliações
- [x] Histórico de avaliações
- [x] Média de avaliações por profissional

### 📢 Anúncios
- [x] Criação e gestão de anúncios
- [x] Exibição de anúncios no perfil

---

## 🛠 Tecnologias

### Frontend (Flutter)
- **Flutter** 3.0+
- **Google Fonts** - Tipografia
- **HTTP** - Requisições API
- **Shared Preferences** - Armazenamento local
- **Image Picker** - Seleção de imagens
- **QR Flutter** - Geração de QR Codes
- **URL Launcher** - Abertura de links
- **App Links** - Deep linking

### Backend (Node.js)
- **Node.js** 18+
- **Express** - Framework web
- **MongoDB/Mongoose** - Banco de dados
- **JWT** - Autenticação
- **Bcrypt** - Hash de senhas
- **Multer** - Upload de arquivos
- **Nodemailer** - Envio de emails
- **Mercado Pago SDK** - Pagamentos
- **CORS** - Cross-origin requests

---

## 📁 Estrutura do Projeto

```
EliteWorks/
│
├── lib/                          # Código Flutter
│   ├── config/                   # Configurações
│   │   ├── api_config.dart
│   │   └── database_config.dart
│   ├── constants/                # Constantes
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   └── app_strings.dart
│   ├── models/                   # Modelos de dados
│   ├── screens/                  # Telas da aplicação
│   ├── services/                 # Serviços e repositories
│   ├── utils/                    # Utilitários
│   ├── widgets/                  # Componentes reutilizáveis
│   └── main.dart                 # Entry point
│
├── backend/                      # Backend Node.js
│   ├── src/
│   │   ├── config/               # Configurações
│   │   │   └── database.js
│   │   ├── controllers/          # Lógica de negócio
│   │   ├── models/               # Schemas MongoDB
│   │   ├── repositories/         # Camada de acesso a dados
│   │   ├── routes/               # Rotas da API
│   │   ├── middleware/           # Middlewares
│   │   ├── services/             # Serviços auxiliares
│   │   └── server.js             # Servidor Express
│   ├── uploads/                  # Arquivos enviados
│   ├── package.json
│   └── README.md
│
├── android/                      # Configurações Android
├── ios/                          # Configurações iOS
├── linux/                        # Configurações Linux
├── pubspec.yaml                  # Dependências Flutter
├── render.yaml                   # Configuração Render
└── README.md                     # Este arquivo
```

---

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Flutter SDK** 3.0 ou superior ([Instalação](https://docs.flutter.dev/get-started/install))
- **Node.js** 18 ou superior ([Download](https://nodejs.org/))
- **MongoDB** ou MongoDB Atlas ([MongoDB Atlas](https://www.mongodb.com/cloud/atlas))
- **Git** ([Download](https://git-scm.com/))
- **Conta Mercado Pago** (para pagamentos)

---

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/EliteWorks.git
cd EliteWorks
```

### 2. Instale as dependências do Backend

```bash
cd backend
npm install
```

### 3. Instale as dependências do Frontend

```bash
cd ..
flutter pub get
```

---

## ⚙️ Configuração

### Backend (.env)

Crie um arquivo `.env` na pasta `backend/` com as seguintes variáveis:

```env
# MongoDB
MONGODB_CONNECTION_STRING=sua_url_mongodb_aqui

# JWT
JWT_SECRET=seu_jwt_secret_super_seguro_aqui

# Email (Gmail)
GMAIL_USER=seu_email@gmail.com
GMAIL_APP_PASSWORD=sua_senha_app_aqui

# Mercado Pago
MERCADOPAGO_ACCESS_TOKEN=seu_token_mercadopago_aqui
MERCADOPAGO_WEBHOOK_URL=https://seu-dominio.com/api/payments/webhook

# Porta do servidor
PORT=3000

# Ambiente
NODE_ENV=development
```

#### Como obter as credenciais:

- **MongoDB**: Crie um cluster gratuito no [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) e copie a connection string
- **JWT_SECRET**: Gere uma string aleatória segura (ex: use `openssl rand -base64 32`)
- **Gmail**: Configure uma [Senha de App](https://support.google.com/accounts/answer/185833) no seu Google Account
- **Mercado Pago**: Obtenha suas credenciais no [Painel Mercado Pago](https://www.mercadopago.com.br/developers/panel)

### Frontend (.env)

Crie um arquivo `.env` na raiz do projeto Flutter:

```env
API_BASE_URL=http://localhost:3000
```

Para produção, use a URL do seu backend deployado:

```env
API_BASE_URL=https://seu-projeto.onrender.com
```

---

## 🏃 Como Executar

### Backend

```bash
cd backend

# Modo desenvolvimento (com auto-reload)
npm run dev

# Modo produção
npm start
```

O servidor estará rodando em `http://localhost:3000`

### Frontend

```bash
# Certifique-se de estar na raiz do projeto
flutter run
```

Para executar em um dispositivo específico:

```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em dispositivo específico
flutter run -d <device_id>
```

### Verificar saúde da API

Acesse: `http://localhost:3000/health`

Resposta esperada:
```json
{
  "status": "OK",
  "message": "EliteWorks API está funcionando"
}
```

---

## 🌐 Deploy

### Backend no Render

1. Crie uma conta no [Render](https://render.com)
2. Conecte seu repositório GitHub
3. Selecione a pasta `backend/` como root directory
4. Configure as variáveis de ambiente no painel do Render
5. O arquivo `render.yaml` já está configurado para deploy automático

### Frontend

O frontend Flutter pode ser compilado para:

- **Android**: `flutter build apk` ou `flutter build appbundle`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`

---

## 📡 API Endpoints

### Autenticação
- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Fazer login
- `GET /api/auth/me` - Obter dados do usuário logado

### Usuários
- `GET /api/users/:id` - Obter usuário por ID
- `PUT /api/users/:id` - Atualizar usuário
- `POST /api/upload/profile` - Upload foto de perfil

### Profissionais
- `GET /api/professionals` - Listar profissionais (com filtros)
- `GET /api/professionals/:id` - Obter profissional por ID
- `POST /api/professionals` - Criar perfil profissional
- `PUT /api/professionals/:id` - Atualizar profissional

### Serviços
- `GET /api/services` - Listar serviços
- `GET /api/services/:id` - Obter serviço por ID
- `POST /api/services` - Criar serviço
- `PUT /api/services/:id` - Atualizar serviço

### Pagamentos
- `POST /api/payments` - Criar pagamento
- `GET /api/payments` - Listar pagamentos
- `POST /api/payments/webhook` - Webhook Mercado Pago

### Mensagens
- `GET /api/messages` - Listar conversas
- `GET /api/messages/:userId` - Obter mensagens com usuário
- `POST /api/messages` - Enviar mensagem

### Notificações
- `GET /api/notifications` - Listar notificações
- `PUT /api/notifications/:id/read` - Marcar como lida
- `PUT /api/notifications/read-all` - Marcar todas como lidas

### Avaliações
- `POST /api/reviews` - Criar avaliação
- `GET /api/reviews/professional/:id` - Avaliações do profissional

### Favoritos
- `GET /api/favorites` - Listar favoritos
- `POST /api/favorites` - Adicionar favorito
- `DELETE /api/favorites/:id` - Remover favorito

---

## 📄 Licença

Este projeto está sob a licença ISC. Veja o arquivo `LICENSE` para mais detalhes.

---

## 📧 Contato

**Email**: eliteworkss1@gmail.com

---

## 🙏 Agradecimentos

Agradecemos a todos que contribuíram para este projeto e às comunidades open-source que tornaram este projeto possível.

---

<div align="center">
  <p>Desenvolvido com ❤️ para conectar profissionais e clientes</p>
  <p>⭐ Se este projeto te ajudou, considere dar uma estrela!</p>
</div>
