FROM traefik:v3.1

# Labels para identificação
LABEL maintainer="Dolorestec Team"
LABEL description="Traefik Reverse Proxy - Custom Docker Image"
LABEL version="v3.1"

# Configurações padrão
COPY traefik.yml /etc/traefik/traefik.yml

# Comando padrão
CMD ["traefik"]