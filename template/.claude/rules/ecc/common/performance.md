# Performance Optimization

## Model Selection Strategy

**Haiku 4.5** (90% of Sonnet capability, 3x cost savings):
- Lightweight agents with frequent invocation
- Pair programming and code generation
- Worker agents in multi-agent systems

**Sonnet 4.6** (Best coding model):
- Main development work
- Orchestrating multi-agent workflows
- Complex coding tasks

**Opus 4.7** (Deepest reasoning):
- Complex architectural decisions
- Maximum reasoning requirements
- Research and analysis tasks

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Extended Thinking + Plan Mode

Extended thinking is enabled by default, reserving up to 31,999 tokens for internal reasoning.

Control extended thinking via:
- **Toggle**: Option+T (macOS) / Alt+T (Windows/Linux)
- **Config**: Set `effortLevel: "low" | "medium" | "high" | "xhigh"` in settings.json (v2.1.68+, `"xhigh"` added in v2.1.111 for Opus 4.7, default `"high"`)
- **Verbose mode**: Ctrl+O to see thinking output
- **Display summaries**: Set `showThinkingSummaries: true` in settings.json (v2.1.89+, display-only)
- **No-flicker mode**: `CLAUDE_CODE_NO_FLICKER=1` — チラつきなし alt-screen レンダリング（v2.1.91+）

For complex tasks requiring deep reasoning:
1. Ensure extended thinking is enabled (on by default)
2. Enable **Plan Mode** for structured approach
3. Use multiple critique rounds for thorough analysis
4. Use split role sub-agents for diverse perspectives

### スキル単位の effort 上書き (v2.1.80+)

SKILL.md の frontmatter で個別スキルの effort を指定可能:

```yaml
effort: low   # このスキル実行時は low に固定
```

軽量なユーティリティ系スキルに `low` を指定するとコスト削減になる。

SKILL.md のコンテンツ内では `${CLAUDE_EFFORT}` 変数で現在の effort レベル（`low`/`medium`/`high`/`xhigh`）を参照可能（v2.1.120+）。
effort に応じてスキルの動作を切り替えたい場合に使用する。

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix
