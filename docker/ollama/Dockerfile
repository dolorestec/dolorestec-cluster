### Estágio final: runtime mínimo baseado em Ollama
FROM ollama/ollama:latest AS runtime

# Labels para identificação
LABEL maintainer="Dolorestec Team"
LABEL description="Ollama AI Server com modelo qwen2.5-coder:1.5b"
LABEL version="latest"

# Configurações padrão
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434

CMD ["serve"]