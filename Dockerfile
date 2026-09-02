# SheetDoom — a tiny web-DOOM image. Build it, then pack the WHOLE thing into a
# spreadsheet with `sheetbuild import` (see README). js-dos boots the freely
# distributable shareware DOOM in the browser.
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
