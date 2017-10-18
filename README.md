# gitnoob

gitnoob is just a small layer of abrstraction for the most used git tasks.
It helps adopting good practices and pushing clean code
features, while reducting the number of commands needed to push code.
(Note : you can still use git commands directly if you want)

Using gitnoobs commands basically :

- prevents you from coding directly into dev branch
- prevents from merging breaking code into dev branch
- force you to code inside feature branches
- maintain a clean structure in dev and master

to get a list of available commands, use the -h argument.

## Understanding gitnoob
Here is the simple concept of gitnoob workflow :
The *master* branch hold your releases, the *dev* branch always contain a potentially releasable version of your code, and you are forced to create a *feature* branch if you wanna work.

### the master branch
Each commit on this branch is considered a new viable version of your application, suitable for production testing and deployment.
That branch cannot be accessed directly, to create à new version you use the `-v` argument form the dev branch.

### the dev branch
The dev branch is the base where feature branches are created. You cannot commit directly inside dev but can begin a new feature or re-open an existing one with the `-f` option.

### feature branches
Feature branches are the right place to code, **"feature-"**  automatically prepend the git name of a feature branch. From here you can :

- stage all you changes and commit them using `-c [commit message]`
- update your feature with changes that happened in the *dev* branch with `-u`
- go back to *dev* with `-r`
- finish your feature and add it to *dev* with `-p` (as in "prune"), note that your feature will not be added to dev it tests fails (rails only for now)

*Note : feature branches are automatically sync with origin (online) for collaboration purposes but you can branch locally from a feature branch if you want to, with the native git commands.*

## dicussion

- we might consider removing the dev branch as the code here is supposed to be ready to deploy. It looks like it could be simplified.
