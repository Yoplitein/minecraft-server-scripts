#!/usr/bin/env python3
import json
import os
import sys
from urllib import request

versionManifest = "https://launchermeta.mojang.com/mc/game/version_manifest.json"

if len(sys.argv) < 2:
    print("Usage: update-vanilla [-f] <version>", file=sys.stderr)
    raise SystemExit(1)
targetVersion = sys.argv[1]


outFile = "minecraft_server.{}.jar".format(targetVersion)
if os.path.exists(outFile) and "-f" not in sys.argv:
    print("Error: output file {} already exists".format(outFile), file=sys.stderr)
    raise SystemExit(1)

selectedManifest = None

for version in json.load(request.urlopen(versionManifest))["versions"]:
    if version["id"] == targetVersion:
        selectedManifest = version["url"]
        
        if version["type"] != "release":
            print("Warning: not a release version ({})".format(version["type"]), file=sys.stderr)
        
        break
else:
    print("No matching versions found", file=sys.stderr)
    raise SystemExit(1)

manifest = json.load(request.urlopen(selectedManifest))
jarURL = manifest["downloads"]["server"]["url"]

def onProgress(numBlocks, blockSize, totalBytes):
    if totalBytes <= 0:
        print("\r{} KiB transferred".format(numBlocks * blockSize / 1024), file=sys.stderr, end="")
    else:
        transferred = numBlocks * blockSize
        percent = transferred / totalBytes
        print("\r{:.2f} / {:.2f} KiB transferred ({}%)".format(transferred / 1024, totalBytes / 1024, int(percent * 100)), file=sys.stderr, end="")

request.urlretrieve(jarURL, outFile, onProgress)
print(file=sys.stderr) # for progress output
print(outFile, "done")

try:
    if os.path.lexists("server.jar"):
        assert os.path.islink("server.jar"), "server.jar is not a symlink"
        os.remove("server.jar")
    
    os.symlink(outFile, "server.jar")
    print("linked server.jar ->", outFile, file=sys.stderr)
except Exception as err:
    print(f"Warning: failed to symlink server.jar ({err})", file=sys.stderr)
