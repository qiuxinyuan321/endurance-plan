# Claim-Evidence Matrix

> Every number in README must appear here with its evidence status.

## Evidence Status Legend

| Tag | Meaning | README display |
|-----|---------|---------------|
| ✓ measured | Reproduced locally, command documented | Number as-is |
| ~ estimated | Derived from public data, not measured | Number with ~ prefix |
| † upstream | Quoted from upstream project, not verified | Number with † suffix |
| ✗ unverified | No evidence | Must not appear in README |

## Claims

| # | Claim | Location | Method | Evidence | Notes |
|---|-------|----------|--------|----------|-------|
| C01 | RTK 60-97% compression | Component table | ✓ measured (single workload) | `benchmark/results/rtk.json` | 121K→3.6K on one test; range needs corpus |
| C02 | LLMLingua 2-5x input compression | Component table | † upstream | [LLMLingua paper](https://github.com/microsoft/LLMLingua) | Not independently measured |
| C03 | Skill tiering saves ~8K tokens/turn | Component table | ~ estimated | Derived: 181 skills ~10K → 23 skills ~2K | Need to measure actual system prompt diff |
| C04 | Model routing ~60% cost savings | Component table | ~ estimated | Based on Opus vs Sonnet/Haiku public pricing | Cannot measure directly without billing API |
| C05 | Thinking budget ~50% savings | Component table | ~ estimated | effortLevel high vs max | Cannot measure directly |
| C06 | Hook test filter 90%+ compression | Component table | ~ estimated | Qualitative: "most test output is pass lines" | Need measured corpus |
| C07 | Platform: Win / Mac / Linux | Badge | ✗ unverified | RTK only has Windows binary | **Must fix**: change to Win ✓ / Mac-Linux partial |

## Action Items

1. **C01**: Run RTK across corpus (3+ workloads), compute mean ± stddev
2. **C02**: Install LLMLingua, run on file_read corpus, measure actual compression
3. **C03**: Capture system prompt with all skills vs Tier1 only, diff token count
4. **C06**: Capture test output before/after filter hook, measure reduction
5. **C07**: Fix README badge to reflect actual platform support
