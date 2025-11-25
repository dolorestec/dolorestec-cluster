FROM sonatype/nexus3:3.86.2-alpine

LABEL maintainer="Dolorestec Team" \
      version="v0.1.0" \
      description="Nexus Repository custom image for Dolorestec"

# Copiar script de inicialização
COPY entrypoint.sh /opt/sonatype/nexus/entrypoint.sh

# Copiar templates de repositórios
COPY repositories/ /opt/sonatype/nexus/repositories/

# Expor porta
EXPOSE 8081

# Definir entrypoint
ENTRYPOINT ["/opt/sonatype/nexus/entrypoint.sh"]

# Comando padrão
CMD ["/opt/sonatype/nexus/bin/nexus", "run"]