# Dolorestec Cluster - Infra Docker Moderna

Este projeto configura uma infraestrutura Docker completa e moderna para aplicações Dolorestec, incluindo PostgreSQL, Redis, RabbitMQ, OpenWebUI e GitHub Runner para CI/CD local.

## Serviços

- **PostgreSQL 18**: Banco de dados relacional usando imagem customizada `dlrs-postgres:v18`.
- **Redis 8.0**: Cache e armazenamento de sessões usando imagem customizada `dlrs-redis:v8.0` com autenticação.
- **RabbitMQ 4.0**: Message broker usando imagem customizada `dlrs-rabbitmq:v4.0` com management plugin.
- **OpenWebUI v0.6.36**: Interface web para IA usando imagem customizada `dlrs-openwebui:v0.6.36`, integrada com PostgreSQL e Redis.
- **GitHub Runner**: Runner local para CI/CD usando imagem customizada `dlrs-github-runner:latest`.

## Melhorias Implementadas

### ✅ Conformidade com Melhores Práticas Docker 2025
- **Imagens Customizadas**: Prefixo `dlrs-` no Docker Hub com versionamento semântico
- **Segurança**: Usuários não-root (exceto RabbitMQ que requer root), senhas via .env
- **Healthchecks**: Verificações automatizadas para todos os serviços
- **Restart Policies**: Configuração `unless-stopped` para reinício automático
- **Dependências Condicionais**: Serviços só iniciam quando dependências estão saudáveis
- **Rede Isolada**: Rede bridge dedicada para comunicação segura
- **Volumes Nomeados**: Persistência de dados com volumes Docker

### 🔒 Segurança Aprimorada
- **Secrets Management**: Variáveis de ambiente para credenciais sensíveis
- **Non-root Containers**: Usuários dedicados para execução
- **Vulnerability Scanning**: Trivy integrado no CI para detecção de vulnerabilidades
- **SBOM**: Software Bill of Materials gerado automaticamente
- **Provenance**: Attestations de build para rastreabilidade

### 🚀 CI/CD Automatizado
- **GitHub Actions**: Pipeline completo para build e push de imagens
- **Matrix Builds**: Build paralelo de todas as imagens customizadas
- **Cache de Build**: Aceleração com GitHub Actions cache
- **Security Scanning**: Upload automático de resultados para GitHub Security tab
- **Multi-platform**: Suporte a múltiplas arquiteturas via Buildx

### 📊 Monitoramento e Observabilidade
- **Healthchecks**: Verificação contínua da saúde dos serviços
- **Logs Centralizados**: Configuração de logging driver
- **Métricas**: Preparado para integração com Prometheus/Grafana

## Pré-requisitos

- Docker 24+
- Docker Compose 3.9+
- GitHub Repository com secrets configurados:
  - `DOCKERHUB_USERNAME`: Nome de usuário do Docker Hub
  - `DOCKERHUB_TOKEN`: Token de acesso do Docker Hub

## Como usar

1. **Configurar Secrets no GitHub**:
   - Acesse Settings > Secrets and variables > Actions
   - Adicione `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`

2. **Iniciar a Infraestrutura**:
   ```bash
   docker-compose up -d
   ```

3. **Verificar Status**:
   ```bash
   docker-compose ps
   ```

4. **Acessar Serviços**:
   - OpenWebUI: http://localhost:8080
   - RabbitMQ Management: http://localhost:15672 (user: rabbitmq_user, pass: rabbitmq_secure_pass_789)

## CI/CD Pipeline

O pipeline GitHub Actions executa automaticamente:

1. **Build**: Compila todas as imagens customizadas
2. **Push**: Envia para Docker Hub com tags apropriadas
3. **Security Scan**: Executa Trivy para detecção de vulnerabilidades
4. **SBOM**: Gera Software Bill of Materials
5. **Attestations**: Cria provenance para rastreabilidade

### Triggers
- Push para `main` com mudanças em `docker/` ou workflow
- Pull requests para `main`

### Imagens Geradas
- `lucascantarelli/dlrs-postgres:v18`
- `lucascantarelli/dlrs-redis:v8.0`
- `lucascantarelli/dlrs-rabbitmq:v4.0`
- `lucascantarelli/dlrs-openwebui:v0.6.36`
- `lucascantarelli/dlrs-github-runner:latest`

## Desenvolvimento Local

### Build Manual das Imagens
```bash
# PostgreSQL
docker build -t dlrs-postgres:v18 ./docker/postgres

# Redis
docker build -t dlrs-redis:v8.0 ./docker/redis

# RabbitMQ
docker build -t dlrs-rabbitmq:v4.0 ./docker/rabbitmq

# OpenWebUI
docker build -t dlrs-openwebui:v0.6.36 ./docker/openwebui

# GitHub Runner
docker build -t dlrs-github-runner:latest ./docker/github-runner
```

### Testes
```bash
# Validar configuração
docker-compose config

# Executar testes de saúde
docker-compose up -d
docker-compose ps
```

## Volumes

- `postgres_data`: Dados do PostgreSQL
- `redis_data`: Dados do Redis
- `rabbitmq_data`: Dados do RabbitMQ
- `openwebui_data`: Configurações e dados do OpenWebUI
- `github_runner_data`: Dados do GitHub Runner

## Troubleshooting

### Problemas Comuns
1. **GitHub Runner não conecta**: Verificar `GITHUB_RUNNER_TOKEN` no .env
2. **RabbitMQ falha**: Remover USER não-root se necessário
3. **Build falha**: Verificar logs do GitHub Actions

### Logs
```bash
# Logs de todos os serviços
docker-compose logs

# Logs específicos
docker-compose logs postgres
```

## Roadmap

- [ ] Integração com Prometheus/Grafana
- [ ] Backup automatizado dos volumes
- [ ] Multi-platform builds (ARM64)
- [ ] Testes automatizados das imagens
- [ ] Configuração de resource limits

---

**Mantido pela equipe Dolorestec** | Docker 2025 Best Practices Compliant