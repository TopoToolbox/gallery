# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'TopoToolbox Gallery'
copyright = '2026'
author = 'TopoToolbox Contributors'


# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['nbsphinx']

templates_path = ['_templates']
exclude_patterns = ['build']



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'pydata_sphinx_theme'
html_static_path = ['_static']

html_title = "TopoToolbox Gallery"
html_logo = "_static/logo_small.png"

html_theme_options = {
    "logo" : {
        "text" : "TopoToolbox Gallery"
    }
}

html_sidebars = {
    "index" : [],
    "notebooks/index" : [],
    #"notebooks/**" : ["sbt-sidebar-nav.html"]
}

html_sourcelink_suffix = ''
