# CLAUDE.md — Claude Code entry point for oblinux-arch-iso

**AGENTS.md is the authoritative repository operating guide. CLAUDE.md
supplements it for Claude Code and must not establish competing
repository policy.**

Before doing any work in this repository, read `AGENTS.md` in full and
follow it. It defines this repository's role (`oblinux-arch-iso` is the
**stable/production** OBLinux Arch implementation), the four-repository
architecture and promotion flow, ownership boundaries, Git safety rules,
validation requirements, and development rules. This file does not
repeat any of that — see `AGENTS.md` for the actual content.

Specifically, when working here:

- Treat every repository-role, architecture, ownership, validation,
  Git-safety, and promotion rule in `AGENTS.md` as binding.
- Never claim a build, runtime, VM, or visual/manual test was performed
  unless it actually was — see `AGENTS.md`'s Validation integrity
  section for how to report validation status honestly.
- Respect the boundaries between this stable repository,
  `oblinux-arch-iso-dev`, `oblinux-brand-master`, and the legacy
  `oblinux` repository exactly as `AGENTS.md` defines them — do not
  treat any of them as interchangeable.
- Never force-push or rewrite published Git history in this repository
  unless `AGENTS.md` explicitly permits it for the situation *and* the
  owner has explicitly authorized it for that specific case.
- Never promote development changes into this stable repository without
  explicit owner approval — a successful dev build or dev validation is
  never sufficient on its own.
- Preserve this repository's own documented architecture and decisions;
  don't assume behavior from another OBLinux repository applies here.
- Consult the specific `docs/` file `AGENTS.md`'s Documentation Map
  points to for the subsystem you're touching, rather than relying on
  summaries alone.

When in doubt, defer to `AGENTS.md` over anything above.

## Git commit policy

This policy applies to every commit Claude Code creates in this
repository:

- Use only the repository's configured Git author identity. Never
  modify Git author or committer identity to represent Claude or
  Anthropic, and never add Claude or Anthropic as a contributor.
- Do not add `Co-Authored-By` trailers for Claude, Anthropic, or any
  AI system.
- Do not add `Generated-By`, `Assisted-By`, `AI-Generated`, or similar
  AI-attribution trailers.
- Do not mention Claude, Anthropic, Claude Code, AI assistance, or
  automated generation anywhere in a commit message.
- Do not add attribution trailers of any kind unless the owner
  explicitly requests one for that specific commit.
- Write normal, professional commit messages that describe the actual
  repository change — nothing else.

For example, a commit should look like:

    Integrate Brand Master v1.0.2

and **not**:

    Integrate Brand Master v1.0.2

    Co-Authored-By: Claude Sonnet <noreply@anthropic.com>

The repository's configured human Git identity remains the sole commit
attribution unless the owner explicitly instructs otherwise. This is
consistent with, and does not override, `AGENTS.md`'s Development
Rules on never attributing an AI tool as author/contributor.
