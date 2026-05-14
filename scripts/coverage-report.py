#!/usr/bin/env python3
import json, sys, os, subprocess, glob

# With --hook: reads PostToolUse event from stdin and filters to xcodebuild test runs.
# Without args: prints coverage for the most recent xcresult immediately.
if "--hook" in sys.argv:
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    cmd = data.get("tool_input", {}).get("command", "")
    if "xcodebuild test" not in cmd:
        sys.exit(0)

results = sorted(
    glob.glob(os.path.expanduser("~/Library/Developer/Xcode/DerivedData/sift-*/Logs/Test/*.xcresult")),
    key=os.path.getmtime,
    reverse=True,
)
if not results:
    print("No xcresult found in DerivedData.")
    sys.exit(0)

proc = subprocess.run(
    ["xcrun", "xccov", "view", "--report", "--json", results[0]],
    capture_output=True,
    text=True,
)
if proc.returncode != 0:
    print(f"xccov failed: {proc.stderr.strip()}")
    sys.exit(0)

cov = json.loads(proc.stdout)
app = next((t for t in cov.get("targets", []) if t["name"] == "sift.app"), None)
if not app:
    print("No sift.app target in coverage data.")
    sys.exit(0)

overall = app["lineCoverage"] * 100
print(f"\n── App Coverage: {overall:.1f}% ────────────────────────────")
for f in sorted(app.get("files", []), key=lambda x: x["lineCoverage"]):
    pct = f["lineCoverage"] * 100
    bar = "█" * int(pct / 10) + "░" * (10 - int(pct / 10))
    name = os.path.basename(f["path"])
    print(f"  {bar}  {pct:5.1f}%  {name}")
print("───────────────────────────────────────────────────\n")
