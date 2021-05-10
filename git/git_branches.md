Les bases
Une branche git est juste un pointeur vers un commit.
Il existe un pointeur HEAD dédié à désigner la branche courante
Passer d'une branche à l'autre (avec la commande git checkout) revient à déplacer le pointeur HEAD d'un pointeur de branche à l'autre (schéma)
L'ajout d'un nouveau commit sur une branche s'accompagne du déplacement du pointeur de la branche (et de HEAD)
Montrer que git commit déplace le poiteur de branche (à la différence des tags/remote-tracking branch)
Exemple de detached head (on peut continuer à commiter mais penser à faire un git checkout -b avant de recheck out une autre branche)
Schéma différence entre git branch et git checkout -b

Remarque : les tags : pointeur inamivible ?

Terminologie git
"The branch must be fully merged in its upstream branch"

Commandes utiles - git branch
LISTER LES BRANCHES
git branch [-l/--list] :  liste toutes les branches locales du dépôt local
master
feature
git branch [-l/--list] -r/--remotes : liste toutes les remote-tracking branches du dépôt local
origin/master
origin/feature
git branch [-l/--list] -a/--all : liste toutes les branches du dépôt local, remote-tracking branches comprises
master
origin/master
feature
origin/feature
git branch [-l/--list] -v : liste toutes les branches locales et leur dernier commit
master   3egh2a Last master commit message
feature  bh6thd Last feature commit message
git branch [-l/--list] -vv : liste toutes les branches locales, leur dernier commit et le nom de leur upstream branch. Construit sur l'image du repo local, ne se connecte pas au serveur, si on veut une image récent, faire un git fetch --all avant.
master   3egh2a [origin/master] Last master commit message
feature  bh6thd [origin/feature: ahead 2] Last feature commit message
local_b  uyt421 Last local_b commit message
git branch [-l/--list] --merged / --no-merged : liste les branches déjà fusionnées / non encore fusionnées (préciser lors de git merge que la branche fusionnée n'est pas supprimée - on pourrait très bien avoir besoin de fusionner son contenu à d'autres branches, par exemple : si on a une branche de dev et de recette, le contenu de la branche de fix doit être intégré à la dev et à la prod) Applique juste un filtre supplémentaire par rapport aux commandes précédentes. Il existe plein d'autres moyens de filter la liste de branches
RENOMMER UNE BRANCHE
git branch -m/--move [<oldbranch>] <newbranch> Si oldbranch n'est pas donné, renomme la branche courante
Si une branche porte déjà le nom newbranch, il faut forcer le renommage avec -m/--move -f/--force ou simplement -M.
EFFACER UNE BRANCHE
* Effacer une branche locale
git branch -d/--delete old_feature
Pour éviter la perte de commits, git n'autorise l'opération uniquement si old_feature a été mergée à son upstream branch (origin/old_feature) où à la branche courante s'il ne lui en a pas été défini. Sinon il faut forcer la suppression avec -d/--delete -f/--force ou simplement -D
* Effacer une (local) remote tracking branch (ex: origin/old_feature)
git branch -d/--delete -r/--remotes origin/old_feature
N'a de sens que si old_feature n'existe plus sur le dépôt distant (sinon on risque de la réimporter lors de git fetch / de synchronisations ultérieures)
### WIP (cf. aussi prune de git remote)
* Effacer une branche sur le dépôt distant
### WIP
CREER UNE BRANCHE
On se préoccupe des --track / --no-track plus tard (que se passe-t-il par défaut ?) Apparemment créer une branche au niveau d'une remote-tracking branch implique que l'upstream branch est setté implicitement ?

git branch new_feature : créer une nouvelle branche, un nouveau pointeur au niveau du commit courant (HEAD)

Mentionner git checkout -b [-f] <new-branch> [<start-point>]

Remarque si on précise explicitement un startpoint différent de HEAD git branch new_feature 3rg8jn
* Si la branche n'existe pas encore, créer une nouvelle branche / pointeur au niveau du commit désigné comme point de départ
* Si la branche existe déjà, celà revient à déplacer le pointeur de la branche vers <start-point>, action pouvant entrainer des pertes de commits et devant alors être forcée avec -f/--force. Un git resert --hard semble produire les mêmes effets (HEAD et branch sont déplacés). Les remote-tracking branches sont en revanche inamovibles pour l'utilisateur. Afin qu'elles reflètent toujours fidèlement l'état du dépôt distant, c'est Git qui se charge de les déplacer à chaque synchronisation avec celui-ci. Corrolaire :  A remote-tracking branch should not contain direct modifications or have local commits made to it.

Remote-tracking branches:
Elles ont toutes un nom de la forme <remote>/<branch>. Ex: origin/master. Sur le dépôt local, on parle de remote(-tracking) branch pour origin/master et de local branch pour master.

Définition d'une upstram branch pour une branche locale
Paramètres qui vont permettre de savoir quoi faire quand on appelle les commandes git fetch / git pull (et git push ?) depuis ou sur cette branche :
Apparemment cela passe concrètement par la définition des attributs/configurations suivantes pour la branche considérée :
* remote
* merge : utile à git pull, c'est la référene passée à git merge (?)
"so that git pull will appropriately merge from the remote-tracking branch." "it directs git pull without arguments to pull from the upstream when the new branch is checked out."

https://git-scm.com/docs/user-manual.html#remote-branch-configuration
git fetch / pull : que se passe-t-il si on leur passe une branche qui n'existe pas en local, qu'est ce qui est créé automatiquement par défaut?
git push : que se passe-t-il si on leur passe une branche qui n'existe pas sur le dépôt distant, qu'est ce qui est créé automatiquement par défaut ?
https://git-scm.com/docs/user-manual.html#fetch-fast-forwards
(we’ve seen branches and tags are special cases of references
https://git-scm.com/docs/user-manual.html#Documentation/user-manual.txt-aiddefremotetrackingbrancharemote-trackingbranch
remote-tracking branch
A ref that is used to follow changes from another repository. It typically looks like refs/remotes/foo/bar (indicating that it tracks a branch named bar in a remote named foo), and matches the right-hand-side of a configured fetch refspec. A remote-tracking branch should not contain direct modifications or have local commits made to it.

https://git-scm.com/docs/user-manual.html#dangling-objects
unreachable object
An object which is not reachable from a branch, tag, or any other reference.
current branch = checked-out branch (Terminologie)
dangling object
An unreachable object which is not reachable even from other unreachable objects; a dangling object has no references to it from any reference or object in the repository.
https://stackoverflow.com/questions/40025328/does-git-gc-execute-at-deterministic-intervals
https://stackoverflow.com/questions/28246216/git-when-does-git-perform-garbage-collection

Tag : It’s like a branch reference, but it never moves — it always points to the same commit but gives it a friendlier name.

Différence upstream branch et remote-tracking branch
L'upstream branch est une propriété d'un branche du dépôt local (qui peut ne pas en avoir) il s'agit du nom de la branche distante suivie (tracked) par une branche locale donnée
Remote-tracking branch : il s'agit d'une branche présente sur le dépôt local (au sens d'un pointeur) qui permet de refléter dans le dépôt local, l'état d'une branche du dépôt distant à la dernière synchronisation (via un git fetch). Les remote-tracking branches donnent à voir l'état des l'upstream branches des branches locales à la dernière synchronisation.

git fetch
Par défaut:
* Si aucune référence n'est passée : git fetch (si aucun remote n'est passé, on utilise celui de l'upstream branch de la branch courante si cette dernière en défini sinon origin) ou git fetch origin, toutes les remote-tracking branch du dépôt local sont mises à jour : récupère les commits et déplace les remote-tracking branches
* Si une ou plusieurs références sont passées, git fetch ne récupèrera que le contenu des branches précisées et n'updatera que les remote-tracking branches correspondantes.

fetch will not update local branches (which track remote branches); if you want to update your local branches you still need to pull every branch.
fetch will not create local branches (which track remote branches), you have to do this manually.

Remarque : git fetch origin master est équivalent à ```git fetch origin master:```, on demande à récupérer le contenu de la branche master de origin mais ne précisons pas quelle branche locale doit recevoir le produit du fetch. La branche de destination sera alors déduit de la liste des remote-tracking branches, origin/master dans la plupart des cas correspondant à notre exemple.

Concernant les tags: tout tag du dépôt distant absent du dépôt local est ajouté à ce dernier lors d'un git fetch. Cf. les options -n/--no-tags et -t/--tags.

Pruning : si l'option -p/--prune est choisie, les remote-tracking branch suivant des branches n'existant plus sur le dépôt distant seront surprimmées avant le fetch. Les tags ne sont pas concernés (cf. documentation pour le pruning des tags). Git a en effet par défaut la propriété de conserver toutes les données à moins que le contraire n'ai été explicitement demandé : on peut ainsi se retrouver à conserver en local des remote-tracking branch ayant été supprimées du dépôt distant au prix d'accroitre inutilement la taille du dépôt local et de dégrader la persformance de certaines opérations. Remarque : on est pas obligé de le faire en même temps qu'un fetch : git remote prune origin

Cas de git fetch non fast-forward : peut être nécessaire de forcer le fetch (-f/--force). Exemple : quelqu'un a rebase une branche du dépôt distant. Ne semble pas affecter l'update automatique des remote tracking branches par défaut (refspecs avec un +).

Pour se créer une branche locale suivant une branche du remote, le plus simple est de la créer en utilisant la remote-tracking branch comme startpoint (qui a pour effet d'automatiquement la définir comme l'upstream branch de la branche qu'on est en train de créer): git branch / git checkout -b new-branch origin/new-branch. origin/new-branch est sur le dépôt local mais on ne peut pas travailler dessus (c'est une remote-tracking branch et non une branche), on est obligé de créer manuellement la branche qui nous permet de travailler dessus (sans oublier de bien définir l'upstream branch de celle-ci). Apparemment on a aussi git checkout --track origin/new-branch. Short cut du short cut : si la branche n'existe pas en local et correspond à un nom de branche présent sur le remote : git checkout new-branch se charge de la créer, set l'upstream branch et en fait la branche courante. Si on avait déjà créé la branche en local mais d'une façon où l'upstream branch n'a pas été définie : git branch -u/--set-upstream-to origin/new-branch (rare).

git pull
pas grand chose à ajouter, étant la somme de git fetch et git merge, on peut lui passer les argument propres à ces deux commandes pour contrôler l'un ou l'autre des deux aspects.

Utilisé sans arguments avec une branche courante pour laquelle une upstream branch est définie : git récupère de l'upstream branch le repo à fetcher, fetch l'ensemble des remote-tracking branches et merge à la branche courante celle précisée dans la définition de l'upstream branch (origin/branch par défaut).

Avec arguments, on ne commentera que la forme git pull origin feature qui est équivalente à git fetch origin (on fetch l'ensemble des remote-tracking branches (?)) suivie de git merge origin/feature.

Histoire du checkout : la première forme semble garantir qu'on ne mergera dans notre branche que celle adaptée à la branche courante. La seconde forme offre la possibilité que la branche à récupérer et merger soit différente de celle précisée dans la définition de l'upstream branch (? à confirmer). La première forme semble préférable.

This command (git pull) will fetch changes from the remote branches to your remote-tracking branches origin/*, and merge the default branch into the current branch.

More generally, a branch that is created from a remote-tracking branch will pull by default from that branch.

Par défaut le merge du pull est ff.

git push
Si la branche locale n'existait pas sur le remote, il est automatiquement créé une remote-tracking branch qui est du même coup définie comme upstream branch pour notre branche locale. Même chose dans l'autre sens si git clone. globalement qu'est ce qui créé les branches locales avec upstream branch : git clone, git checkout (et git branch).

git push simple : le repo est récupéré de l'upstream branch, sinon origin. La branche de destination est récupérée de la définition l'upstream branch, sinon Git se rabat sur un comportement par défaut (HEAD - branche courante).

N'ayez pas peur : git push ne push pas tout (il faut être plus explicite pour cela git push --all)

Effacer des branches distantes
Depuis git 1.7.0
git push --delete origin branch1 branch2

Doit sûrement effacer la branche sur le remote et la remote-tracking branch associée. La branche locale reste ensuite à supprimer.
https://stackoverflow.com/questions/2003505/how-do-i-delete-a-git-branch-both-locally-and-remotely

plus facile que git push origin :branch après laquelle il faut là encore supprimer la branche locale (git branch -d) et peut être même la remote tracking branch (git fetch --prune) quoique normalement non, le git push met aussi à jour la remote tracking branch et là il la met à jout à rien.
Possible qu'il faille forcer si la branche n'est pas mergée sur le dépôt distant.
