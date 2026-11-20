#!/bin/sh
# Stand-in for a coding agent in the demo recording: prints a short
# conversation and writes PLAN.md step by step, replacing the file atomically
# on every step like real agents do.

set -eu

plan=$PWD/PLAN.md
step() { sleep "${DEMO_STEP:-2}"; }

write_plan() {
  tmp=$(mktemp "$PWD/.plan.XXXXXX")
  cat > "$tmp"
  mv "$tmp" "$plan"
}

link() { printf '\033]8;;file://%s\033\\%s\033]8;;\033\\' "$1" "$2"; }

printf '\033[2m› Plan the relaunch of our docs site\033[0m\n\n'
printf '● Writing the plan to %s\n' "$(link "$plan" PLAN.md)"

write_plan <<'EOF'
# Docs site relaunch

Status: **draft**

## Goals

- Faster search
- One place for guides and API reference
EOF
step

printf '● Adding milestones\n'
write_plan <<'EOF'
# Docs site relaunch

Status: **draft**

## Goals

- Faster search
- One place for guides and API reference

## Milestones

| Week | Milestone | Owner |
|---|---|---|
| 1 | Content audit | Docs team |
| 2 | New navigation | Design |
| 3 | Search index | Platform |
| 4 | Launch | Everyone |
EOF
step

printf '● Adding tasks and the rollout flow\n'
write_plan <<'EOF'
# Docs site relaunch

Status: **ready for review**

## Goals

- Faster search
- One place for guides and API reference

## Milestones

| Week | Milestone | Owner |
|---|---|---|
| 1 | Content audit | Docs team |
| 2 | New navigation | Design |
| 3 | Search index | Platform |
| 4 | Launch | Everyone |

## Tasks

- [x] Collect existing pages
- [x] Draft the new navigation
- [ ] Build the search index
- [ ] Redirect old URLs

## Rollout

```mermaid
flowchart LR
  Audit --> Navigation --> Search --> Launch
```
EOF
printf '\n● Plan ready: %s\n' "$(link "$plan" PLAN.md)"
