## Description

Please describe the purpose of this Pull Request. If you are adding or updating a persona, please fill in the section below.

### Persona Contribution Details (If applicable)

- **Persona Name:** The ...
- **Essence (one line):** ...
- **The Opinionation Test:** What is the specific line/belief this persona holds that a generalist wouldn't? (A rule that changes the outcome)
  > e.g. "I refuse to say 'done' on a change I haven't seen actually run."

## Verification

Please describe how you verified these changes. If this is a persona contribution, include the exact command you ran and a short snippet or screenshot of the output.
- **Commands run:** `/persona <slug> <task>`
- **Behavior difference compared to default Claude:** ...

## Checklist

- [ ] I have read the [CONTRIBUTING.md](CONTRIBUTING.md) guidelines.
- [ ] I created a dedicated feature branch for this change (e.g., `feat/add-role` or `fix/issue-name`) and did not push directly to `main`.
- [ ] My changes pass local validations (`bash scripts/validate-personas.sh`).
- [ ] All shell scripts pass local linting (`shellcheck --severity=style --shell=bash install.sh scripts/*.sh tests/*.sh`).
- [ ] I ran the automated export integration tests and they passed (`bash tests/test-export.sh`).
- [ ] If contributing a persona:
  - [ ] Added version field in frontmatter (set to `1.0.0` for new, or bumped appropriately if modified).
  - [ ] Added to `plugin.json`'s skills array.
  - [ ] Added to the roster table in `skills/persona/SKILL.md`.
  - [ ] Added a line in `CHANGELOG.md` under `[Unreleased]`.
