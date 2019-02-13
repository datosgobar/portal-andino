SHELL = bash

.PHONY: docs servedocs doctoc

servedocs:
	mkdocs serve

mkdocsdocs:
	mkdocs build
	rsync -vau --remove-source-files site/ docs/
	rm -rf site

docs: doctoc mkdocsdocs

doctoc: ## generate table of contents, doctoc command line tool required
        ## https://github.com/thlorenz/doctoc
	doctoc --maxlevel 4 --github --title "## Indice" docs/
	find docs/ -name "*.md" -exec bash fix_github_links.sh {} \;

pdf:
	python md2pdf.py docs/quickstart.md,docs/developers/install.md,docs/developers/update.md,docs/developers/checklist.md,docs/developers/migration.md,docs/developers/maintenance.md,docs/developers/https.md,docs/developers/dns.md,docs/developers/development.md,docs/developers/tests.md docs/pdf/portal-andino-docs.pdf






