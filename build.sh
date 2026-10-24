#!/bin/sh
# Compile la version française (docs/) puis la version anglaise (docs/en/).
set -e
cd "$(dirname "$0")"

quarto render

# Ressources partagées copiées dans le projet anglais (ignorées par git)
cp custom.css en/
cp -R _extensions en/
cp -R doc.assets en/
cp CV_moatsembellh_en.pdf en/
for f in PCBOTcarte.jpg PCBOTcarte2.jpg waveglider.jpg titlepanel.png; do cp "travaux/$f" en/works/; done
cp -R travaux/fpga travaux/tipe en/works/

(cd en && quarto render)
rm -rf docs/en
cp -R en/_site docs/en
touch docs/.nojekyll

# Liens FR <-> EN relatifs, pour qu'ils marchent en local comme en ligne
python3 - <<'PY'
import pathlib, os
docs = pathlib.Path("docs")
for page in docs.rglob("*.html"):
    rel = page.relative_to(docs)
    up = os.path.relpath(docs, page.parent)
    up = "" if up == "." else up + "/"
    html = page.read_text(encoding="utf-8")
    if rel.parts[0] == "en":
        html = html.replace('href="https://elnmoat.github.io/"', f'href="{os.path.relpath(docs, page.parent)}/index.html"')
    else:
        html = html.replace('href="https://elnmoat.github.io/en/"', f'href="{up}en/index.html"')
    page.write_text(html, encoding="utf-8")
PY
echo "Site compilé dans docs/ (FR) et docs/en/ (EN)"
