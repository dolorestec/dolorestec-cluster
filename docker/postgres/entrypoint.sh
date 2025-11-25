#!/bin/bash

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
SERVICE_NAME="postgres"
SERVICE_VERSION="v0.1.0"
CONTAINER_NAME="dlrs-postgres"
IMAGE_NAME="dolorestec/postgres:v0.1.0"
SERVICE_PORT="5432"

# Banner: tenta imprimir /opt/postgres/banner.txt se existir
if [ -f /opt/postgres/banner.txt ]; then
  cat /opt/postgres/banner.txt || true
fi

# Log padronizado com cores e emojis
echo -e "${BLUE}🚀${NC} ${GREEN}Iniciando ${SERVICE_NAME} v${SERVICE_VERSION}${NC}"
echo -e "${CYAN}📊${NC} ${WHITE}Container: ${CONTAINER_NAME}${NC}"
echo -e "${MAGENTA}🏗️${NC} ${WHITE}Imagem: ${IMAGE_NAME}${NC}"
echo -e "${YELLOW}⚙️${NC} ${WHITE}Configurando ambiente...${NC}"

# Função para configurar o serviço (pode ser sobrescrita)
configure_service() {
  echo -e "${BLUE}🔧${NC} ${WHITE}Configuração padrão aplicada${NC}"
}

# Executa configuração específica do serviço
configure_service

echo -e "${GREEN}✅${NC} ${WHITE}${SERVICE_NAME} pronto para iniciar${NC}"
echo -e "${CYAN}🌐${NC} ${WHITE}Serviço disponível na porta ${SERVICE_PORT}${NC}"
echo ""

# Executa o comando como usuário postgres (não root)
exec su-exec postgres "$@"