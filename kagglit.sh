#!/bin/bash

USERNAME="$1"
GIT_OPT=0
FETCH_PRIVATE=0
GEN_README=0
README_NAME=""

HELP="usage: kagglit USERNAME [-h] [-c] [-p] [-a] [-g FILENAME]

Sync public notebooks of a specified Kaggle user into a current local working directory or Git repository.

arguments:
  -h, --help               show this help message and exit
  -c, --commit             sync notebooks and make a git commit
  -p, --push               sync notebooks, make a git commit, and push to master
  -a, --all                download all notebooks, including private notebooks
  -g, --genindex FILENAME  make auto-generated index on the specified file

For more information, visit: https://github.com/masnormen/kagglit"

if [ $# -eq 0 ]; then
	echo "error: at least the following arguments are required: username"
	exit 1
fi

while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo "$HELP"
			exit;
		;;
		-c|--commit)
			GIT_OPT=1
		;;
		-p|--push)
	  		GIT_OPT=2
		;;
		-g|--genindex)
	  		GEN_README=1
	  		README_NAME=${2}
		;;
		-a|--all)
	  		FETCH_PRIVATE=1
		;;
	esac
	shift
done

if [[ $USERNAME == "" ]]; then
	echo "error: at least the following arguments are required: username"
	exit 1
fi

echo "Fetching kernel list..."
DATA=$(kaggle kernels list --user "$USERNAME" --page-size 100)

# Check if kernel is found
if [[ $DATA == "No kernels found" ]]; then
	echo "$DATA for this user"
	exit 1
fi

# Split output lines into array
IFS=$'\n' lines=($DATA)

readme_links=""

for line in "${lines[@]}"; do
	# Split into columns
	columns=$(echo "$line" |  sed 's/ \{2,\}/;/g')
	IFS=';' read -ra columns <<<"$columns"
	
	# Get notebook's info
	ref="${columns[0]}"
	title=$(echo "${columns[1]}" |  sed 's/[<>:"\/\\|?*]//g')
	lastRunTime="${columns[3]}"
	
	# Check if it's a notebook column with valid ref
	if [[ $ref != *"/"* ]]; then
 		continue
 	fi
 	
 	IFS='/' read -ra filename <<< "$ref"
	filename="${filename[1]}"
 	
 	# Pulling individual kernels with its metadata
 	rm kernel-metadata.json &>/dev/null
	kaggle kernels pull "$ref" -m && echo "Downloaded ${filename}.ipynb"
	
	# Check if notebook is private
	private=$(grep -o '"is_private": [^"]*' kernel-metadata.json | grep -Eo 'false|true')
	if [[ $private == *"true"* ]] && [ $FETCH_PRIVATE -eq 0 ]; then
		rm "${filename}.ipynb" &>/dev/null
		rm kernel-metadata.json &>/dev/null
 		continue
 	fi
	
	lang=$(grep -o '"language": "[^"]*' kernel-metadata.json | grep -o '[^"]*$' | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }')
	dataset=$(grep -A1 "dataset_sources" kernel-metadata.json | grep -v '\[' | grep -o '"[A-Za-z/0-9_.-]*"' | sed 's/"//g')
	competition=$(grep -A1 "competition_sources" kernel-metadata.json | grep -v '\[' | grep -o '"[A-Za-z/0-9_.-]*"' | sed 's/"//g')
	# kernel=`grep -A1 "kernel_sources" kernel-metadata.json | grep -v '\[' | grep -o '"[A-Za-z/0-9_.-]*"' | sed 's/"//g'`
	
	langemoji="📎" # Default for "all"
	case "$lang" in
		Python)
			langemoji="🐍"
		;;
		R)
	  		langemoji="Ⓡ"
		;;
		Sqlite)
	  		langemoji="🖋️"
		;;
		Julia)
	  		langemoji="Ⓙ"
		;;
	esac
	
	if [ $GEN_README -eq 1 ]; then
		readme_entry="- ## [📑&nbsp;&nbsp;${title} &rarr;](https://www.kaggle.com/${ref}/)  \n  ### ${langemoji}&nbsp;&nbsp;Lang: ${lang}"
	 	if [ -n "$dataset" ]; then
	 		readme_entry+=" | [📈&nbsp;&nbsp;Dataset source](https://www.kaggle.com/${dataset})"
	 	fi
	  	#if [ -n $kernel ]; then
	  	#	readme_entry+=" | [📋&nbsp;&nbsp;Kernel source](https://www.kaggle.com/${kernel})"
	  	#fi
	 	if [ -n "$competition" ]; then
	 		readme_entry+=" | [🚩&nbsp;&nbsp;Competition](https://www.kaggle.com/c/${competition})"
	 	fi
	 	readme_entry+=" | [:octocat:&nbsp;&nbsp;GitHub link](/${filename}.ipynb)"
	 	readme_entry+="\n  Last run time: ${lastRunTime} UTC\n"
	 	readme_links+=$readme_entry
	fi
 	
 	rm kernel-metadata.json &>/dev/null
done

if [ $GEN_README -eq 1 ]; then
	cat README.md | awk -v my_var="\n$readme_links" 'BEGIN {p=1} /^<!--kagglit-start-->/ {print;print my_var;p=0} /^<!--kagglit-end-->/ {p=1} p' > tmpkgglt && mv tmpkgglt $README_NAME
fi

if [ $GIT_OPT -gt 0 ]; then
	# Add kagglit to .gitignore if not already
	grep -qxF 'kagglit.sh' .gitignore || echo 'kagglit.sh' >> .gitignore
	
	date=$(date '+%Y/%m/%d %H:%M:%S')
	git add .
	git commit -m "Synchronized on ${date}"
fi
if [ $GIT_OPT -gt 1 ]; then
	git push -u origin master
fi