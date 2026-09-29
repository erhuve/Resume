# Updating the resume

Edit `main.tex`. The README and PDF are generated outputs.

The GitHub Actions workflow regenerates both after changes to the LaTeX source or rendering scripts reach `main`. Pull requests build the outputs without committing them. The workflow can also be run manually from the Actions tab. Repository Actions settings must allow the workflow to write repository contents.

To regenerate the README locally, install Pandoc and Python 3, then run:

```sh
python3 scripts/render_readme.py
```

To regenerate the PDF, install TeX Live with the extra LaTeX packages, then run:

```sh
mkdir -p build
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
cp build/main.pdf 'Luo Raymond Resume.pdf'
```

The README preserves text, links, emphasis, section order, and paired heading/date columns. GitHub controls its fonts, table borders, spacing, wrapping, and theme; it does not reproduce the PDF's exact page layout. The PDF remains the print version.
