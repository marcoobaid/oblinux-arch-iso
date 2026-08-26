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

When in doubt, re-read `AGENTS.md` rather than guessing.
