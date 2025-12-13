
---

### 📄 `docs/DEVOPS_GUIDE.md`

```markdown
# 🛠️ DevOps Guide — gos3 Standard

> “Build once, run anywhere — even on a phone.”  
> — gos3 DevOps | 2025-12-13

## 🔄 Reproducibility Checklist
- [ ] `./setup.sh` idempotent
- [ ] `./check_deps.sh` pure validation
- [ ] No hardcoded paths
- [ ] All binaries in `arch/serve/`
- [ ] Weights excluded from git

## 📦 Distribution
```bash
tar -czf tiny-llm-offline-20251213.tar.gz arch/ backend/ frontend/ demo.py
