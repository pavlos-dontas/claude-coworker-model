# Claude Coworker Model

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Offload bulk I/O from Claude Code to cheap LLMs. Save thousands of tokens on file reading, boilerplate generation, and doc updates. Worker calls cost ~$0.02; primary model focuses on architecture.

## Quick Start

```bash
git clone https://github.com/imkunal007219/claude-coworker-model.git
cd claude-coworker-model
./setup.sh

export WORKER_API_KEY="your-key"
export WORKER_BASE_URL="https://api.openai.com/v1"
export WORKER_MODEL="gpt-4o-mini"

ask-worker --paths src/*.py --question "Find all SQL injection risks"
```

## How It Works

The expensive model (Claude) handles reasoning and architecture. The cheap worker model handles token-heavy I/O:

1. **Read**: Worker ingests large codebases, returns structured summaries with file paths and line numbers
2. **Generate**: Worker produces boilerplate using existing files as style references  
3. **Extract**: Worker parses session transcripts for documentation

Pattern: Claude decides *what* to do; the worker does the *reading/writing*.

## Configuration

Three environment variables configure any OpenAI-compatible provider:

| Variable | Purpose | Example |
|----------|---------|---------|
| `WORKER_API_KEY` | API authentication | `sk-abc123` |
| `WORKER_BASE_URL` | Provider endpoint | `https://api.openai.com/v1` |
| `WORKER_MODEL` | Model identifier | `gpt-4o-mini` |

## Provider Examples

**OpenAI**
```bash
export WORKER_API_KEY="$OPENAI_API_KEY"
export WORKER_BASE_URL="https://api.openai.com/v1"
export WORKER_MODEL="gpt-4o-mini"
```

**OpenRouter** (access hundreds of models)
```bash
export WORKER_API_KEY="$OPENROUTER_API_KEY"
export WORKER_BASE_URL="https://openrouter.ai/api/v1"
export WORKER_MODEL="google/gemini-flash-1.5"
```

**DeepSeek**
```bash
export WORKER_API_KEY="$DEEPSEEK_API_KEY"
export WORKER_BASE_URL="https://api.deepseek.com/v1"
export WORKER_MODEL="deepseek-chat"
```

**Ollama (local)**
```bash
export WORKER_API_KEY="ollama"
export WORKER_BASE_URL="http://localhost:11434/v1"
export WORKER_MODEL="qwen2.5-coder:14b"
```

## Tools

### ask-worker
Delegate bulk reading to the worker model. Returns structured bullets, not prose.

```bash
# Analyze multiple files for security issues
ask-worker \
  --paths auth.py database.py utils.py \
  --question "Identify all unvalidated inputs" \
  --max-tokens 8192

# Generate API documentation from source
ask-worker \
  --paths src/**/*.ts \
  --question "List all exported functions with their arguments"
```

Flags:
- `--paths`: Files to ingest (supports globs)
- `--question`: Specific extraction query
- `--max-tokens`: Total budget including reasoning tokens
- `--model`: Override `WORKER_MODEL`

### worker-write
Generate code or documentation using an existing file as a style reference.

```bash
# Generate tests matching existing style
worker-write \
  --spec "Write pytest tests for auth.py covering OAuth2 flow" \
  --context tests/test_main.py \
  --target tests/test_auth.py

# Create API docs matching current format
worker-write \
  --spec "Document the new /v2/users endpoint" \
  --context docs/endpoints.md \
  --target docs/endpoints_v2.md
```

Flags:
- `--spec`: What to write (generation instructions)
- `--context`: Reference file to mimic (style, imports, structure)
- `--target`: Output file path
- `--max-tokens`: Token budget for reasoning + output (default 16384)

### extract-chat
Convert Claude Code JSONL session logs to human-readable text.

```bash
# Extract last session to stdout
extract-chat ~/.claude/projects/my-project/session.jsonl

# Write to file
extract-chat ~/.claude/projects/my-project/session.jsonl -o /tmp/chat.txt

# Pipe to ask-worker for doc updates
extract-chat session.jsonl -o /tmp/chat.txt && \
  ask-worker --paths /tmp/chat.txt docs/README.md --question "What doc updates are needed?"
```

## CLAUDE.md Setup

Copy `CLAUDE.md.template` to your project root as `CLAUDE.md`. This provides routing rules that tell Claude when to delegate:

```markdown
## Worker Delegation Rules

When asked to analyze, summarize, or search across multiple files:
DELEGATE to ask-worker with relevant file paths.

When asked to generate boilerplate, tests, or documentation:
DELEGATE to worker-write with appropriate reference files.

When asked to review session history:
DELEGATE to extract-chat.

DO NOT delegate:
- Architecture decisions
- Debugging complex logic
- Refactoring plans
```

Add `CLAUDE.md` to your repository so Claude Code loads it automatically on startup.

## Results

| Metric | Before | After |
|--------|--------|-------|
| Claude Pro weekly limit | Hit by Wednesday | Never hit |
| Token usage per session | 80%+ on file reading | 20% (summaries only) |
| 3-week worker API cost | — | $0.38 total |
| Context window usage | 80% reading files | 20% reading summaries |

Based on the pattern described in [this implementation (medium link)](https://medium.com/@kunalbhardwaj598/i-was-burning-through-claude-codes-weekly-limit-in-3-days-here-s-how-i-fixed-it-0344c555abda) [Reddit link](https://www.reddit.com/r/ClaudeAI/comments/1t1o43w/i_gave_claude_code_a_002call_coworker_and_stopped/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) (567K views Reddit, 7.2K Medium).

## Author

**Kunal Bhardwaj** — Systems engineer working on autonomous drones and AI-powered developer tools. Building at the intersection of embedded systems and LLM workflows.

- Blog: [medium.com/@kunalbhardwaj](https://medium.com/@kunalbhardwaj598/i-was-burning-through-claude-codes-weekly-limit-in-3-days-here-s-how-i-fixed-it-0344c555abda)
- LinkedIn: [linkedin.com/in/kunalbhardwaj](https://www.linkedin.com/in/kunal-bhardwaj-61433818b)

## Contributing

PRs welcome. Focus areas: additional provider templates, token usage optimization, and extracting structured data from more session formats.

MIT License. See [LICENSE](LICENSE).
