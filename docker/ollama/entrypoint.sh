# Banner: tenta imprimir /opt/ollama/banner.txt se existir
if [ -f /opt/ollama/banner.txt ]; then
  cat /opt/ollama/banner.txt || true
fi

# Função para garantir que o modelo esteja disponível
ensure_model() {
  echo "Verificando modelo qwen2.5-coder:1.5b..."

  # Inicia servidor temporário em background para baixar/criar modelo
  ollama serve &
  SERVER_PID=$!

  # Espera o servidor iniciar
  echo "Aguardando servidor Ollama iniciar..."
  for i in {1..30}; do
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
      echo "Servidor Ollama pronto!"
      break
    fi
    sleep 2
  done

  # Primeiro, baixa o modelo base se não existir
  if ! ollama list | grep -q "qwen2.5-coder:1.5b"; then
    echo "Baixando modelo base qwen2.5-coder:1.5b..."
    ollama pull qwen2.5-coder:1.5b
    if [ $? -ne 0 ]; then
      echo "Erro ao baixar modelo base qwen2.5-coder:1.5b"
      exit 1
    fi
  fi

  # Modelo analyst não será criado pois Modelfile não existe
  echo "Pulando criação do modelo analyst (Modelfile não encontrado)"

  # Para o servidor temporário
  kill $SERVER_PID 2>/dev/null || true
  wait $SERVER_PID 2>/dev/null || true
}

# Executa função de garantia do modelo
ensure_model

# Define OLLAMA_CONTEXT_LENGTH se não estiver definido
export OLLAMA_CONTEXT_LENGTH=${OLLAMA_CONTEXT_LENGTH:-32768}

# Executa o comando passado (serve por padrão)
exec ollama "$@"