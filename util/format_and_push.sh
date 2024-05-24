#!/usr/bin/env bash
# echo "${BASH_SOURCE[0]}"
#echo "$( dirname -- "${BASH_SOURCE[-1]}" )"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[-1]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR
for ITEM in $SCRIPT_DIR/*venv*/; do
    if [[ -d $ITEM ]]; then
        echo "$ITEM is a directory"
        venv_dir=${ITEM%*/}
    fi
done

$venv_dir/bin/python3 $SCRIPT_DIR/update_readme.py

git add README.md
git commit -m "Build README.md from stubs"

git push