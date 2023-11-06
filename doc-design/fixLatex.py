#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from replace_in_file import *

def freplace(old, new):
    file_name=os.path.join("build", "latex", "soep-design.tex")
    replace_in_file(old, new, file_name)

freplace('\documentclass[letterpaper,10pt,english]{sphinxmanual}', '''\pdfminorversion=7
\documentclass[letterpaper, 10pt, english]{book}''')

# This removes code generated by sphinx which causes on Ubuntu 16.04
# a  "LaTeX Error: Option clash for package geometry." because we
# overwrite the geometry settings.
freplace('\usepackage[margin=1in,marginparwidth=0.5in]{geometry}', '') # For Linux
freplace('\usepackage{geometry}', '')                                  # For OS X

#freplace('\\maketitle',
#        '\\input{../../source/titlepage.tex} \\setcounter{page}{2}')

freplace('\\phantomsection\\label{index::doc}',
        '\\phantomsection\\label{index::doc} \\clearpage')

freplace('\\begin{thebibliography}{1}',
        '''\\chapter{References}
\\begin{thebibliography}{1}''')

freplace('\\begin{Verbatim}[',
        '\\begin{Verbatim}[fontsize=\\footnotesize, ')

# The last entry of the references has the wrong identation. The command below fixes it.
freplace('\\end{sphinxthebibliography}', '\\bibitem[]{}{} \\end{sphinxthebibliography}')
