#!/bin/sh -e

# Perform destructive re-initialization of the project.
# -----------------------------------------------------

# Warning: DESTRUCTIVE


# Effectful execution functions.
# -------------------------------------

logic ()
#
# This function should have the following constraints:
# ----------------------------------------------------
# -- signature: logic :: name description username -> 0
# -- only operates on current directory that is assumed to be named 'name'
# -- creates a repository github.com:user/name
#
{
    # Initialize parameters.
    # ----------------------

    name="$1"
    description="$2"
    username="$3"

    # Make local changes.
    # -------------------

    git remote rename 'origin' 'initial'
    cabal init                    \
        --is-executable           \
        --source-dir 'src'        \
        --license 'ISC'           \
        --synopsis "$description" \
        --non-interactive
    cabal sandbox init
    echo "$description" > README.md
    mkdir -p src
    touch src/Main.hs
    echo 'module Main where' >> src/Main.hs
    echo                     >> src/Main.hs
    echo 'main = return ()'  >> src/Main.hs

    # Kill itself.
    # ------------

    git rm -- "$0"

    # Commit local changes.
    # ---------------------

    git branch master
    git checkout master
    git add "${name}.cabal" 'cabal.sandbox.config' 'README.md' 'LICENSE' 'src' 'Setup.hs'
    git commit -m "Automatic initial commit. All things set up."
    
    # Push local changes to github.
    # -----------------------------

    curl                                                             \
        -u "$username" https://api.github.com/user/repos             \
        -d '{"name":"'"$name"'", "description": "'"$description"'"}' \
        > /dev/null
    git remote add origin "git@github.com:${username}/${name}.git"
    git push --set-upstream origin master

    return 0
}

# User interfacing.
# -----------------

if test $# -eq 0
then # Interactive.

    echo "Re-initialization will destroy git history in here. Sure to proceed ?"

    select yn in "Yes" "No"
    do
        case $yn in 
            (Yes)
                echo "How would you like to name your new project ?"
                read name
                echo "How would you like to describe your new project ?"
                read description
                echo "How would you like to present yourself? (Default: ${USER})"
                read username

                if not test "$username"
                then
                    username="$USER"
                fi

                logic "$name" "$description" "$username"
                exit
                ;;
            (No)
                exit
                ;;
        esac
    done
else # Batch.
    name="$1"
    description="$2"
    username="$3"
    logic "$name" "$description" "$username"
fi

exit # In any way.

