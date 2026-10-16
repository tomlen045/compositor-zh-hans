#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Convert Localizable.xcstrings -> zh-Hans.lproj/Localizable.strings (runtime
format) and inject into a .app bundle — no Xcode needed.

Only translated (non-empty) entries are written; missing keys fall back to the
app's built-in English at runtime.
"""
import json
import os
import plistlib
import shutil
import subprocess
import sys

def xcstrings_to_strings(xc_path, lang="zh-Hans"):
    d = json.load(open(xc_path, encoding="utf-8"))
    lines = ["/* Localizable.strings — generated from xcstrings by inject_l10n.py */"]
    n = 0
    for key, entry in sorted(d.get("strings", {}).items()):
        su = entry.get("localizations", {}).get(lang, {}).get("stringUnit", {})
        if su.get("state") == "translated" and su.get("value"):
            val = su["value"]
            k = key.replace("\\", "\\\\").replace('"', '\\"')
            v = val.replace("\\", "\\\\").replace('"', '\\"')
            lines.append('"%s" = "%s";' % (k, v))
            n += 1
    return "\n".join(lines) + "\n", n

def main():
    if len(sys.argv) < 3:
        print("usage: inject_l10n.py <Compositor.app> <Localizable.xcstrings>")
        sys.exit(2)
    app = sys.argv[1]
    xc = sys.argv[2]
    res = os.path.join(app, "Contents", "Resources")
    assert os.path.isdir(res), "not a .app bundle: " + app

    zh_dir = os.path.join(res, "zh-Hans.lproj")
    os.makedirs(zh_dir, exist_ok=True)
    text, n = xcstrings_to_strings(xc, "zh-Hans")
    with open(os.path.join(zh_dir, "Localizable.strings"), "w", encoding="utf-8") as f:
        f.write(text)
    print("wrote %d zh-Hans entries -> %s" % (n, os.path.join(zh_dir, "Localizable.strings")))

    # declare the localization in Info.plist (merge, don't clobber)
    info = os.path.join(app, "Contents", "Info.plist")
    with open(info, "rb") as f:
        p = plistlib.load(f)
    locs = set(p.get("CFBundleLocalizations") or [])
    locs.add("zh-Hans")
    p["CFBundleLocalizations"] = sorted(locs)
    with open(info, "wb") as f:
        plistlib.dump(p, f)
    print("Info.plist CFBundleLocalizations:", sorted(locs))

    # re-sign (ad-hoc) so macOS will still launch the modified bundle
    r = subprocess.run(["codesign", "--force", "--deep", "--sign", "-", app],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("codesign FAILED:", r.stderr.strip()[:300])
        sys.exit(r.returncode)
    # verify the re-signed bundle actually validates
    v = subprocess.run(["codesign", "--verify", "--deep", "--strict", app],
                       capture_output=True, text=True)
    if v.returncode != 0:
        print("codesign verify FAILED:", (v.stderr or v.stdout).strip()[:300])
        sys.exit(v.returncode)
    print("codesign: OK (verified)")

if __name__ == "__main__":
    main()
