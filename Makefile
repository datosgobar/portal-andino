SHELL = bash

.PHONY: docs servedocs doctoc

servedocs:
	mkdocs serve

mkdocsdocs:
	mkdocs build
	rsync -vau --remove-source-files site/ docs/
	rm -rf site

docs: mkdocsdocs

doctoc: ## generate table of contents, doctoc command line tool required
        ## https://github.com/thlorenz/doctoc
	doctoc --maxlevel 3 --gitlab --title "## Indice" docs/
	find docs/ -name "*.md" -exec bash fix_github_links.sh {} \;

pdf:
	mkdocs_datosgobar md2pdf mkdocs.yml docs/portal-andino-docs.pdf







