## Executer un script python

Dans une CLI Linux 

On appelle le binaire python auquel on passe en autres arguments le chemin du script .py à exécuter. 

```
/usr/bin/python my_script.py
```

Remarque : le script doit avoir les droits pour s'exécuter (=> ```chmod```).

Si le chemin vers le binaire python figure dans ```$PATH```, cela simplifie l'éciture : 

```
python my_script.py
```

Attention : si Python 3.x et Python 2.7 sont installés sur une meme machine, on ne peut pas garantir vers quoi pointe ```python```. Pour Python 2.7 on a souvent un lien ```python2``` qui pointe vers ```python2.7```

Si on a un script (fichier texte) de commandes Python 
On peut ajouter un shebang à la première ligne du fichier .py. Le shebang permet d'indiquer à l'OS qu'il n'est pas en présence d'un fichier binaire mais d'un script et lui fournit le chemin vers l'interpréteur permettant d'exécuter les commandes (avec d'éventuels arguments qu'on souhaiterait passer à celui-ci). 

Exemple de shebangs : 
```
#!/bin/bash
#!/usr/bin/python -0
``` 

L'exécution du script dans la CLI s'écrit alors simplement ```./my_script.py```.

Portabilité : pour améliorer la portabilité du script c'est à dire pour pouvoir l'exécuter sur une autre machine sans avoir à modifier sa première ligne, on peut utiliser la commande env qui va aller chercher l'interpréteur dans le ```$PATH``` de la machine qui exécute le script. On écrit alors en tete de fichier : 

```
#!/usr/bin/env pyhton
```

Remarque : la commande ```env <command>``` a pour effet de lancer ```<command>```.

Remarque : exécuter un programme Python depuis le shell Python : Utiliser les built-in functions ```execfile``` : ```execfile('my_script.py')``` ou ```subprocess``` qui avec laquelle il est plus aisé de passer d"éventuels arguments :

```
import subprocess
subprocess.call(['python', 'helloworld.py', 'arg'])
```

## Fichier __init__.py
La présence d'un fichier __init__.py dans un répertoire permet de marquer celui-ci comme un répertoire contenant des packages Python ou dit autrement, que le répertoire doit etre traité comme un package Python. Si on le retire, Python ne viendra plus chercher de modules dans ces répertoire. Reformulé encore une fois, un package Python est un répertoire contenant un fichier __init__.py.

Remarque : package vs module : un package (ou librairie) Python est un répertoire contenant des modules Python (un module Python = un fichier .py = un script Python) dont un fichier __init__.py.

Si on a par exemple la structure suivante et qye ````mydir``` est sur notre ```$PATH``` : 
```
mydir/package/__init__.py
mydir/package/mymodule.py
mydir/package/subpackage/__init__.py
mydir/package/subpackage/mysubmodule1.py
mydir/package/subpackage/mysubmodule2.py
```

Alors on pourra importer ```mymodule``` avec les déclarations :
```
import package.mymodule
# ou
from package import mymodule
```

Le fichier __init__.py est généralement vide mais il peut contenir des instructions qui sont exécutées à l'importation du package (import d'autres dépendances, check de dépendances, aiasing, etc.). Voir ce [lien](https://docs.python.org/3/tutorial/modules.html#packages) pour plus de détails, notamment sur la variable ```__all__``` qui permet d'écrire ```from package import *```. Lire aussi ce [lien](http://sametmax.com/les-imports-en-python/).

Par exemple : on peut importer des éléments de mymodule.py dans __init__.py pour les rendre disponibles au niveau du package : 

```
# dans __init__.py
from mymodule import someFunc

# on peut désormais importer someFunc depuis package
from package import someFunc
```

Remarque : les éléments présents dans la docstring du __init__.py de Profiler (automodule, members, etc.) sont destinés à ```sphinx``` qui permet de générer automatiquement de la documentation.

Remarque : comprendre les histoires de structure de package, la distinction nette entre package/module/script (un package peut consister en un unique module ou plusieurs, une structure de modules est appelé un package. Il semble qu'un module corresponde à un sous-répertoire d'un package - doivent-ils tous avoir des __init__.py ?) et les histoires de "import it into the module namespace" où on passe une ligne d'import dans le __init__.py ce qui permet d'écrire ensuite ```from hello import helloworld``` au lieu de ```from hello.hello import helloworld```. Avec l'histoire de fichiers setup.py à placer dans le répertoire parent, il s'agit surtout ici de bien comprendre comment tout marche pour bien organiser et structurer son code => http://www.mxm.dk/2008/02/python-eggs-simple-introduction.html 

## Fichier __main__.py
Attention il faut distinguer fichier __main__.py de la valeur ```'__main__'``` pouvant etre prise par la varaible ```__name__```.

Contrairement à des langages comme C ou Java par exemple, Python ne possède pas l'équivalent d'une méthode main(). Quand on lance un script Python l'intégralité du script est exécutée, on a pas de fonction qui soit automatiquement appelée comme le main() de Java ou C.

S'il s'agit de lancer un seul script dont on souhaite qu'une partie soit automatiquement exécutée s'il est lancé directement mais pas quand il est importé : cf. ```if __name__ == "__main__"``` ci-dessous.

Python propose également un fichier __main__.py permettant de rendre facilement un projet Python exécutable. Un projet Python s'entend ici comme un répertoire contenant des modules Python (dont possiblement un __init__.py si le projet est destiné à former un package). Le fichier __main__.py fera office de point d'entrée lors du lancement du projet.

Exemple : On suppose qu'on a un répertoire myProjectDir contenant __init__.py, __main__.py, file1.py et file2.py où __main__.py rassemble la séquence d'instruction du programme. On peut lancer notre projet avec l'une des commandes suivantes : 

```
python -m myProjectdir
```

Remarque : Apparemment ```python myProjectdir``` marche aussi, la différence se situerait sur l'exécution de __init__.py (?).

On peut aussi zipper le répertoire et directement lancer :

```
python myProject.zip
```

Remaque : on peut demander à ```python``` de zipper notre répertoire, la commande ```python -m zipfile -c myProject.zip myProjectDir``` étant souvent donnée en exemple. Elle revient en fait à lancer comme un script le module zipfile.py sans doute intégré à la librairie standard (-m) à laquelle on passe sous forme de string les arguments ```myProject.zip myProjectDir``` (-c).

### Variable ```__name__```
La variable ```__name__``` est une built-in variable automatiquement créée par l'interpréteur et toujours visible quelque soit l'endroit où on se trouve. Elle s'évalue au nom du module (script) courant, c'est à dire du nom du fichier .py dont on est en train d'exécuter le code. Seule exception : le module sur lequel a été appelé ```python```. Quand on exécute des instruction appartenant à ce module (ou script) dit principal, la variable ```__name__``` prend ```__main__``` comme valeur.

Cette variable nous permet de savoir si du point de vue du scoping lexical on se trouve dans le module principal ou pas et si ce n'est pas le cas, dans quel module on se trouve. 

Cela est particulièrement utile à l'importation de module. Quand on importe un module en Python, cela se traduit par l'exécution du code du module importé (qui consiste le plus souvent en des définitions de fonctions et qui sont alors chargées en mémoire). Lors de l'exécution du code du module importé, la variable ```__name__``` va prendre le nom du module comme valeur.

Or il se peut qu'on ne souhaite pas que certains éléments du module soient exécutés lorsque celui-ci est importé par un autre (mais que ces éléments soient en revanche exécutés si ce module est directement exécuté). C'est là que la variable ```__name__``` vient nous aider.

Exemple : 
```
# File1.py
print "File1 __name__ = %s" %__name__

import File2

print "File1 __name__ = %s" %__name__

if __name__ == "__main__":
    print "File1 is being run directly"
else:
    print "File1 is being imported"
```

```
# File2.py
print "File2 __name__ = %s" %__name__

if __name__ == "__main__":
    print "File2 is being run directly"
else:
    print "File2 is being imported"
```

Ainsi l'exécution de la commande ```python File1.py``` va retourner : 
```
File1 __name__ = __main__
File2 __name__ = File2
File2 is being imported
File1 __name__ = __main__
File1 is being run directly
```

On peut ainsi éviter que des éléments d'un module pouvant aussi bien etre importé qu'exécuté directement ne soient exécutés quand celui-ci est simplement importé (des tests par exemple).

Remarque : Python ne possède pas de méthode ```main()``` mais on peut faire comme si : 
```
import sys

def main(argv):
	...

if __name__ == "__main__":
	main(sys.argv[1:]) # récurpère les arguments passés via la ligne de commande
```

## Fichiers .pex (Python EXecutable)
```pex``` est en fait un package python permettant de produire un exécutable : le fichier .pex. Le .pex commence en gros par un ```#!/usr/bin/env python```, on peut donc le lancer directement dans une CLI. Son effet sera principalement de lancer un environnement Python : le .pex lance un interpréteur Python en chargeant les modules qu'il embarque. On peut ainsi passer au .pex un script Python à exécuter dans l'environnement créé au lancement du .pex : ```./myPexFile.pex myScript.py```.

On peut également construire des .pex exécutant une fonction une fois l'environnement créé. Le .pex s'apparente alors à un véritable exécutable (compressé) qui package un script et ses dépendances. Il ce qu'on a le plus proche d'un .jar pour Python (oui et non : oui car contient une méthode main permettant d'exécuter le jar mais non dans le sens où ça n'est pas un format destiné à distribuer des packages : on ne passe pas des .pex au pythonpath comme on passe des .jar au classpath de la JVM).

> ".pex files are self-contained executable Python virtual environments. More specifically, they are carefully constructed zip files with a ```#!/usr/bin/env python``` and special __main__.py"

> "Because of the flexibility of the Python import subsystem, python -m my_module works regardless if my_module is on disk or within a zip file. Adding ```#!/usr/bin/env python``` to the top of a .zip file containing a __main__.py and marking it executable will turn it into an executable Python program. pex takes advantage of this feature in order to build executable .pex files.""

On peut voir le package ```pex``` comme un outil de build. Voir ce qu'il requiert. ```pex``` demande une forme de description du build (un peu comme un build.sbt) dans un fichier setup.py placé à un endroit précis. Il semble qu'il exige aussi une structure particulière pour les répertoires du projet à packager.

Remarque : un pex est unzippable si on sohaite voir ce qu'il y a dedans.

## Fichiers .egg
Le format .egg (fichier aussi appelé *.egg distribution*) est un format de distribution Python qui peut directement travailler avec (importer des packages au format .egg) via l'utilisation de la librairie ```setuptools```.
Créer (build) un .egg se fait avec le même package et demande comme pour un .pex de créer un fichier setup.py (comprenant au minimum un appel à ```setuptools.setup```) dans le parent directory du package.

Exemple de setup.py : 
```
from setuptools import setup, find_packages

setup(
    name = "mypackage",
    version = "0.1",
    packages = find_packages(exclude=['tests']) # va chercher tous les packages du current directory (tous les répertoires avec un __init__.py) pour les ajouter au .egg
    )
```

Remarque : la fonction ```setup``` permet notamment d'avoir la main sur les métadonnées contenues dans le fichier PKG-INFO qui est joint à la distribution.

Le setup.py se trouvant dans le *parent directory* du package (voir https://pythonhosted.org/an_example_pypi_project/setuptools.html#directory-structure) : 
```
someDir/setup.py
someDir/myPackage/__init__.py
someDir/myPackage/script1.py
```

Remarque : Python (dans la librairie standard) possède son propre package pour la création de distributions (````distutils```) qui possède également une fonction ````setup``` à utiliser dans un setup.py. Là où ```setuptools``` va produire un .egg (par l'appel de ```bdist_egg```), ````distutils``` produit un .tar.gz (par l'appel de ```sdist```).

Créer le .egg (*build a .egg distribution*) impose d'en passer par une ligne de commande : 
```
python setup.py bdist_egg
```
La syntaxe générale étant : ```python setup.py <some_command> <options>``` => https://pythonhosted.org/an_example_pypi_project/setuptools.html#using-setup-py
Il est sous-entendu dans l'expression ci-dessus que le current directory est celui du package (sinon on écrit ```path/to/setup.py```) 

Le build se solde par la création de trois nouveaux répertoires à l'intérieur du *parent directory* du package : 
* dist : qui contient le .egg (idem que pour ```distutils``` où le répertoire dist contient le .tar.gz)
* build :
* myPackage.egg-info : 

Remarque : ```setuptools``` propose plein d'autres fonctions pour créer toutes formes de distributions. Le package implémente en particulier une fonction ```sdist``` qui comme ```distutils``` peut produire un .tar.gz.
Remarque : un .egg est en fait un fichier zippé
Remarque : il semble que .egg soit un ancien format remplacé par le wheel (.whl)

Semble plus être un format pour distribuer ses packages (pour qu'ils puissent ensuite tous être importés facilement de la même façon ?) qu'un exécutable.

> "It should be noted that for pure Python eggs, the egg file is completely cross-platform."
Qu'en est-il pour les .pex ? Où peut apparatre une dépendance à la plateforme (à l'OS) ? Comment on gère ça ?

Voir : https://python101.pythonlibrary.org/chapter38_eggs.html et le chapitre suivant sur les wheels.

## Environnements d'exécution 
virtualenv vs conda ?
Lire http://sametmax.com/les-environnement-virtuels-python-virtualenv-et-virtualenvwrapper/
Où est l'environnement pour profiler ? Où sont les packages (en local sur l'application node) pour les notebooks ?
