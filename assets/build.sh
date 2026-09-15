#!/usr/bin/env bash
# Compile every .tex diagram in this folder to a self-contained .svg.
#
#   ./build.sh              build all
#   ./build.sh foo.tex      build just one
#
# You only need this if you are CHANGING a diagram. The .svg files are
# committed and the Quarto deck renders straight from them, so nobody
# rebuilding the deck needs LaTeX.
#
# ---------------------------------------------------------------------
# Route: pdflatex -> PDF -> pdftocairo -> SVG
#
# Requires TeX Live plus poppler:   brew install poppler
#
# Two other routes look obvious and both fail silently. Do not "simplify"
# this back to either of them:
#
#   dvisvgm --pdf ...       dvisvgm's PDF backend needs mutool or
#                           Ghostscript, which TeX Live does not ship.
#                           Fails with "can't retrieve number of pages".
#
#   latex -> DVI -> dvisvgm In DVI mode tikz emits its graphics as
#                           PostScript specials, and processing those
#                           ALSO needs Ghostscript. Without it dvisvgm
#                           drops every box and arrow and stacks all the
#                           labels at one point -- and exits 0, so the
#                           build looks like it worked. Always eyeball
#                           the SVG after changing this script.
# ---------------------------------------------------------------------

set -euo pipefail
cd "$(dirname "$0")"

command -v pdflatex   >/dev/null || { echo "pdflatex not found (install TeX Live)"; exit 1; }
command -v pdftocairo >/dev/null || { echo "pdftocairo not found (brew install poppler)"; exit 1; }

if [ "$#" -gt 0 ]; then targets=("$@"); else targets=(*.tex); fi

for tex in "${targets[@]}"; do
  base="${tex%.tex}"
  echo "==> $tex"

  pdflatex -interaction=nonstopmode -halt-on-error "$tex" >/dev/null
  pdftocairo -svg "$base.pdf" "$base.svg"

  rm -f "$base.aux" "$base.log" "$base.pdf"

  python3 - "$base.svg" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
w = re.search(r'width="([0-9.]+)',  s).group(1)
h = re.search(r'height="([0-9.]+)', s).group(1)
paths = len(re.findall(r'<path', s))
ext   = len(re.findall(r'xlink:href="(?!#)', s))
print(f"    {sys.argv[1]}  {float(w):.0f}pt x {float(h):.0f}pt  "
      f"{paths} paths  {ext} external refs")
if float(w) / float(h) < 3:
    print("    WARNING: unexpectedly tall. The graphics may have been "
          "dropped -- open the SVG and look at it.")
PY
done

echo "done."
