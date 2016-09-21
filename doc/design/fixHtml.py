#!/usr/bin/python
import re
import glob, os

# This section fixes wrong formating as plantuml seems to write a wrong
# formatting if used together with numfig
for fil in glob.glob("build/html/*.html"):
    lines = []
    with open(fil, 'r') as infile:
        for line in infile:
            line = re.sub(r'<span class="caption-text">Figure \d: &lt;paragraph&gt;', ': ', line)
            line = re.sub(r'&lt;/paragraph&gt;</span>', '', line)
            lines.append(line)

    with open(fil, 'w') as outfile:
        for line in lines:
            outfile.write(line)



