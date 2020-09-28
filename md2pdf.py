#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Convierte un archivo markdown en pdf según el estilo de la DNDIP"""

from __future__ import unicode_literals
from __future__ import print_function
from __future__ import with_statement
import os
import sys

import markdown2
import pdfkit
import shutil


def main(input_paths_str, output_path):

    # lee los htmls a convertir en PDF
    input_paths = input_paths_str.split(",")
    htmls = []
    for input_path in input_paths:
        with open(input_path) as input_file:
            htmls.append(markdown2.markdown(
                input_file.read(),
                extras=["fenced_code", "codehilite", "admonition"]))
    print("Hay {} documentos".format(len(htmls)))

    # guarda html
    with open(output_path.replace(".pdf", ".html"), "wb") as output_html:

        # aplica el estilo al principio
        html = "\n".join(htmls)
        html_with_style = """
        <link rel="stylesheet" href="pdf.css" type="text/css"/>
        """ + html

        # escribe el html
        output_html.write(html_with_style.encode("utf-8"))
        shutil.copyfile(
            "docs/css/pdf.css",
            os.path.join(os.path.dirname(output_path), "pdf.css")
        )

    # guarda pdf
    pdfkit.from_string(html, output_path, options={"encoding": "utf8"},
                       css="docs/css/pdf.css")


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
