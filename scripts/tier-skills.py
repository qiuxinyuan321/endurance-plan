#!/usr/bin/env python3
"""
Endurance Plan - Skill Tiering Script
Batch disable non-essential skills by setting manifest.json enabled=false.
Customizable Tier 1 list.
"""
import json
import os
import shutil
import sys
from datetime import datetime

SKILLS_DIR = os.path.expanduser("~/.claude/skills")
ARCHIVE_DIR = os.path.expanduser("~/.claude/skills-archive")

# Default Tier 1 skills (always-on). Customize as needed.
TIER1 = {
    # Coding core
    "unified-coding-agent", "writing-plans", "executing-plans",
    "verification-before-completion", "systematic-debugging",
    "smart-test-fixing", "create-pull-request",
    # Memory & Search
    "unified-memory-system", "auto-memory", "super-search",
    # Communication
    "unified-lark", "unified-github", "discord-official", "slack-official",
    # Productivity
    "unified-obsidian", "unified-productivity-agent", "summarize",
    # Tools
    "playwright", "pdf", "screenshot", "wsl-bridge",
    "windows-automation-unified", "skill-loader",
}


def backup_manifests():
    ts = datetime.now().strftime("%Y%m%d")
    backup_dir = os.path.join(ARCHIVE_DIR, f"pre-tiering-{ts}")
    os.makedirs(backup_dir, exist_ok=True)
    count = 0
    for entry in os.listdir(SKILLS_DIR):
        skill_dir = os.path.join(SKILLS_DIR, entry)
        manifest = os.path.join(skill_dir, "manifest.json")
        if os.path.isdir(skill_dir) and os.path.exists(manifest):
            dst = os.path.join(backup_dir, entry)
            os.makedirs(dst, exist_ok=True)
            shutil.copy2(manifest, os.path.join(dst, "manifest.json"))
            count += 1
    print(f"Backed up {count} manifests to {backup_dir}")
    return backup_dir


def tier_skills(dry_run=False):
    disabled = 0
    ensured = 0
    skipped = 0

    for entry in sorted(os.listdir(SKILLS_DIR)):
        skill_dir = os.path.join(SKILLS_DIR, entry)
        if not os.path.isdir(skill_dir) or entry.startswith("."):
            continue

        manifest_path = os.path.join(skill_dir, "manifest.json")
        is_tier1 = entry in TIER1

        if os.path.exists(manifest_path):
            with open(manifest_path, "r", encoding="utf-8") as f:
                data = json.load(f)
        else:
            data = {"name": entry, "version": "1.0.0"}

        if is_tier1:
            if data.get("enabled") is not True:
                data["enabled"] = True
                ensured += 1
                if not dry_run:
                    with open(manifest_path, "w", encoding="utf-8") as f:
                        json.dump(data, f, indent=2, ensure_ascii=False)
                    print(f"  [TIER1] {entry} -> enabled")
            else:
                skipped += 1
        else:
            if data.get("enabled") is not False:
                data["enabled"] = False
                disabled += 1
                if not dry_run:
                    with open(manifest_path, "w", encoding="utf-8") as f:
                        json.dump(data, f, indent=2, ensure_ascii=False)
                    print(f"  [TIER2] {entry} -> disabled")
            else:
                skipped += 1

    print(f"\nSummary: {ensured} ensured T1, {disabled} disabled T2, {skipped} unchanged")
    if dry_run:
        print("(dry run - no files modified)")


def main():
    dry_run = "--dry-run" in sys.argv
    skip_backup = "--no-backup" in sys.argv

    if not os.path.isdir(SKILLS_DIR):
        print(f"Skills directory not found: {SKILLS_DIR}")
        sys.exit(1)

    if not skip_backup and not dry_run:
        backup_manifests()

    print(f"\nTiering skills (Tier 1: {len(TIER1)} skills)...")
    tier_skills(dry_run)
    print("\nRestart Claude Code to apply changes.")


if __name__ == "__main__":
    main()
