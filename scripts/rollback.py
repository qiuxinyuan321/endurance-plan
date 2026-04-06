#!/usr/bin/env python3
"""
Endurance Plan - Rollback Skill Tiering
Restore all manifest.json from the most recent backup.
"""
import json
import os
import shutil
import sys

ARCHIVE_DIR = os.path.expanduser("~/.claude/skills-archive")
SKILLS_DIR = os.path.expanduser("~/.claude/skills")


def find_latest_backup():
    if not os.path.isdir(ARCHIVE_DIR):
        return None
    backups = [d for d in os.listdir(ARCHIVE_DIR) if d.startswith("pre-tiering-")]
    if not backups:
        return None
    return os.path.join(ARCHIVE_DIR, sorted(backups)[-1])


def rollback(backup_dir):
    restored = 0
    for entry in os.listdir(backup_dir):
        src = os.path.join(backup_dir, entry, "manifest.json")
        dst = os.path.join(SKILLS_DIR, entry, "manifest.json")
        if os.path.exists(src) and os.path.isdir(os.path.join(SKILLS_DIR, entry)):
            shutil.copy2(src, dst)
            restored += 1

    print(f"Restored {restored} manifest.json files from {backup_dir}")
    print("Restart Claude Code to apply changes.")


def main():
    backup_dir = sys.argv[1] if len(sys.argv) > 1 else find_latest_backup()
    if not backup_dir or not os.path.isdir(backup_dir):
        print("No backup found. Specify path: python rollback.py <backup_dir>")
        sys.exit(1)
    rollback(backup_dir)


if __name__ == "__main__":
    main()
