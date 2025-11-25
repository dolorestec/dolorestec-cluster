FROM traefik:v3.6.2

# Labels para identificação
LABEL maintainer="Dolorestec Team"
LABEL description="Traefik Reverse Proxy - Custom Docker Image"

# Configurações padrão
COPY traefik.yml /etc/traefik/traefik.yml

# Comando padrão
CMD ["traefik"]