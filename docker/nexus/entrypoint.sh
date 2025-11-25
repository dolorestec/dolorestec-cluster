#!/bin/sh

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variáveis específicas do serviço
SERVICE_NAME="nexus"
SERVICE_VERSION="v0.1.0"
CONTAINER_NAME="dlrs-nexus"
IMAGE_NAME="dolorestec/nexus:v0.1.0"
SERVICE_PORT="8081"

# Banner: tenta imprimir /opt/nexus/banner.txt se existir
if [ -f /opt/nexus/banner.txt ]; then
  cat /opt/nexus/banner.txt || true
fi

# Log padronizado com cores e emojis
echo -e "${BLUE}🚀${NC} ${GREEN}Iniciando ${SERVICE_NAME} v${SERVICE_VERSION}${NC}"
echo -e "${CYAN}📊${NC} ${WHITE}Container: ${CONTAINER_NAME}${NC}"
echo -e "${MAGENTA}🏗️${NC} ${WHITE}Imagem: ${IMAGE_NAME}${NC}"
echo -e "${YELLOW}⚙️${NC} ${WHITE}Configurando ambiente...${NC}"

# Função genérica para criar repositórios a partir de templates
create_repositories_from_templates() {
  local format=$1
  local emoji=$2
  local description=$3
  
  echo -e "${BLUE}$emoji${NC} ${WHITE}$description${NC}"
  
  # Processar todos os templates do formato especificado
  for template in /opt/sonatype/nexus/repositories/${format}-*.json; do
    if [ -f "$template" ]; then
      repo_type=$(basename "$template" | sed "s/${format}-\(.*\)\.json/\1/")
      case $repo_type in
        proxy)
          endpoint="${format}/proxy"
          ;;
        hosted)
          endpoint="${format}/hosted"
          ;;
        group)
          endpoint="${format}/group"
          ;;
        hub-proxy)
          endpoint="${format}/proxy"
          ;;
        *)
          echo -e "${YELLOW}⚠️${NC} ${WHITE}Tipo de repositório desconhecido: $repo_type${NC}"
          continue
          ;;
      esac
      
      echo -e "${CYAN}📄${NC} ${WHITE}Aplicando template: $(basename "$template")${NC}"
      response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST -H "Content-Type: application/json" \
        -u "admin:${NEXUS_PASSWORD}" \
        "http://localhost:8081/service/rest/v1/repositories/$endpoint" \
        --data-binary @"$template")
      http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
      body=$(echo "$response" | sed '/HTTP_CODE:/d')
      if [ "$http_code" -eq 201 ] || [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✅${NC} ${WHITE}Template aplicado com sucesso${NC}"
      else
        echo -e "${RED}❌${NC} ${WHITE}Falha ao aplicar template (HTTP $http_code): $body${NC}"
      fi
    fi
  done
}

# Função para criar repositórios Docker
create_docker_repositories() {
  create_repositories_from_templates "docker" "🐳" "Criando repositórios Docker..."
}

# Função para criar repositórios Python
create_python_repositories() {
  create_repositories_from_templates "pypi" "🐍" "Criando repositórios Python..."
}

# Função para criar repositórios npm
create_npm_repositories() {
  create_repositories_from_templates "npm" "⚛️" "Criando repositórios npm..."
}

# Função para configurar o serviço (pode ser sobrescrita)
configure_service() {
  echo -e "${BLUE}🔧${NC} ${WHITE}Configurando senha do admin...${NC}"
  
  # Inicia o processo de alteração de senha em background
  (
    # Aguarda o Nexus inicializar
    echo -e "${YELLOW}⏳${NC} ${WHITE}Aguardando Nexus ficar pronto...${NC}"
    while ! curl -s http://localhost:8081/service/rest/v1/status/check > /dev/null; do
      sleep 5
    done
    echo -e "${GREEN}✅${NC} ${WHITE}Nexus pronto${NC}"
    
    # Tenta alterar a senha via API
    if [ -f /nexus-data/admin.password ]; then
      ADMIN_PASSWORD=$(cat /nexus-data/admin.password)
      echo -e "${YELLOW}🔑${NC} ${WHITE}Alterando senha do admin via API...${NC}"
      
      # Tenta alterar a senha
      curl -s -X PUT -H "Content-Type: application/json" \
        -u "admin:${ADMIN_PASSWORD}" \
        "http://localhost:8081/service/rest/v1/security/users/admin/change-password" \
        -d "{\"password\": \"${NEXUS_PASSWORD}\"}" && \
      echo -e "${GREEN}✅${NC} ${WHITE}Senha alterada com sucesso${NC}" || \
      echo -e "${RED}❌${NC} ${WHITE}Falha ao alterar senha${NC}"
    fi
    
    # Aguarda a senha ser alterada
    echo -e "${YELLOW}⏳${NC} ${WHITE}Verificando nova senha...${NC}"
    while ! curl -s -u "admin:${NEXUS_PASSWORD}" http://localhost:8081/service/rest/v1/repositories > /dev/null; do
      sleep 2
    done
    echo -e "${GREEN}✅${NC} ${WHITE}Senha verificada${NC}"
    
    echo -e "${BLUE}📦${NC} ${WHITE}Configurando repositórios...${NC}"
    
    # Criar repositórios Docker
    create_docker_repositories
    
    # Criar repositórios Python
    create_python_repositories
    
    # Criar repositórios npm (React)
    create_npm_repositories
    
    echo -e "${GREEN}✅${NC} ${WHITE}Repositórios configurados${NC}"
  ) &
}

# Executa configuração específica do serviço
configure_service

echo -e "${GREEN}✅${NC} ${WHITE}${SERVICE_NAME} pronto para iniciar${NC}"
echo -e "${CYAN}🌐${NC} ${WHITE}Serviço disponível na porta ${SERVICE_PORT}${NC}"
echo ""

# Executa o comando passado (serviço específico por padrão)
exec "$@"