#!/usr/bin/env bash
# Prove it: build real DOOM, store the WHOLE image inside a spreadsheet, delete it
# locally, rebuild it straight FROM THE SPREADSHEET, and run it.
# Needs: docker + python3 + openpyxl, and the sci repo cloned as a sibling (or set SCI=).
set -euo pipefail
SCI="${SCI:-../sci}"
[ -f "$SCI/tools/sheetbuild.py" ] || { echo "set SCI=/path/to/sci (needs tools/sheetbuild.py)"; exit 1; }

echo ">>> [1/5] building real DOOM (chocolate-doom + freedoom + noVNC)…"
docker build -t doom:shareware .
docker save doom:shareware -o /tmp/doom.tar

echo ">>> [2/5] packing the WHOLE image into cluster.xlsx (layers -> base64 cells)…"
python3 "$SCI/tools/sheetbuild.py" import /tmp/doom.tar --name doom:shareware --store cluster.xlsx
python3 "$SCI/tools/sheetbuild.py" ls --store cluster.xlsx

echo ">>> [3/5] deleting the local image — it now exists ONLY in the spreadsheet."
docker rmi doom:shareware

echo ">>> [4/5] rebuilding the image FROM THE SPREADSHEET (every layer sha256-verified)…"
python3 "$SCI/tools/sheetbuild.py" export doom:shareware --store cluster.xlsx --out /tmp/back.tar
docker load -i /tmp/back.tar

echo ">>> [5/5] running DOOM, materialized from the sheet:"
echo "        open  http://localhost:8080/vnc.html  ->  Connect  ->  rip and tear"
docker run --rm -p 8080:8080 doom:shareware
