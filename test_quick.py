# test_quick.py
from wasmer import engine, Store, Module, Instance
from wasmer_compiler_cranelift import Compiler

store = Store(engine.JIT(Compiler))
with open('arch/serve/llm.wasm', 'rb') as f:
    module = Module(store, f.read())

instance = Instance(module)

# Teste simples
tokens = [1, 42, 2]  # <s> hello </s>
ptr = instance.exports.alloc(len(tokens))

mem = instance.exports.memory.uint32_view(offset=ptr)
for i, tok in enumerate(tokens):
    mem[i] = tok

result = instance.exports.forward(ptr, len(tokens))
print(f"✅ Input: [1, 42, 2] → Output: token_{result}")
