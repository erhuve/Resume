import pathlib
import subprocess


ROOT = pathlib.Path(__file__).resolve().parents[1]


def render():
    source = (ROOT / "main.tex").read_text()
    source = source.replace(r"\input{glyphtounicode}", "")
    result = subprocess.run(
        [
            "pandoc", "--from=latex", "--to=html", "--wrap=none",
            f"--lua-filter={ROOT / 'scripts/readme.lua'}",
        ],
        input=source, text=True, capture_output=True, check=True,
    )
    if result.stderr:
        raise RuntimeError(result.stderr)
    return (
        "<!-- Generated from main.tex by scripts/render_readme.py. Do not edit directly. -->\n\n"
        + result.stdout
        + '\n<p align="center"><a href="Luo%20Raymond%20Resume.pdf">View / download PDF</a></p>\n'
    )


if __name__ == "__main__":
    (ROOT / "README.md").write_text(render())
