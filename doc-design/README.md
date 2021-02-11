This document can be compiled using

```
make html
```
or
```
make latex
```

The compilation requires sphinx-doc (http://www.sphinx-doc.org)
and a few contributions, which can be installed by running

```
pip3 install --user sphinx
pip3 install --user sphinx_bootstrap_theme
pip3 install --user sphinxcontrib.bibtex==1.0
pip3 install --user sphinxcontrib-plantuml
```

UML graphics are drawn using https://pypi.python.org/pypi/sphinxcontrib-plantuml

plantuml requires graphviz, which can be installed on OS X using

```
brew install graphviz
```
and on Linux using
```
sudo apt-get install graphviz
```
