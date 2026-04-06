#!/usr/bin/env python
"""Endurance Plan - Hook Golden Test Runner
Runs all hook test cases and reports pass/fail.
"""
import json
import subprocess
import sys
import os

HOOKS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(os.path.dirname(HOOKS_DIR))  # benchmark/hook-tests → benchmark → project root
REPO_HOOKS = os.path.join(PROJECT_DIR, "hooks")

TESTS = [
    {
        "hook": os.path.join(REPO_HOOKS, "safety-guard.py"),
        "cases": [
            {"file": "safety-guard/allow.jsonl", "expected_decision": None},       # passthrough = no decision
            {"file": "safety-guard/deny.jsonl", "expected_decision": "deny"},
            {"file": "safety-guard/ask.jsonl", "expected_decision": "ask"},
        ]
    },
    {
        "hook": os.path.join(REPO_HOOKS, "filter-test-output.py"),
        "cases": [
            {"file": "filter-test/match.jsonl", "expected_decision": "allow"},      # rewrite = allow with updatedInput
            {"file": "filter-test/nomatch.jsonl", "expected_decision": None},       # passthrough
        ]
    },
]


def run_test_case(hook_path: str, input_json: str) -> dict:
    """Run a single test case through a hook and return parsed output."""
    python_cmd = sys.executable
    result = subprocess.run(
        [python_cmd, hook_path],
        input=input_json,
        capture_output=True,
        text=True,
        timeout=10,
    )
    if result.returncode != 0:
        return {"error": f"exit {result.returncode}: {result.stderr}"}
    try:
        return json.loads(result.stdout.strip()) if result.stdout.strip() else {}
    except json.JSONDecodeError:
        return {"error": f"invalid JSON: {result.stdout[:200]}"}


def extract_decision(output: dict) -> str | None:
    """Extract permissionDecision from hook output, None if passthrough."""
    hook_output = output.get("hookSpecificOutput", {})
    return hook_output.get("permissionDecision")


def main():
    total = 0
    passed = 0
    failed = 0
    errors = []

    for test_group in TESTS:
        hook_path = test_group["hook"]
        hook_name = os.path.basename(hook_path)

        for case in test_group["cases"]:
            case_file = os.path.join(HOOKS_DIR, case["file"])
            expected = case["expected_decision"]

            with open(case_file) as f:
                for line_no, line in enumerate(f, 1):
                    line = line.strip()
                    if not line:
                        continue
                    total += 1

                    output = run_test_case(hook_path, line)

                    if "error" in output:
                        failed += 1
                        errors.append(f"  FAIL {hook_name} {case['file']}:{line_no} — {output['error']}")
                        continue

                    actual = extract_decision(output)
                    if actual == expected:
                        passed += 1
                    else:
                        failed += 1
                        cmd = json.loads(line).get("tool_input", {}).get("command", "?")
                        errors.append(
                            f"  FAIL {hook_name} {case['file']}:{line_no} "
                            f"cmd={cmd!r} expected={expected} got={actual}"
                        )

    print(f"\n=== Hook Golden Tests ===")
    print(f"Total: {total}  Passed: {passed}  Failed: {failed}")
    if errors:
        print(f"\nFailures:")
        for e in errors:
            print(e)
        sys.exit(1)
    else:
        print("All tests passed!")
        sys.exit(0)


if __name__ == "__main__":
    main()
