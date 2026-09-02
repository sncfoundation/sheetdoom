<div align="center">

# 🔫 SheetDoom

**Real, full DOOM — packaged as a SICF image and run from a spreadsheet.**

The chocolate-doom engine plus the free Freedoom WAD, stored in the cells, run by the cluster.
A [Sheet-Native Computing Foundation](https://sncfoundation.github.io) demo · sci#6 · sheeternetes#52

</div>

---

Not js-dos, not a toy. This is the actual **chocolate-doom** engine with the Freedoom IWAD (a free, DOOM-compatible game),
running in a Linux container over noVNC, so you play real DOOM in a browser with a keyboard. The
twist: the container image itself is stored **inside a spreadsheet** ([SICF](https://github.com/sncfoundation/sci/blob/main/specs/sicf-v0.1.md)
native mode), and the Sheeternetes kubelet materializes it back out and runs it. Execution is on
the node; the sheet stores the image and schedules the pod.

## Run it (needs a Docker host)

You'll also want the [`sheeternetes-onprem`](https://github.com/sncfoundation/sheeternetes-onprem)
runtime and the [`sheetbuild`](https://github.com/sncfoundation/sci) tool.

```bash
# 1. build real DOOM and save it to a tar
docker build -t doom:shareware .
docker save  doom:shareware -o doom.tar

# 2. pack the WHOLE image INTO the cluster workbook (layers -> base64 cells, sha256-addressed)
python3 /path/to/sci/tools/sheetbuild.py import doom.tar --name doom:shareware --store cluster.xlsx

# 3. prove it: delete it locally. it now exists ONLY in the spreadsheet.
docker rmi doom:shareware

# 4. bring up the cluster and deploy
#    terminal 1:  WORKBOOK=cluster.xlsx TOKEN=secret python3 apiserver.py
#    terminal 2:  ./kubelet.sh          (WEBAPP_URL/TOKEN in .skctl.env)
./skctl apply doom.json                 # image: sicf:doom:shareware
./skctl get pods                        # doom-1  Running
```

The kubelet saw `sicf:`, pulled the layers out of the sheet, verified every sha256,
`docker load`ed the image back into existence, and ran it. Then play:

```bash
# the kubelet doesn't publish ports yet (tracked: sheeternetes-onprem#7), so to play,
# run the freshly-materialized image directly — it came back out of the spreadsheet:
docker run --rm -p 8080:8080 doom:shareware
# open http://localhost:8080/vnc.html  ->  Connect  ->  rip and tear
```

## Size, honestly

A full Linux DOOM (Debian + X + noVNC + the engine) is a couple hundred MB. Base64 in cells it's
thousands of cells — under the 10M-cell workbook limit, but the file gets heavy and Excel/Sheets
will feel it. That's exactly what we're measuring in
[sci#5](https://github.com/sncfoundation/sci/issues/5). For a snappier demo, a minimal
framebuffer/ASCII DOOM build shrinks it a lot; the WAD alone is a few MB.

---

<sub>Apache-2.0. id Software owns DOOM; this repo ships only packaging + a launcher (chocolate-doom and the free Freedoom WAD come from Debian main). Do run DOOM on a spreadsheet. It reconciles. 💩</sub>
