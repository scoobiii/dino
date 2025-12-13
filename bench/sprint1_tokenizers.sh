#!/bin/bash
echo ">>> Sprint 1: Criando tokenizers e testes paralelos"

# 1. Criar estrutura
mkdir -p src/tokenizers tests formal/lean4

# 2. Criar base.py
cat > src/tokenizers/base.py << 'EOF'
from abc import ABC, abstractmethod
from typing import List

class BaseTokenizer(ABC):
    @abstractmethod
    def tokenize(self, text: str) -> List[str]:
        pass
EOF

# 3. Criar bpe_fast.py
cat > src/tokenizers/bpe_fast.py << 'EOF'
from .base import BaseTokenizer
from typing import List

class BPEFastTokenizer(BaseTokenizer):
    def tokenize(self, text: str) -> List[str]:
        return text.split()
EOF

# 4. Criar teste Pytest
cat > tests/test_parallel_tokens.py << 'EOF'
import pytest
from concurrent.futures import ThreadPoolExecutor
from src.tokenizers.bpe_fast import BPEFastTokenizer

def test_parallel_tokenize():
    tokenizers = [BPEFastTokenizer() for _ in range(5)]
    text = "teste de tokenização paralelo"
    with ThreadPoolExecutor(max_workers=5) as executor:
        results = list(executor.map(lambda t: t.tokenize(text), tokenizers))
    for r in results:
        assert r == ["teste", "de", "tokenização", "paralelo"]
EOF

# 5. Rodar teste
pytest tests/test_parallel_tokens.py

