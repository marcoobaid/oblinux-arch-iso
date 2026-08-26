# CLAUDE.md — Claude Code entry point for oblinux-arch-iso-dev

**AGENTS.md is the authoritative repository operating guide. CLAUDE.md
supplements it for Claude Code and must not establish competing
repository policy.**

Before doing any work in this repository:

1. Read `AGENTS.md` in full, first.
2. Treat it as authoritative for repository role, architecture,
   ownership, Git safety, validation, and promotion rules — this file
   does not restate that content, and if anything here ever appears to
   conflict with it, `AGENTS.md` wins.
3. Follow its Agent start-of-task workflow, including reading the
   `docs/` file(s) it points to for the subsystem you're touching
   (Documentation Map) before making changes.

Non-negotiables, all defined in full in `AGENTS.md` — this is a pointer,
not a restatement:

- Never claim a build, boot, install, runtime, or visual test happened
  unless it actually did. This repo cannot self-verify builds/boots from
  macOS.
- Respect the boundaries between this repo (dev/staging), `oblinux-arch-iso`
  (stable), `oblinux-brand-master` (shared branding), and the legacy
  `oblinux` repo exactly as `AGENTS.md`'s Pipeline role and governance
  section defines them.
- Never force-push or rewrite published history unless `AGENTS.md`
  explicitly permits it and the owner has explicitly authorized that
  specific instance.
- Never promote dev changes into a stable repository without explicit
  owner approval — a successful dev build is not approval.
- Preserve this repo's actual architecture and conventions; don't carry
  over assumptions from another OBLinux repository.
- Consult the relevant `docs/` file(s) `AGENTS.md`'s Documentation Map
  points to before modifying the associated subsystem.

When in doubt, re-read `AGENTS.md` rather than guessing.

## Git commit policy

This policy applies to every Git commit Claude Code creates in this
repository, and it is not optional:

- Use only the repository's configured Git author identity. Never
  modify Git author/committer identity to represent Claude or
  Anthropic, and never add Claude or Anthropic as a contributor.
- Do not add `Co-Authored-By` trailers for Claude, Anthropic, or any AI
  system.
- Do not add `Generated-By`, `Assisted-By`, `AI-Generated`, or similar
  AI-attribution trailers.
- Do not mention Claude, Anthropic, Claude Code, AI assistance, or
  automated generation anywhere in the commit message.
- Do not add any attribution trailer unless the owner explicitly
  requests one for that specific commit.
- Write normal, professional commit messages that describe the actual
  repository change — nothing else.

Example — correct:

```
Integrate Brand Master v1.0.2
```

Example — incorrect:

```
Integrate Brand Master v1.0.2

Co-Authored-By: Claude Sonnet <noreply@anthropic.com>
```

The repository's configured human Git identity remains the sole commit
attribution unless the owner explicitly instructs otherwise. This is
consistent with, and reinforces, `AGENTS.md`'s Development Rules on AI
attribution — it does not add competing policy.
