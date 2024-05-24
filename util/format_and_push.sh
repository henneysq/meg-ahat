#!/usr/bin/env bash
# echo "${BASH_SOURCE[0]}"
#echo "$( dirname -- "${BASH_SOURCE[-1]}" )"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJ_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[-1]}" )" &> /dev/null && pwd )
echo "$PROJ_DIR is the project directory"
for ITEM in $PROJ_DIR/*venv*/; do
    if [[ -d $ITEM ]]; then
        echo "$ITEM is a directory"
        venv_dir=${ITEM%*/}
    fi
done

echo "$SCRIPT_DIR is where we find the update_readme.py"
$venv_dir/bin/python3 $SCRIPT_DIR/update_readme.py

git add README.md
git commit -m "Build README.md from stubs"

git push