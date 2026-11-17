#!/bin/sh
# Compile la version anglaise (docs/, version par défaut) puis la version française (docs/fr/).
set -e
cd "$(dirname "$0")"

# Les anciennes sorties sont supprimées avant de compiler, sinon Quarto les recopie
rm -rf docs _site_fr en/_site

# Version française
quarto render

# Ressources partagées copiées dans le projet anglais (ignorées par git)
cp custom.css en/
cp -R _extensions en/
cp -R doc.assets en/
cp CV_moatsembellh_en.pdf photo.jpg en/
for f in PCBOTcarte.jpg PCBOTcarte2.jpg waveglider.jpg titlepanel.png; do cp "travaux/$f" en/works/; done
cp -R travaux/fpga travaux/tipe travaux/scan3d en/works/

# Version anglaise
(cd en && quarto render)

cp -R en/_site docs
cp -R _site_fr docs/fr
touch docs/.nojekyll

# Liens EN <-> FR relatifs, pour qu'ils marchent en local comme en ligne
python3 - <<'PY'
import pathlib, os
docs = pathlib.Path("docs")
for page in docs.rglob("*.html"):
    rel = page.relative_to(docs)
    root = os.path.relpath(docs, page.parent)
    root = "" if root == "." else root + "/"
    html = page.read_text(encoding="utf-8")
    if rel.parts[0] == "fr":
        html = html.replace('href="https://elnmoat.github.io/"', f'href="{root}index.html"')
    else:
        html = html.replace('href="https://elnmoat.github.io/fr/"', f'href="{root}fr/index.html"')
    page.write_text(html, encoding="utf-8")
PY
echo "Site compilé dans docs/ (EN, par défaut) et docs/fr/ (FR)"
