---
type: Guide
title: Documentation guide
description: How to add a page to this bundle.
sources:
  - id: okf
    resource: https://github.com/open-knowledge-format/open-knowledge-format/blob/main/SPEC.md
    title: Open Knowledge Format specification
---

# Documentation guide

The `docs/` directory is one Open Knowledge Format (OKF) 0.3 bundle. OKF uses
one Markdown file per concept. A concept needs YAML frontmatter with a
non-empty `type`. Its path without `.md` is its ID. OKF reserves `index.md`
for navigation and `log.md` for optional change history.[^okf]

## Where to record a change

- New physical device or hardware upgrade: update [Equipment](equipment.md).
  Keep one row per device. Do not add VMs or Ansible connection settings to
  this file.
- Change in how you create or configure VMs: update the
  [Automation plan](automation.md). Keep plans distinct from equipment you own
  and procedures you have tested.
- Repeatable operation, such as restoring a VM: add a `Runbook` page after you
  test the steps. Include the condition for success.

## How to add a page

1. Choose a short, stable filename. Add `type`, `title`, and a one-sentence
   `description` to the YAML frontmatter. The last two fields are repository
   conventions, not OKF requirements.
2. Link to related pages with relative Markdown links. Keep each fact in one
   place. Add `sources` when a page relies on an external specification.
3. Add the page and its description to the [bundle index](index.md). Add a
   subdirectory with its own index only when several pages cover the same
   subject. Use Git for change history.
4. Run `mise install` to install the pinned tools. Stage your changes, then
   run `mise run check` before you commit. This checks Markdown and the OKF
   bundle. It also runs Betterleaks on staged changes and local Git history.
   The secret scan does not check unstaged changes or untracked files.
   To run only the secret scan, use `mise run lint:secrets`.

[^okf]: [Open Knowledge Format specification](https://github.com/open-knowledge-format/open-knowledge-format/blob/main/SPEC.md), sections 2 to 4, 6, 8, and 9.
