#!/bin/sh -e

# Perform destructive re-initialization of the project.
# -----------------------------------------------------

# Warning: DESTRUCTIVE


# Effectful execution functions.
# -------------------------------------

logic ()
{
    name="$1"
    description="$2"
    username="$3"
    subId="`date +%s`"

    mkdir "$subId"

    # Reset Git repo.
    git remote rename 'origin' 'initial'

    # Set npm project name, project description, associated variables.
    # (The latter implies "repository", "bugs" and "homepage")
    sed -i".archive" -r '
        s/"name": "initial"/"name": "'"$name"'"/
        s/"description": "[^"]*"/"description": "'"$description"'"/
        s/(.*)initial(.*)/\1'"$name"'\2/
        ' 'package.json'
    mv 'package.json.archive' "$subId"

    # Write a readme.
    echo "$description" > README.md

    # Commit changes.
    git branch master
    git checkout master
    git add package.json
    git add README.md
    git add gulpfile.{js,coffee}
    git add src
    git commit -m "Automatic initial commit. All things set up."
    
    # Synchronize.
    curl -u "$username" https://api.github.com/user/repos -d '{"name":"'"$name"'"}' >/dev/null
    git remote add origin "git@github.com:${username}/${name}.git"
    git push --set-upstream origin master

    # Clean up.
    rm -rf "$subId"

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

rm "$0"
exit # In any way.
