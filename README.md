<div align="center">

# 🔫 SheetDoom

**DOOM, packaged as a SICF image and run from a spreadsheet.**

The whole game lives in the cells. The cluster runs it from there.
A [Sheet-Native Computing Foundation](https://sncfoundation.github.io) demo · sci#6 · sheeternetes#52

</div>

---

Can it run DOOM? Yes — and the image itself lives **inside a Google Sheet / Excel file**.

DOOM is small enough to store entirely in a workbook: the shareware game plus a tiny web
front-end is a few hundred base64 cells — far under the 10M-cell limit. Sheeternetes packs it
into the sheet with [`sheetbuild`](https://github.com/sncfoundation/sci), and the kubelet
materializes it back out and runs it. **Execution stays on the node** (real Docker); the
spreadsheet only stores the image and schedules the pod. This is [SICF](https://github.com/sncfoundation/sci/blob/main/specs/sicf-v0.1.md)
native mode — our own container format, no registry.

## Run it

You need a Docker host, plus the [`sheeternetes-onprem`](https://github.com/sncfoundation/sheeternetes-onprem)
runtime and [`sci`](https://github.com/sncfoundation/sci) tools.

```bash
# 1. build the image and save it to a tar
docker build -t doom:shareware .
docker save  doom:shareware -o doom.tar

# 2. pack the WHOLE image into the cluster workbook (layers -> base64 cells, sha256-addressed)
python3 /path/to/sci/tools/sheetbuild.py import doom.tar --name doom:shareware --store cluster.xlsx

# 3. the killer move — delete it locally. It now exists ONLY in the spreadsheet.
docker rmi doom:shareware

# 4. bring up the cluster and deploy
#    terminal 1:  WORKBOOK=cluster.xlsx TOKEN=secret python3 apiserver.py
#    terminal 2:  ./kubelet.sh           (WEBAPP_URL/TOKEN in .skctl.env)
./skctl apply doom.json                  # image: sicf:doom:shareware
./skctl get pods                         # doom-1  Running
```

Behind the scenes: the kubelet saw `sicf:`, called `sicf.py` — it fetched the layers from the
apiserver, **verified every sha256**, `docker load`-ed the image (watch it reappear:
`docker images | grep doom`), and ran it. The image came **out of the spreadsheet**.

## Play it

The kubelet doesn't publish ports yet ([tracked](https://github.com/sncfoundation/sheeternetes-onprem/issues/7)),
so the simplest way to open the freshly-materialized image is to run it directly — proving it
came back from the cells:

```bash
docker run --rm -p 8080:80 doom:shareware   # http://localhost:8080  →  rip and tear
```

## Notes

- The front-end uses [js-dos](https://js-dos.com) to boot the shareware DOOM in the browser; it
  needs internet for the js-dos lib. For a fully **air-gapped** image, vendor `js-dos.js` and a
  WAD next to `index.html`.
- The heavy lifting (the game) runs on the node's real CPU. The spreadsheet is the store and the
  control plane — never the executor.

---

<sub>Apache-2.0. id Software owns DOOM; this repo ships only a thin launcher and the packaging demo.
Do not run production on a spreadsheet. Do run DOOM on one. It reconciles. 💩</sub>
