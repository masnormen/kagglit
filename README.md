# Kagglit

Kagglit is a simple shell script to easily sync Kaggle notebooks of a specified  user into a current local working directory and/or Git repository. It can also auto-generate an index written in Markdown format and put it into a file. This is particularly useful if you want to sync and then list of all your notebooks in a README file, for example.

## Installation

Ensure you have the following:
- Bash
- Git (if you want to use Kagglit to sync a Git repository)
- [Kaggle API](https://github.com/Kaggle/kaggle-api) properly installed. Make sure it's in your $PATH.

Then, download the shell script and make it executable,

```bash
$ curl "https://raw.githubusercontent.com/masnormen/kagglit/master/kagglit.sh"
$ chmod +x kagglit.sh
```

## Usage

The command line tool supports the following commands:

```sh
$ ./kagglit.sh

usage: kagglit USERNAME [-h] [-c] [-p] [-a] [-g FILENAME]

Sync public Kaggle notebooks of a specified user into a current local working directory and/or Git repository.

arguments:
  -h, --help               show this help message and exit
  -c, --commit             sync notebooks and make a git commit
  -p, --push               sync notebooks, make a git commit, and push to master
  -a, --all                download all notebooks, including private notebooks
  -g, --genindex FILENAME  make auto-generated index on the specified file

For more information, visit: https://github.com/masnormen/kagglit
```

See more details below for using each of these commands.

## Index Generator

With the `kagglit -g FILENAME` command, you can auto-generate an index containing the list of all your notebooks and put it into a file. The generated index is in Markdown format. Kagglit detects the identifying tags `<!--kagglit-start-->` and `<!--kagglit-end-->` in your file, and replace the content inbetween the two tags with the generated index.

For example:

**README. md: before**
```markdown
# Index
This is an example

<!--kagglit-start-->

THIS WILL BE REPLACED

<!--kagglit-end-->

Hey, this is also an example
```

**Execute Kagglit**
```bash
$ ./kagglit.sh masnormen -g README.md
```

**README. md: after**
```markdown
# Index
This is an example

<!--kagglit-start-->

- ## [📑&nbsp;&nbsp;IMDB's Indonesian Movies Exploratory Data Analysis &rarr;](https://www.kaggle.com/masnormen/imdb-s-indonesian-movies-exploratory-data-analysis/)  
  ### 🐍&nbsp;&nbsp;Lang: Python | [📈&nbsp;&nbsp;Dataset source](https://www.kaggle.com/dionisiusdh/imdb-indonesian-movies) | [:octocat:&nbsp;&nbsp;GitHub link](/imdb-s-indonesian-movies-exploratory-data-analysis.ipynb)
  Last run time: 2020-11-01 02:24:57 UTC

<!--kagglit-end-->

Hey, this is also an example
```

**Rendered result:**

- ## [📑&nbsp;&nbsp;IMDB's Indonesian Movies Exploratory Data Analysis &rarr;](https://www.kaggle.com/masnormen/imdb-s-indonesian-movies-exploratory-data-analysis/)  
  ### 🐍&nbsp;&nbsp;Lang: Python | [📈&nbsp;&nbsp;Dataset source](https://www.kaggle.com/dionisiusdh/imdb-indonesian-movies) | [:octocat:&nbsp;&nbsp;GitHub link](/imdb-s-indonesian-movies-exploratory-data-analysis.ipynb)
  Last run time: 2020-11-01 02:24:57 UTC

---

The generated index will be written automatically between the identifying tags in the README.md file. Notice that the tag `<!--kagglit-start-->` won't be printed on the actual rendered result because it is a HTML comment tag.

## Syncing private notebooks

By default, Kagglit will only sync notebooks you have made public. To sync private notebooks, you can use the option `-a` or `--all`

```bash
# Sync all notebooks, including private notebooks

$ ./kagglit.sh masnormen -a
```

## Syncing with Git repository

Kagglit can sync your Kaggle notebooks locally, and then commit or push changes on a Git repository. An initialized Git repository must be already in the current working directory. It's basically a wrapper for `git add`, `git commit` and `git push origin master`

Sync and commit:
```bash
$ ./kagglit.sh masnormen -c
```

Sync, commit, and push:
```bash
$ ./kagglit.sh masnormen -p
```

## License

Kagglit is released under the [Apache 2.0 license](LICENSE).