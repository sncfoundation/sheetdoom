# SheetDoom — a REAL, full DOOM: the chocolate-doom engine + the shareware WAD,
# played in your browser over noVNC. No js-dos, no CDN — a genuine Linux DOOM.
# Build it, then pack the whole image INTO a spreadsheet with `sheetbuild import`.
FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      chocolate-doom freedoom \
      xvfb x11vnc fluxbox novnc websockify tini ca-certificates \
 && rm -rf /var/lib/apt/lists/*
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/usr/local/bin/start.sh"]
