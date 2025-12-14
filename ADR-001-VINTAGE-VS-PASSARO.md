# ADR-001: Escolha de Arquitetura - Vintage vs Pássaro

## Status
**ACEITO** - 14/12/2025

## Contexto
Precisávamos escolher entre duas arquiteturas para inferência LLM no edge:
- **Vintage**: C/WASM (linear, AOT-compiled, minimalista)
- **Pássaro**: Bend/HVM (paralelo, runtime-based, expressivo)

## Decisão
**Adotar Vintage (C/WASM) como arquitetura de produção principal.**

**Manter Pássaro (Bend/HVM) como branch experimental para pesquisa.**

## Dados da Decisão
### Benchmark (10 execuções cada):
- Vintage: 18.8 ± 2.5 ms (min 15, max 23)
- Pássaro: 31.0 ± 5.4 ms (min 26, max 46)
- **Vintage é 1.65× mais rápido**
- **Zero sobreposição**: Vintage max < Pássaro min

### Memória (estimativa arquitetural):
- Vintage: ~10 MB
- Pássaro: ~100 MB (10× mais)

### Consistência:
- Vintage venceu em TODAS as 10 execuções
- Diferença estatisticamente significativa (p < 0.001)

## Consequências
### Positivas:
- Performance previsível e consistente
- Baixo consumo de memória (ideal para edge)
- Cold start rápido (~20 ms)
- Custo operacional baixo
- Debug simplificado (determinístico)

### Negativas:
- Paralelismo limitado (apenas 1 núcleo)
- Expressividade de código menor (C vs Bend)
- Manutenção de branch experimental adicional

## Alternativas Consideradas
1. **Pássaro como principal**: Rejeitado devido a overhead (~1.65× mais lento)
2. **Arquitetura híbrida**: Adiado para workload > 500 tokens
3. **Ambos em produção**: Rejeitado por complexidade operacional

## Condições para Revisão
Esta decisão será reavaliada quando:
1. Workload médio > 500 tokens
2. Overhead HVM reduzido para < 1.3×
3. Pássaro for > 2× mais rápido em workload grande
4. Memória disponível > 1 GB por instância

## Próximos Passos
1. [ ] Completar implementação Vintage em produção
2. [ ] Otimizar WASM (quantização INT8, pruning)
3. [ ] Estabelecer branch experimental para Pássaro
4. [ ] Monitorar performance em produção real
5. [ ] Reavaliar em 3 meses com dados reais

## Referências
- Benchmark completo: `bench/results/`
- Código Vintage: `arch/model/tiny256k.c`
- Código Pássaro: `arch/model/bend256k.bend`
- Análise estatística: `FINAL_SIMPLE_REPORT.txt`
