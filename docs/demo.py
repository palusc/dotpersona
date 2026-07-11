#!/usr/bin/env python3
"""Controlled, faithful re-creation of a `/persona` session for the demo GIF.

Rendered by docs/demo.tape via VHS so the recording has stable timing and
type — it mirrors the real plugin's output (see skills/persona/SKILL.md and
the Roster in README.md) rather than driving a live Claude Code session.
"""
import sys
import time

R = "\033[0m"; B = "\033[1m"; DIM = "\033[2m"
CY = "\033[36m"; MG = "\033[35m"; GR = "\033[32m"
YL = "\033[33m"; RD = "\033[31m"; BL = "\033[34m"; GY = "\033[90m"


def out(s=""):
    sys.stdout.write(s)
    sys.stdout.flush()


def line(s="", pause=0.0):
    out(s + "\n")
    if pause:
        time.sleep(pause)


# group label -> [(name, bullet color, one-line essence)]
GROUPS = [
    ("Core roles", [
        ("The Architect",  MG, "Designs systems that survive contact with reality."),
        ("The Designer",   CY, "Understands the system before touching a pixel."),
        ("The Shipper",    GR, "Momentum over ceremony — small, verified steps."),
        ("The Auditor",    RD, "Assumes code is guilty until proven correct."),
        ("The DBA",        YL, "Query plans, indexing, zero-downtime migrations."),
        ("The Tester",     GR, "Hunts edge-cases; writes robust test suites."),
        ("The Wordsmith",  BL, "Punchy docs, UI copy, and clean logs."),
        ("The Researcher", CY, "Chases evidence over vibes."),
        ("The Strategist", MG, "One decision, and a reason to believe it."),
        ("The Product Manager", BL, "Turns a vague ask into a spec, not a wish."),
    ]),
    ("Domain leads", [
        ("The Backend Lead",  YL, "Data models, APIs, idempotency, boring reliability."),
        ("The Frontend Lead", CY, "Component architecture, state, a11y by default."),
        ("The Data Lead",     GR, "Pipelines, schemas, is-this-metric-even-right."),
        ("The DevOps Lead",   RD, "Deploys, observability, the 3am-pager mindset."),
    ]),
    ("Specialists", [
        ("The Growth Hacker",   GR, "The one metric that actually moves the business."),
        ("The Copywriter",      BL, "Words that convert; cuts your draft in half."),
        ("The Legal Reviewer",  YL, "ToS, privacy, licensing — can we ship this."),
        ("The Interviewer",     MG, "Pressure-tests a plan until only truth survives."),
        ("The Teacher",         CY, "Explains it so you understand, not just copy."),
    ]),
]

TOTAL = sum(len(members) for _, members in GROUPS)


def show_list():
    line()
    line(f"  {B}The roster{R} {DIM}— {TOTAL} senior specialists{R}", 0.15)
    for label, members in GROUPS:
        line()
        line(f"  {DIM}{label}{R}", 0.10)
        for name, col, essence in members:
            line(f"  {col}●{R}  {B}{name:<20}{R} {DIM}{essence}{R}", 0.05)
    line()


def adopt_auditor():
    line()
    line(f"  {RD}—{R} {B}The Auditor{R}. I'll assume this code is guilty "
         f"until I prove it correct.", 0.2)
    line()
    line(f"  {DIM}skills{R}   code-checkup · security-review · grill-me", 0.12)
    line(f"  {DIM}method{R}   recon → hunt → prove with a repro → scoped fix", 0.12)
    line(f"  {DIM}try{R}      {CY}/persona auditor server.js{R}", 0.12)
    line()


def drop():
    line()
    line(f"  {DIM}Dropped the persona. Back to default Claude.{R}", 0.15)
    line()


def header():
    line()
    line(f"  {MG}🎭{R}  {B}persona{R} {DIM}·{R} {GY}Claude Code plugin{R}")
    line(f"  {DIM}────────────────────────────────────────────{R}")
    line(f"  {DIM}Summon the right expert with one command.{R}")
    line()


PROMPT = f"  {MG}🎭{R} {CY}❯{R} "


def main():
    header()
    while True:
        try:
            cmd = input(PROMPT).strip()
        except (EOFError, KeyboardInterrupt):
            break
        if cmd in ("exit", "quit"):
            break
        if cmd.startswith("/persona list"):
            show_list()
        elif cmd.startswith("/persona off"):
            drop()
        elif cmd.startswith("/persona"):
            adopt_auditor()
        elif cmd:
            line(f"  {DIM}unknown command: {cmd}{R}")


if __name__ == "__main__":
    main()
