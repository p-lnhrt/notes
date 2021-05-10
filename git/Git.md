# Git
## Aide
L’aide accessible pour chaque commande via la commande ```git help <command_name>``` sous la forme d’une page HTML affichée dans le navigateur est aussi disponible [en ligne](https://git-scm.com/docs).



Cette aide s’ajoute à la ressource Pro Git 2nd Edition (2014) également disponible en ligne en [anglais](https://git-scm.com/book/en/v2) et en français.



## 1. Git : un système de contrôle de versions décentralisé
Git est un système de contrôle de versions décentralisé (*decentralized version control system* - DVCS). Dans un système de contrôle de versions centralisé (dont Subversion ou Perforce sont les plus connus), l’ensemble des versions des différents fichiers d’un projet sont stockées sur un unique serveur auquel différents clients viennent se connecter. L’un des principaux désavantages est que cet unique serveur constitue un *single point of failure*. S’il est hors-ligne pendant quelques heures, personne ne peut collaborer ou sauver ses changements.
De même, si le disque dur du serveur venait à être corrompu sans que les sauvegardes appropriées aient été faites, toutes les données du projet sont alors irrémédiablement perdues.



Dans un système décentralisé (comme Git, Mercurial ou encore Bazaar), les clients n’extraient, ne copient, ne chargent (*check out*) pas seulement la dernière version d’un fichier mais dupliquent (*clone*) intégralement le dépôt distant (*remote repository*), c’est à dire l’ensemble des fichiers ainsi que l’historique de leurs versions. Chaque extraction depuis le dépôt distant est aussi l'occasion de sauvegarder les données du dépôt distant en local sur le poste de chaque client. En cas de défaillance du serveur distant sur lequel l’ensemble des fichiers du projet sont stockés, il suffira de copier les données de l’un des clients pour restaurer les fichiers du projet avec un minimum de pertes. Les systèmes décentralisés gèrent aussi particulièrement bien le fait que des clients peuvent travailler sur plusieurs dépôts en même temps. L’aspect décentralisé implique que l’essentiel des opérations avec Git sont menées en local puisque l’intégralité du projet est stocké sur le disque. Cela peut être bien plus rapide qu’avec les systèmes centralisés pour lesquels les opérations exignent des échanges avec un serveur distant avec une latence parfois importante. Mieux encore, cela veut également dire qu’on peut très facilement travailler hors-ligne.



L’originalité de Git par rapport d’autres systèmes provient de sa façon de stocker les données. Traditionnellement, les VCS sont *delta-based*, l’information stockée pour un projet correspond à chaque fichier ainsi que l’ensemble des modifications qui leur ont été apportées au cours du temps (delta). La somme du fichier d’origine et de tous ses deltas donne la dernière version d’un fichier donné.



Git ne procède pas comme cela. Dans Git, l’évolution d’un projet est pensée et stockée comme une suite d’instantanés (*snapshots*). A chaque point dans le temps où a été fait une "sauvegarde" (*commit*), Git associe un objet stockant un instantané du projet. Git stocke l'ensemble des fichiers du *working directory* (ainsi que sa structure) dans un objet *commit*. Evidemment, si certains fichiers n’ont pas changé depuis la version précédente, ces derniers ne sont pas à nouveau stockés : on préférera une référence vers le dernier fichier identique réellement stocké. Git gère également bien l’intégrité des fichiers qu’il stocke. Dans Git tout est vérifié par une somme de contrôle avant d’être stocké (*check-summed*), l’objet stocké étant ensuite indexé avec cette somme de contrôle unique (40 caractères hexadécimaux). Dans la base de donnée Git, on se réfère à un objet non pas avec son nom (ex : nom_de_fichier) mais avec une clé unique qui est est sa somme de contrôle.



La génération des sommes de contrôle est réalisée par une opération appelée empreinte SHA-1 (*SHA-1 hash*). La clé de 40 caractères hexadécimaux est générée à partir du contenu du fichier ou de la structure du répertoire considéré. Il est ainsi impossible de modifier le contenu d’un fichier ou d’un répertoire sans que Git s’en aperçoive : on ne peut pas perdre ou corrompre le contenu d’un fichier sans que Git ne le détecte.



La majorité des actions Git ne font qu’ajouter des données à la base. Il est rare ou difficile de supprimer et donc d’avoir la possibilité de perdre accidentellement des données. Il est donc d’autant plus rare de faire faire au système une opération irréversible où des données seraient perdues. Toutefois et comme avec n’importe quel VCS, tout changement non encore validé peut être perdu, mais une fois qu’un instantané est validé (*once a snapshot is committed*), il est très difficile de perdre irrémédiablement ces données. Cela est d’autant plus vrai qu’on synchronise (*push*) régulièrement notre base de données locale avec un dépôt distant (*remote repository*).



## 2. Démarrer un dépôt Git
Il faut déjà distinguer deux éléments : le répertoire de travail courant local (*working directory*) qui est suivi par le VCS et le dépôt distant (*remote depository*) où l'historique du projet est mis à la disposition de tous ceux qui y ont accès. Dans Git, l'historique d'un projet prend la forme d'un ensemble d'instantanés, chacun pointant vers le où les instantanés à partir du ou desquels il a été directement créé. Un instantané correspond à une image de la structure du répertoire de travail ainsi que les versions de tous les fichiers suivis par Git s'y trouvant. L'historique d'un projet est donc un graphe (pas forcément acyclique) dont chacun des noeuds est un instantané. Ce graph ayant généralement une structure arborescente partant du premier instantané du projet et on appelle souvent branche des ensembles d'instantanés consécutifs.



*Remarque* : En théorie le *remote repository* peut aussi se situer chez le même hôte que le *working directory*.



On peut démarrer un dépôt Git de deux façons : soit en initialisant le dépôt dans le répetoire de travail local avec ```git init```, soit en clonant le dépôt distant sur notre poste local à l'aide de ```git clone```.



*Remarque* : Quand on lance la commande ```git init``` dans un répertoire existant (ou pas), Git y crée le répertoire .git dans lequel Git stocke et manipule tout ce dont il a besoin. A l’intérieur de ce répertoire, on trouve en particulier :
- Le fichier config qui contient toutes les options de configuration du dépôt.
- Les répertoires refs où sont stockées les références (terme englobant branches, étiquettes, *remotes*).
- Le répertoire objects qui stocke le contenu de la base de données.
- Le fichier HEAD qui pointe vers la branche courante.
- Le fichier index où Git stocke les références des fichiers qui serviront à construire le prochain *commit* (aussi désigné comme *staging area* en anglais).



En cas d'initialisation à partir du dépôt distant, un utilisateur va tout d’abord dupliquer (*clone*) l’ensemble de son contenu dans son répertoire de travail local. Le clonage complet peut n’intervenir qu’une fois, on récupère alors ensuite régulièrement (*fetch*) les éléments ajoutés au dépôt distant par d’autres et qui pourraient nous manquer à l'aide de la commande ```git fetch```. Il n'y pas de synchronisation automatique. Si de nouveaux *commits* sont ajoutés à l'historique du projet, il est nécessaire de faire un ```git fetch``` pour les récupérer.



## 3. Un fichier vu par Git
On suppose pour l'instant que l’utilisateur n’ajoute pas de fichiers, l’ensemble des fichiers du répertoire courant coïncide avec celui du dépôt distant. On veut signifier par là que tous les fichiers du répertoire courant sont suivis (*tracked*) par le VCS, c'est à dire que ce dernier surveille si des mofications leur ont été apportées ou non. Après avoir apporté des modifications, on souhaite les intégrer à la base de donnée locale du VCS. Intégrer ces modification à la base de donnée revient à les valider (*commit*), à créer un nouvel instantané du projet dont font alors partie les fichiers modifiés. On dit que des modifications sont validées (*committed*) une fois qu’elles sont stockées en sécurité dans la base de données locale du VCS.



Git laisse la possibilité de choisir lesquels des fichiers modifiés on souhaite intégrer à la prochaine validation (*commit*). Les fichiers choisis sont ajoutés à un fichier intermédiaire appelé *staging area* - zone d’indexation ou index - qui pour simplifier, recense l'ensemble des fichiers, modifiés ou pas qui serviront à construire la prochaine validation. Un fichier suivi (*tracked*) par le VCS passe ainsi par trois états en cas de modification :
- Fichier modifié (*modified*) : le fichier a été modifié mais les changements ne sont pas encore intégrés à la base de données locale du VCS
- Fichier indexé (*staged*) : le fichier modifié est marqué **dans sa version actuelle** pour faire partie du prochain instantané du projet (si le fichier est à nouveau modifié après avoir été indexé, la validation n’intégrera que les premières modifications).
- Fichier validé (*committed*) : les modifications indexées sont intégrées à la base de données locale du VCS (appelée aussi .git *directory* / *repository*) faisant partie d’un nouvel instantané du projet.



On peut ajouter un quatrième statut aux trois status possibles d’un fichier dans Git : non-suivi (*untracked*). On peut souhaiter que tous les fichiers du répertoire du projet ne voient pas leur modifications suivies (fichiers log, fichiers temporaires, etc.). On peut ainsi retirer des fichiers de la liste des fichiers suivis (l'index) ou plus largement les ajouter à la liste des fichiers que Git doit ignorer (automatiquement ne pas suivre) contenue dans le fichier .gitignore.



Pour chaque statut il existe une opération permettant d’y ajouter ou d’en retirer un fichier :
- Pour être suivi, un fichier est directement indexé (*staged*). Une fois la validation (*commit*) effectuée, son statut passe à suivi-non-modifié.
- De suivi-non-modifié, on peut soit cesser de suivre le fichier (*remove*), son statut passant à non-suivi (*untracked*), soit le modifier, son statut passant à modifié (*modified*).
- Une fois un fichier répertorié comme modifié, il doit encore être indexé (*staged*) puis validé (*committed*) afin de pouvoir revenir dans l’état suivi-non-modifié. On peut également revenir à l'état suivi-non-modifié en écrasant le fichier modifié avec son ancienne version (*reset*), les modifications étant irrémédiablement perdues au passage.



#### *Remarque* : alias de commandes Git
A chaque transition correspond une commande cependant certaines peuvent se montrer un peu longue ou peu transparentes. On peut alors décider d'utiliser un alias.



Git permet la création d’alias pour des commandes de notre choix ce qui permet de rendre son utilisation plus fluide. Par exemple, on peut créer une commande plus courte et de même effet que ```git commit``` comme par exemple ```git ci```. Un tel alias est créé grâce à la commande suivante : ```git config [--system|--globlal| ] alias.ci commit```



Autre exemple : on peut créer une commande ```git unstage``` avec la commande suivante : ```git config [--system|--globlal| ] alias.unstage ‘reset HEAD --’```



### 3.1 Tracked vs Untracked
En réalité, le caractère suivi ou non-suivi d’un fichier par Git (et non présent dans le fichier .gitignore) dépend de la présence ou non du fichier dans l’index. Un fichier absent de l’index n’est pas suivi par Git.
Ainsi pour que Git arrête de suivre un fichier, il faut le supprimer de l’index. Cela se fait à l’aide de la commande ```git rm```. On peut distinguer les principaux cas d’usage suivant :
- ```git rm <file_name>``` : le fichier est supprimé de l’index, il n’est plus suivit et ne fera pas partie du prochain *commit*. Le fichier est également supprimé physiquement du *working tree*.
- ```git rm - -cached <file_name>``` : le fichier est seulement supprimé de l’index et donc plus suivi par Git, il n’est pas supprimé du *working tree* et est donc conservé sur le disque.
- ```git rm –f``` : Même effet que ```git rm``` mais force l’exécution de la commande. Nécessaire si le fichier à supprimer a subi des modifications qui ont été indexées. Cela évite les suppressions accidentelles.
On peut aussi supprimer manuellement le fichier du *working tree* mais il n’est alors pas supprimé de l’index. Un git status va alors montrer qu’il existe pour ce fichier des modifications encore non indexées (la modification étant qu’il a été supprimé). Il va donc falloir ajouter le fichier à l’index à l’aide ```git add``` afin qu’il en soit supprimé et qu’il ne soit plus suivi. Ce procédé étant assez contre-intuitif, préférer l’utilisation de ```git rm```.



Remarque : les fichiers non-suivis : Git doit faire comme s’ils n’existaient pas. Lorsqu’on checkout vers une autre branche, Git ne change que les fichiers suivis pour être conforme à l’instantané du projet pour les fichiers qu’il suit. Les fichiers non-suivis restent comme des constantes au milieu de ces changements d’environnement.



### 3.2 Renommer des fichiers suivis par Git
Les fichiers étant adressés par une clé calculée sur leur contenu, Git n’a pas moyen de savoir que les métadonnées du fichier comme son nom ont été modifiées. Si on renomme manuellement un fichier de Nom1 à Nom2, il va falloir supprimer Nom1 de l’index avec ```git rm Nom1``` et ajouter Nom2 à celui-ci avec ```git add Nom2``` de façon à ce que Git suive ce qu’il voit comme un nouveau fichier. La commande ```git mv Nom1 Nom2``` permet de faire cela en une seule commande. Là encore, pour ce genre d’opérations en apparence banales, il est recommandé de passer par les commandes Git appropriées.



## 4. Le *commit*
Quand on fait une validation (*commit*), Git crée et stocke un objet *commit* contenant un pointeur vers le contenu indexé (*staged*). L’objet contient également le nom, le mail et un message de l’auteur de la validation. L’objet contient aussi des des pointeurs vers les le où les *commits* parents (immédiatement précédents) : aucun pour le *commit* initial, un pour un *commit* normal, au moins deux pour un *commit* résultant en la fusion de deux branches.



On peut ensuite régulièrement synchroniser (*push*) la base de donnée locale du VCS avec le dépôt distant.



Un *commit* se caractérise par son empreinte SHA-1 faisant office d’identifiant unique, sa date, son auteur (avec son mail) et son message descriptif.



Dans Git tout le contenu est stocké sous forme d’objets *tree* ou *blob*. Une version particulière d’un fichier est stockée dans un *blob*, un *tree* permet lui de stocker des groupes de fichiers et donc de conserver une empreinte de la structure du répertoire de travail. Chaque objet est identifié de façon unique par sa somme de contrôle. Un objet *tree* consiste en une ou plusieurs entrées chacune consistant en un pointeur SHA-1 (une somme de contrôle), une référence vers un *blob* ou un autre *tree*. 
Remarque : Quand on demande à Git de se replacer au niveau d’un instantané, d’un commit particulier, typiquement lors d’un changement de branche, Git rajoute, modifier ou supprime automatiquement des fichiers du répertoire courant suivant les besoins, de façon à ce qu’il retrouve un état identique à celui du moment du *commit*.
D’un point de vue plus bas niveau, Git gère les fichiers suivis à l’aide de quatre objets fondamentaux, chaque instance de ces types étant identifiée de façon unique par une empreinte SHA-1 calculée sur son contenu (Git étant designé comme un *content-addressable filesystem*):
- *Annotated tags* qui pointent vers des *commits*
- *Commits* qui pointent vers le *root directory tree* du projet
- *Trees* qui représentent des répertoires et sous-répertoires du *cwd*
- *Blobs* qui représentent des fichiers (suivis) du répertoire du *cwd* et de ses sous-répertoires.



De nombreuses commandes acceptent des identifiants spéciaux permettant de se référer à un *commit* ou une un arbre de répertoires (*tree*). Ces identifiants sont dits *commit-ish* s’ils permettent d’accéder in fine à un *commit*. Ils sont dits *tree-ish* s’ils permettent d’accéder in fine à un objet *tree*. Comme un *commit* pointe vers un objet *tree*, tout indentifiant *commit-ish* est aussi *tree-ish*. L’inverse n’est cependant pas vrai, les objets *tree* ne pointant pas vers des objets *commit*. Remarque : l’identifiant d’un *annotated tag* est *commit-ish* et donc *tree-ish* (un nom de branche est ainsi *commit-ish*). Un identifiant purement *tree-ish* renvoie directement à un tree sans passer par un objet commit.
Dans la documentation, il faut comprendre :
- ```<tree>``` : le nom d’un objet *tree*
- ```<commit>``` : le nom d’un objet *commit*
- ```<tree-ish>``` : le nom d’un objet *tree*, *commit* ou *tag*; la commande voulant in fine opérer sur un objet *tree*.
- ```<commit-ish>``` : le nom d’un objet *commit* ou *tag* : la commande voulant in fine opérer sur un objet *commit*.



Se référer à ces différents objets utilise parfois une syntaxe propre à Git. Typiquement, utiliser les séparateurs habituels pour un chemin ne va pas marcher (```master:foo``` fonctionne mais pas ```master/foo``` pour se référer au répertoire foo). Résumé des syntaxes tiré de https://stackoverflow.com/questions/4044368/what-does-tree-ish-mean-in-git.



### 4.2 Conserver son travail en l'état sans *commit* : le remisage (*stashing*)
Il arrive qu’il faille aller travailler sur une autre branche du projet ou simplement mettre le projet en pause temporairement, il est très probable que nos travaux en cours soient alors inachevés. Git permet de sauvegarder notre *working directory* tel quel (*dirty*), à l’opposé de ce qu’il serait au moment d’un *commit* (*clean*). On dit que notre *working directory* est alors remisé (*stashed*). Le remisage (commande ```git stash [push]``` ou anciennement ```git stash [save]```) va conserver tous les changements non-commités et même si on le souhaite, les fichiers non-suivis (option ```--include-untracked```) voire même aussi les fichiers normalement ignorés (option ```--all```). Si ces fichiers normalement non-suivis sont conservés, Git les supprime ensuite du *working directory* comme le ferait ```git clean``` pour «revenir à un *clean working directory*».
Git stocke alors un instantané du *working directory* et éventuellement de l’index au moment du remisage dans un objet *stash*. Si on souhaite également sauvegarder l’état de l’index à ce même moment pour retrouver un espace de travail identique à la restauration, utiliser l’option ```--keep-index``` de ```git stash push```. Il peut aussi être utile d’inclure à la manière d’un *commit*, un message descriptif (optionnel) à l’aide de l’option ```-m```.
Une fois la commande exécutée, le *working directory* et l’index sont restaurés conforme au ```HEAD``` *commit*. Un *stash* est stocké et restauré au niveau du commit ou a eu lieu le remisage. Un *stash* est restauré à l’aide de la commande ```git stash apply [<stash>]``` (par défaut restaure le dernier *stash* enregistré, sinon choisir le *stash* parmi la liste de ceux disponibles. Ex : ```stash@{2}``` pour le 2e objet stash de la liste) éventuellement accompagnée de l’option ```--index``` pour restaurer l’index et pas seulement les fichiers modifiés.
S’il n’est plus utile, on peut supprimer un *stash* avec ```git stash drop [<stash>]``` (par défaut le dernier créé) ou ```git stash pop```. On accède à la liste des *stashes* à l’aide de ```git stash list``` et peut les inspecter individuellement à l’aide de ```git stash show [<stash>]```.
Un *stash* est restauré au niveau du *commit* où il avait été créé : après restauration du *stash*, ```HEAD``` pointe vers ce *commit*. Il est possible que depuis la création, le travail se soit poursuivi sur la branche. Continuer le travail depuis le *stash* va demander de créer une nouvelle branche. Ceci peut être fait au moment de la restauration du *stash* avec ```git stash branch <branch_name> [<stash>]```. En plus de créer une nouvelle branche et de restaurer le *working directory* et l’index, cette commande va aussi automatiquement supprimer le *stash*.



## 5. Le fichier d’index
Le fichier d’index (en anglais *staging area*, parfois aussi appelé cache ou cache du répertoire) est un fichier binaire conservé dans .git/index qui correspond à une liste de chemins de fichiers avec notamment pour chacun, les permissions, l’empreinte SHA-1 du *blob* associé, etc. La commande ```git ls-files --stage``` permet de visualiser une partie du contenu de l’index dans la console. L’index contient toutes les informations nécessaires à la génération d’un objet *tree* lors du lancement de la commande ```git commit```. Cet objet étant du même coup ajouté à la base de données. Le *commit* généré pointera vers l’objet *tree* construit à partir de l’index.



Le *tree* du prochain *commit* étant généré à partir de l’index, on comprend dès lors que ce fichier ne contient pas uniquement les références des fichiers ayant été modifiés et indexés avec la commande ```git add```. L’index contient donc en fait les références de tous les fichiers suivis (*tracked*). L’index est initialisé avec le contenu du dernier *commit*, ainsi la commande ```git ls-files --stage``` ne retourne pas rien après un commit comme on pourrait s’y attendre en considérant l’index comme uniquement la liste des fichiers modifiés. La commande retourne la liste des fichiers du dernier *commit*.
Quand un fichier est modifié et indexé, sa version modifiée est copiée dans le cache et la référence à cette copie prend la place de celle à l’ancienne version dans l’index.
Ce phénomène est à l’origine du fait que si on modifie à nouveau le fichier sans l’indexer et qu’on lance la commande ```git status```, le même nom de fichier va apparaître dans «*Changes to be commited*» et «*Changes not staged for commit*» : il existe deux versions différentes du même fichier différentes du dernier commit, une version mis en cache et référencée dans l’index, une seconde située dans le working directory (plus généralement appelé working tree dans git. On peut distinguer *working tree* de *working directory* dans l’idée que le second ne fait au sens strict référence qu’à un seul répertoire. Le *working tree* désigne l’ensemble de l’arborescence dont le *working directory* est la racine. En effet, le dépôt Git est initialisé dans un répertoire mais celui-ci peut consister en une arborescence. La modification d’un fichier dans cette arborescence sera prise en compte, Git ne s’arrête pas strictement au *working directory* où il a été initialisé. Git couvre l’ensemble des fichiers pour lesquels le répertoire où a été initialisé le dépôt est une racine commune (on dira que ces fichiers sont situés dans le *working tree*).



Git parle du mot « cache » comme d’un terme obsolète pour désigner l’index. Il est toutefois révélateur de ce qui se passe en interne lorsqu’on « ajoute un fichier à l’index ».
Quand on se réfère à un fichier dans Git, cela peut se faire de 4 manières :
- La copie du fichier correspondant à la dernière version *committed*, elle est stockée dans la base de donnée Git (immutable)
- La copie du fichier correspondant à la dernière version *committed* située dans le *working tree*. Ce fichier est écrasé après modifications.
- La version courante du fichier sur le disque (situé dans le *working tree*), après le dernier *commit*, son contenu coïncide avec celui du fichier stocké dans la base après le *commit*.
- La copie mise en cache par l’index 



On comprend ainsi mieux la syntaxe de la commande ```git checkout -- <file name>```. Cette commande permet d’habitude de changer branche mais ici la présence de ```--``` change le comportement de la commande. Dans ce mode de fonctionnement, le fichier présent dans le *working tree* est remplacé par celui de même référence (chemin) situé dans l’index. Ainsi, si des modifications n’ont pas été indexées, celles-ci seront écrasées par les dernières modifications indexées. C’est pour cela que cette commande est présentée dans la sortie de ```git status```, comme permettant de «*discard changes in working directory*» (car elle a précisément cet effet) pour les fichiers avec «*changes not staged for commit*».



## 6. L'historique du projet : branches et étiquettes
L’historique des *commits* associés à un *repository* est consultable avec la commande ```git log``` (en ayant préalablement fait du repository le *cwd*).



### 6.1 Faire d'un *commit* particulier un repère : l'étiquette (*tag*)
Une étiquette est en fait une référence, un pointeur (ex : ```HEAD```, les étiquettes de branche) vers un *commit* particulier. Rend le travail plus fluide car on peut ainsi se référer facilement à un *commit* avec un alias et non une clé SHA-1. Une branche est en réalité une étiquette pointant vers le dernier *commit* d’une *line of work* (même si le terme branche désigne aussi par abus de langage, l’ensemble de ses *commits*. L’étiquette de branche est avancée à chaque nouveau *commit*. L’étiquette d’un *tag*, annoté ou simple ne bouge pas, il pointe invariablement vers le même *commit* lui donnant juste un nom plus pratique. Dernier type de référence : les *remote references*.



Attention, la commande ```git push``` ne synchronise pas les étiquettes créées localement. Pour le faire, il faut explicitement synchroniser (*push*) les étiquettes (de façon similaire à ce qu’on ferait pour synchroniser des branches distantes) : ```git push origin <tag_name>```.
Git permet d’étiqueter certains instantanés comme étant d’un intérêt particulier : v0.1, v1.0, v2.0, etc. Cela se fait à l’aide de la commande ```git tag <tag name>``` Sans options, on crée ce qu’on appelle une étiquette légère (*lightweight tag*). Ce cas correspond juste à un pointeur vers un instantané (*commit*) spécifique, à une somme de contrôle particulière stockée dans un fichier. En ajoutant d’autres options et notamment un message descriptif (avec ```-m```), on crée une étiquette annotée (*annotated tag*). Une étiquette annotée est en revanche stocké comme un objet à part entière dans la base Git avec sa somme de contrôle, le nom et le mail de son créateur ainsi qu’un message descriptif. Par défaut c’est la dernière validation (*commit*) qui est étiquetée (*tagged*). Si on souhaite étiqueter une validation passée, il suffit de passer en argument tout ou partie de sa somme de contrôle.
Pour visualiser l’instantané (*commit*) associé à une étiquette particulière, utiliser la commande : ```git show <tag_name>```.



*Remarque* : Comment Git sait-il quel est le *commit* courant : il existe une référence spéciale pointant vers le *commit* courant : ```HEAD``` (en réalité ```HEAD``` pointe vers une étiquette de branche qui elle-même pointe vers un *commit*).



Différence (lightweight) tag / branche
Tous deux ont en commun de n’être qu’un pointeur vers un *commit* particulier. Toutefois, à chaque nouveau *commit*, le *tag* de la branche est « avancé », pointe vers le nouveau *commit* alors que le *tag* (*annotated* ou *lightweight*) est immutable et n’est pas déplacé.



### 6.2 Les branches :



Rappel : ```git branch``` crée une nouvelle branche mais ne nous place pas dessus (```git branch``` ne déplace pas ```HEAD```). On se place sur une nouvelle branche via ```git checkout``` qui entre autres choses change la référence du pointeur de ```HEAD```.



Remarque : quand on supprime une branche non-fusionnée (non-recommandé), on perd tous les *commits* jusqu’au raccord. On ne supprime pas seulement le pointeur laissant simplement une suite de *commits* sans pointeur à leur extrémité, les *commits* sont supprimés, la branchée coupée.



#### 6.2.1 Les branches distantes (*remote branches*)
Le projet peut continuer à faire sa vie sur le serveur, à chaque ```git fetch origin```, Git va placer des références là où se trouve le projet sur le serveur. Ces pointeurs ne sont en revanche ni modifiables ni déplaçables par l’utilisateur et ne seront mis à jours et éventuellement déplacés qu’au prochain *fetch*. Ils sont comme un marque-page pour montrer à l’utilisateur où se trouve le projet sur le *remote*. Ils sont de la forme ```<remote>/<branch>```. Si on a divergé depuis le serveur (ex : nos master ont divergé). Ou si on a une branche en moins, le processus de récupérations nous ajoute les éléments manquants sous forme de nouvelles branches. Ce principe fonctionne quel que soit le nombre de *remotes* depuis lesquels on *fetch*. Attention une *remote reference* est immutable, on ne peut pas directement travailler sur une branche récupérée du serveur (et qu’on n’avait pas auparavant). Pour ce faire, il faut soit fusionner la *remote branche* sur une de nos branches locales et poursuivre le travail à partir de là, soit on crée une nouvelle branche basée sur la *remote branch* à l’aide de ```git checkout```. Le processus crée automatiquement une *tracking branch*.



#### 6.2.2 Suivre l’état du dépôt distant : les *remote references*
Les ```remote references``` sont des références locales permettant de suivre l’état de branches du dépôt distant. Quand on ```clone``` ou récupère de nouvelles informations sur le dépôt distant (```fetch```), Git place dans nos données locales un *tag* immutable, faisant en quelque sorte office de marque-page, qui pointe vers l’endroit où en est le travail sur le serveur. Ce *tag* n’est déplacé que lors d’une synchronisation avec le dépôt distant. Le nom du *tag* est de la forme ```<remote>/<branch>```. Le suivi de branches distantes n’est pas limité à un seul dépôt.



Pour synchroniser notre travail avec le dépôt distant (pourvu qu’on ait les droits en écriture), il faut le faire branche par branche (ce qui permet d’avoir des branches de travail en local qu’on ne partage pas avec les autres) à l’aide de la commande ```git push <remote> <branch>``` (si les branches n’ont pas le même nom sur en local et sur le dépôt distant, on utilise la syntaxe : ```git push <remote> <local_branch_name>:<remote_branch_name>```).



Attention : le ```git push``` fonctionne uniquement si on a les droits en écriture sur le dépôt distant et si personne d’autre n’a *push* sur la même branche depuis notre dernier *clone*/*fetch+merge*. Dans le cas où la 2e condition ne serait pas vérifiée, il faut récupérer le travail de nos collègues (*fetch*), l’intégrer au notre (*merge*) avant de faire un nouveau ```git push```.



Attention : quand on recueille (*fetch*) de l’information du serveur et qu’on récupère une nouvelle branche qu’on avait pas auparavant, on ne peut pas directement travailler dessus car on a juste un pointeur (*remote reference*) immutable. On a alors deux solutions, soit fusionner cette nouvelle branche à notre travail (```git merge <remote>/<branch>```), soit nous créer une branche locale de même nom sur laquelle on peut travailler (```git checkout –b <local_name> <remote>/<branch>```). Dans cette opération, la nouvelle branche créée va aussi automatiquement traquer ```<remote>/<branch>``` (appelée *upstream branch*).



Plus généralement, ```git fetch``` ne modifie jamais le *working directory*. Les nouvelles informations provenant du dépôt distant sur la branche sur laquelle on travaille ne sont pas intégrées à celle-ci. Pour ce faire, il faut fusionner l’*upstream branch* à notre branche de travail avec ```git merge <remote>/<branch>```. En créant un nouveau *commit*, cette opération aura pour effet de modifier le *working directory*. Nos fichiers de travail intégreront alors les derniers ajouts en provenance du dépôt distant. La commande ```git pull``` permet d’enchaîner les deux opérations ```git fetch``` et ```git merge```.



#### 6.2.3 Lier une branche locale à son alter ego dans le dépôt distant pour une synchronisation plus fluide : les *tracking branches*
En liant une branche locale à son alter ego dans le dépôt distant on peut s’économiser de taper des informations lors d’opérations de synchronisation (*fetch*/*push*). La branche locale est appelée *tracking branch* et la branche distante l’*upstream branch*. Ainsi, si notre branche de travail courante est une *tracking branch*, on peut se contenter de taper ```git pull``` / ```git push``` sans plus d’informations, Git saura déjà avec quelle branche de quel dépôt distant se synchroniser.
La façon la plus fréquente de créer une tracking branch est d’utiliser la commande ```git checkout  -b <local_branch_name> <remote>/<remote_branch_name>```. Il existe plusieurs commandes équivalentes et plus courtes :
- ```git checkout --track <remote>/<remote_branch_name>``` : créé une *tracking branch* ayant le même nom que l’*upstream branch*.
- ```git checkout <remote_branch_name>``` : créé une *tracking branch* ayant le même nom que l’*upstream branch* ```<remote_branch_name>``` s’il n’existe déjà pas de branche de même nom dans notre projet local et si l’*upstream branch* est la seule à s’appeler ```<remote_branch_name>``` parmi tous les dépôts distants avec lesquels on travaille.



Pour lier une branche distante à une branche locale déjà existante (et qui est aussi notre branche courante), utiliser :
```git branch –u <remote>/<branch>``` ou ```git branch --set-upstream-to <remote>/<branch>```



Remarque : lorsqu’on clone un dépôt distant, git clone crée une *tracking branch* pour chaque branche du dépôt distant.



### 6.3 La commande ```git checkout```
Quand on représente le projet comme une succession de *commits* répartis éventuellement sur plusieurs branches, il faut se souvenir qu’à chaque *commit* correspond un objet *tree* à partir duquel on est capable de reconstituer l’image du projet tel qu’il était à ce moment-là.



La commande checkout correspond justement à l’action de recharger tout ou partie du working tree à partir de l’objet *tree* d’un *commit* cible. La commande s’utilise en général sous la forme ```git checkout <branche>```. Concrètement, Git va :
- Déplacer le pointeur du *tag* ```HEAD``` vers le *tag* ```<branch>```
- Peupler l’index avec le contenu du dernier commit de ```<branche>```
- Mettre à jour le *working tree* de façon à ce qu’il soit identique à celui stocké dans le dernier *commit* de la branche ```<branche>``` en copiant le contenu de l’index dans le *working directory*.



Par défaut ```git checkout``` va nous placer sur le dernier *commit* de la branche visée mais en théorie rien n’interdit de recharger n’importe quel ancien *commit*, qu’il soit une extrémité ou pas. La commande pour ce faire est quasi-identique : ```git checkout [--detach] <commit>```. Git va réaliser les trois étapes mentionnées ci-dessus mais dans le cas présent, l’étiquette ```HEAD``` ne pointe plus vers une autre étiquette comme elle le ferait en extrémité de branche mais directement vers le *commit* visé : on dit qu’on est en mode ```DETACHED HEAD```.
On peut ne pas se préoccuper de cette situation et retourner à une autre branche comme par exemple avec ```git checkout master``` une fois ce qu’on a passé en revu ce qu’on cherchait dans cet ancien commit. C’est en revanche un problème si on décide de créer un ou plusieurs *commits* à partir de cet endroit-là : on va de facto créer une nouvelle branche mais sans étiquette pointant vers son *commit* le plus récent (sauf ```HEAD``` jusqu’à ce qu’on change de branche). Une fois changé de branche, la branche sans étiquette risque d’être perdue à la prochaine garbage collection. Pour éviter cela, il faut créer une étiqueter cette branche avant de la quitter.
Il y a plusieurs façons de le faire :
- ```git checkout –b <nom_branche>```
- ```git branch <nom_branche>```
- ```git tag <nom_branche>```



Remarque : De ces trois façons de faire, seule la première nous sort du mode ```DETACHED HEAD```. La première commande inclut en effet une étape ```git checkout <nom_branche>``` qui va rediriger le pointeur de ```HEAD``` vers l’étiquette ```<nom_branche>```. Dans les deux autres cas on reste en ```DETACHED HEAD``` avec ```HEAD``` et ```<nom_branche>``` pointant vers le dernier *commit* de la branche.



## 7. Fusionner deux branches : ```git merge```
- Si le *commit* de la branche qu’on veut fusionner est simplement situé en aval du *tag* de la branche sur laquelle on veut fusionner, l’opération de fusion consiste simplement à avancer le second *tag* au niveau du premier. On parle de *fast-forward merge*.
- Le cas le plus fréquent est de vouloir fusionner deux branches qui ont divergé à partir d’un certain *commit*. Leur fusion va passer par la création d’un troisième *commit* qui pointera vers les deux anciennes extrémités. On parle de *three-way merge* car la création du nouveau *commit* passe par l’examen de trois *commits*, les deux extrémités et l’ancêtre commun. Seul le *tag* de la branche courante («*the branch we merge into*») est avancé sur ce nouveau *commit*.



*Remarque* : Pourquoi utilise-t-on l’ancêtre commun ? Cela permet par exemple de voir si une même ligne d’un même fichier a été modifiée dans chacune des branches (ce qui crée alors un conflit à résoudre).
Lequel des deux pointeurs sera avancé après merge ? Celui vers lequel ```HEAD``` pointe. On se *checkout* donc sur la branche vers laquelle on veut tirer l’autre : ```git merge <branche à tirer à soi>```.



### 7.1 Résolution des conflits pouvant apparaître à la fusion
Un conflit lors de la reunion de deux branches peut avoir des origines multiples : une même ligne d’un même fichier a été modifiée dans chacune des deux branches, un fichier supprimé dans une branche a été modifié dans l’autre, etc. Dans tous les cas, Git ne peut pas savoir seul laquelle des versions il doit conserver, on doit pour cela l’y aider.
Si un conflit apparaît après le lancement de ```git merge```, Git passe dans un mode dont on ne peut sortir qu’une fois tous les conflits résolus et le *merge* achevé ou via un ```git merge --abort``` qui annule l’opération. On peut voir quels sont les fichiers incriminés à l’aide de ```git status```. Pour résoudre le conflit, on va alors ouvrir le fichier concerné de la branche courante. Git aura écrit dans le fichier pour marquer le lieu du conflit :



```
<<<<<<< HEAD
… code de la branche courante …
=======
… code figurant au même emplacement dans l’autre branche
>>>>>>> branch_name
```
A nous de choisir en n'oubliant pas d’effacer les marqueurs de conflit ```>>>```, ```===``` et ```<<<```. Une fois qu’on a résolu les conflits dans un fichier, on ajoute ce dernier à l’index à partir duquel sera créé le *merge commit* (un *merge* n’étant après tout que la création d’un commit un peu particulier) avec ```git add```. Une fois tous les conflits résolus, on termine le *merge* en demandant manuellement la création du *merge commit* à l’aide de ```git commit –m <message>```.



Remarque : Ouvrir les fichiers objets de conflit un par un n’est pas très pratique de même que les marqueurs posés par Git peu élégants. On peut utiliser à la place des assistants (*mergetools*) qui rendent la résolution de conflits plus fluide. En cas de conflit, on appelle alors l’assistant avec ```git mergetool```. On peut vouloir changer d’application, cela se fait alors avec ```git config```.



## 8. Revenir en arrière
On voit ici comment :
- Revenir sur un *commit*
- Faire passer un fichier de *staged* à *unstaged* (sans perdre les modifications)
- Faire passer un fichier de *modified* à *unmodified*



### 8.1 Amender le dernier commit avec ```git commit --amend```
Modifier le dernier *commit* : si on se rend compte qu’on a oublié de joindre des fichiers au dernier *commit*, on peut les ajouter à l’index (```git add <file_name>```) et lancer ```git commit --amend```. On ne crée pas de nouveau commit mais on amende l’ancien qui est généré normalement à partir de l’état de l’index au passage de la commande.



### 8.2 Recharcher un contenu antérieur avec ```git checkout``` ou ```git reset```
Comme on l’a vu Git travaille avec trois *trees* :
- Celui du dernier *commit* et avec lequel l’index a été initialement peuplé. Il est pointé par ```HEAD``` et sera désigné par ce nom.
- L’index (techniquement ce n’est pas un *tree* mais l’idée est qu’il en reflète la structure)
- Le *working tree*



Il est possible que ces différents *trees* coïncident ponctuellement. Après un *commit*, les trois *trees* sont identiques (qu’à la condition que toutes les modifications du *working tree* aient été indexées sinon seuls ```HEAD``` et index coïncident). On répercute les changements du *working tree* à l’index lorsque ces modifications sont indexées. Index et ```HEAD``` coïncident après un *commit*. HEAD et *working tree* ne coincident qu’après un *commit* où l’ensemble des modifications a été indexé ou qu’après un ```git checkout``` qui, par construction, modifie le *working tree* pour le rendre identique à celui du *commit* vers lequel on fait pointer ```HEAD```.



#### 8.2.1 ``````git reset``````
La première chose que fait la commande ```git reset <commit>``` est de faire pointer le *tag* vers lequel ```HEAD``` pointe vers ```<commit>```. Ce que ```git reset``` fait après dépend des options passées à la commande.
Il existe trois (modes) principaux ```git reset```:
- Le *soft reset* : ```git reset --soft```. C’est l’option prise par défaut quand on ne précise pas le mode pour ```git reset <commit>```.
- Le *mixed reset* : ```git reset --mixed```. C’est l’option prise par défaut quand on ne précise pas le mode pour ```git reset <tree-ish> <paths>```.
- Le *hard reset* : ```git reset --hard```.



Dans le *soft reset*, seul le *tree* vers lequel pointe ```HEAD``` est modifié. Dans le *mixed reset*, le *tree* vers lequel pointe ```HEAD``` est modifié et ce dernier sert à repeupler l’index. Deux *trees* sur trois sont ainsi « réinitialisés ».
Dans le *hard reset*, on ajoute au *mixed reset* une étape où Git va faire coïncider le *working tree* avec l’index. Cette option est potentiellement dangereuse car toute information du *working tree* non sauvegardée dans un *commit* avant le *reset* sera irrémédiablement perdue.
Dans les cas où on précise un chemin (généralement simplement un nom de fichier si on est déjà dans le *working directory*) à la commande *reset* (```git reset <tree-ish> <paths>```), la première étape disparait (pointer vers une partie d’un *tree* n’a pas de sens) mais les deux autres peuvent encore être réalisées. Par défaut c’est le mode *mixed* qui est choisi : on copie dans l’index la version du fichier stockée dans ```<tree-ish>```.
Cette méthode a une application utile : la désindexation de modifications. En effet, demander à Git de copier la version d’un fichier issue du *tree* du dernier *commit* (vers lequel pointe ```HEAD```) dans l’index revient à désindexer des modifications. La commande est ```git reset HEAD <file>```. On rappelle que ```HEAD``` est de type *tree-ish*.
Si on souhaite remplacer la version présente dans l’index par celle d’un autre *commit*, alors on a qu’à préciser un identifiant de celui-ci à la place de ```HEAD```. Ex : ```git reset eb43bf file.txt```



#### 8.2.2 Différence entre ```git reset --hard``` et ```git checkout```
Les commandes ```git reset --hard <tree-ish>``` (prendre une branche pour que la comparaison soit vraiment pertinente) et ```git checkout <tree-ish>``` ont des effets très proches mais ont deux différences majeures :
- ```git checkout``` est dit *directory-safe*. Comme les deux commandes vont à priori écraser les fichiers du *working tree* de façon à le rendre identique à celui pointé par ```HEAD```, il est possible que des modifications non indexées et donc non sauvegardées dans un commit soient perdues. Git checkout contrôle cela avant d’exécuter les instructions pouvant faire des dégâts irrémédiables. ```git reset --hard``` en revanche ne le fait pas.



Principale différence : ```git reset``` déplace le *tag* vers lequel pointe ```HEAD``` en le faisant pointer vers un nouveau *tree* (*commit*). A l’opposé, ```git checkout``` déplace ```HEAD``` qui va soit pointer vers un nouveau tag (```git checkout <branch>```), les tags ne bougeant pas, soit directement vers un *commit* (```git checkout <commit>``` - mode ```DETACHED HEAD```).
Il faut retenir que ```git reset``` déplace l’étiquette de la branche et ```HEAD``` avec elle alors que ```git checkout``` ne déplace pas les étiquettes de branche mais bouge ```HEAD``` de l’une à l’autre.



Remarque : ```git checkout``` peut aussi s’utiliser sous la forme ```git checkout <branch> <file>```. ```HEAD``` ne sera pas déplacé car cela n’a pas de sens de faire pointer un *tag* vers une partie d’un arbre mais le fichier sera bien copié dans l’index et le *working directory* écrasant son ancienne version et cela sans contrôles. Cette commande n’est donc pas *directory safe* contrairement à ```git reset <commit> <file>``` qui ne copie le fichier que dans l’index. Mieux encore, les fichiers du *working tree* modifiés localement sont conservés lors du changement de branche à l’aide de ```git checkout``` et peuvent ainsi être *commit* plus tard sur cette même branche.
En particulier ```git checkout -- <file>``` utilisée pour annuler des modifications (refait passer un fichier de *modified* à *unmodified*) n’est pas *directory safe* et conduit à une perte irrémédiable d’information.



#### 8.2.3 Autre application : écraser des commits
Mettons qu’on a une série de *commits* où un certain nombre d’entre eux sont simplement des oublis ou des corrections mineures. On souhaiterait faire en sorte que tous ces *commits* n’en forme qu’un seul pour avoir une meilleure lisibilité de l’histoire du projet. La commande ```git reset``` nous permet de le faire facilement. En effet ```git reset --soft``` nous permet de revenir en arrière au niveau d’un *commit* de référence mais sans modifier l’index. Il ne nous reste alors qu’à lancer ```git commit``` pour poursuivre une nouvelle branche équivalente à la précédente mais où toutes les modifications sont dans un même *commit*. L’ancienne branche sera effacée à la *garbage collection*.



L’exemple suivant correspond au simple enchainement des commandes suivantes :



```git commit```



```git reset --soft HEAD~2```



### 8.3 Créer un nouveau commit constitué d'anciennes versions : ```git revert```
```git revert <commit>``` permet également de revenir à l'état d'un commit antérieur ```<commit>``` mais au lieu d'aller placer ```HEAD``` à son niveau comme le feraient ```git reset``` et ```git checkout```, on va créer un nouveau commit identique à ```<commit>``` et y avancer ```HEAD```. L'exécution de cette commande exige qu'aucun des fichiers du *working tree* n'ait été modifié, on doit avoir un *clean working tree*.



### 8.4 Modifier la structure de l'historique du projet : le rebasage (*rebasing*)
Le *rebasing* est une technique similaire à la fusion (*merge*) de deux branches : dans les deux cas le *commit* final issu de l’opération est identique. En revanche, le *rebasing* modifie la structure de l’historique du projet : des deux branches de départ on en a plus qu’une après *rebasing*.



L’historique des *commits* permet de garder une trace de tout ce qui s’est passé et on peut être réticent à en modifier la structure car cela serait altérer la vérité. Toutefois l’historique des *commits* reflète aussi la façon dont le projet s’est construit et certains enchainements peuvent ne pas être très intéressants et méritent d’être remaniés. De même qu’on ne publierait pas ses brouillons, les retraitements que réalisés avec ```git rebase``` permettent de raconter une histoire plus claire à de futurs contributeurs qui voudraient comprendre l’histoire du projet en jetant un œil à l’historique des *commits*.
L’idée de *rebase* est de faire comme si les modifications développées dans une branche B qui a été ensuite fusionnée à une branche A avaient été faites directement dans la branche A. Pour une branche B présentant X *commits* entre son ancêtre commun avec A et leur point de fusion, un *rebase* va prendre les deltas introduits par chaque *commits* de B et les « rejouer » sur A. Le *rebase* (```git rebase A B```) va en fait ajouter X *commits* à la branche A, chaque nouveau *commit* ajoute le delta (appelé *patch* dans Git) développé sur B au code de A. Au bout des X *commits* on obtient un *commit* identique au *commit* issu de la fusion de A et B avec ```git merge```. *Rebase* ressemble à couper la branche B pour l’abouter à A, l’extrémité étant identique au résultat d’un ```git merge``` des deux branches. Le contenu des X *commits* ajoutés à A n’est pas identique à ceux de la branche B : le premier *commit* ajouté correspond au contenu du dernier *commit* de A plus le delta (net) introduit dans le premier *commit* de B, etc.
A l’issu du *rebase* de B sur A, le pointeur de B se situe à l’extrémité de la nouvelle branche tandis que celui de A est toujours à la même place et donc en retard. Il faut donc faire suivre le *rebase* d’un ```git checkout A``` + ```git merge B```.



On peut vouloir rejouer une branche C sur une branche A avec C qui n’est pas directement branchée sur A (mais sur une branche B). Il faut alors se servir de l’option ```--onto``` : ```git rebase --onto A B C```.
Si A est notre master, la référence de la branche B (et C) n’est plus utile (comme après un ```git merge```) et peut être supprimée avec ```git branch –d B```.
Un conseil est de ne jamais faire de *rebase* sur du contenu déjà partagé sur un dépôt distant. Si quelqu’un entreprend par exemple de restructurer sur sa machine du contenu du dépôt distant, modifications qui sont ensuite synchronisées (de force) avec celui-ci, cela risque rapidement de devenir ingérable. Entre autres problèmes pouvant être issus de cette situation, ayant l’ancienne structure, un ```git pull``` va me donner à la fois l’ancienne (avec les commits que mon collègue entendait supprimer) et la nouvelle.
Remarque : git possède des outils permettant de revenir en arrière après un *rebase* apocalyptique. Cela est permis par le fait que non seulement chaque fichier est identifié par une empreinte SHA-1 mais aussi chaque modification, chaque delta (*patch*) apporté à chaque fichier.
Il ne faut donc utiliser ```git rebase``` que sur du code non encore partagé, pour en simplifier la structure, en clarifier l’historique avant de se synchroniser avec le dépôt distant.



## 9. Des clients webs pour Git : GitHub, GitLab
- Github : Un *fork* consiste à faire une copie d’un projet d’un autre dans notre espace personnel, copie sur laquelle on peut ensuite travailler et *push* sans problème. Pas besoin d’ajouter des collaborateurs et de leur donner un *push access* s’ils veulent juste travailler dans leur coin. Si en revanche on veut contribuer au *repository* original, il faut en passer par une *pull request*. Une *pull request* ouvre une conversation permettant la revue du code et la discussion avec l’*owner* jusqu’à ce qu’il soit éventuellement assez satisfait pour *merge*.
Un enchaînement classique Gihub consiste en :
 1. *Forker* un projet
 2. Créer une branche de travail (*topic branch*) sur le master
 3. Apporter des améliorations (*commits*)
 4. *Push* vers la *topic branch* de mon *Github project*
 5. Ouverture d’une *pull request*
 6. Discuter avec l’*owner*, continuer éventuellement à *commit*.
 7. La *pull resquest* est fermée après avoir été acceptée et réalisée ou rejetée.

Remarque : il existe la possibilité de faire des *pulls requests* internes un projet où tout le monde a déjà en théorie les droits pour *push*.
 l’*owner*, continuer éventuellement à *commit*.
 7. La *pull resquest* est fermée après avoir été acceptée et réalisée ou rejetée.



Remarque : il existe la possibilité de faire des *pulls requests* internes un projet où tout le monde a déjà en théorie les droits pour *push*.
