doctoc: ## generate table of contents, doctoc command line tool required
        ## https://github.com/thlorenz/doctoc
	doctoc --github --title "## Indice" docs/quickstart.md
	bash fix_github_links.sh docs/quickstart.md
