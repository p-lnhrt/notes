## Data model

### Type, call by object, scoping (LEGB rule, cf. Pyhton execution model), data_structures, argument checking (à ajouter à ce qu'on sait des fonctions)

Tout est objet en Python. Corollaire : il n'existe pas de type primitifs : ```1``` est un objet, une instance de la classe ```int```. Tout de qu'on manipule est objet : int, list, classe, fonction, module, type, etc.

Un objet est caractérisé par un triptique :
* *Type* : Tout objet a un type qui correspond à classe dont il est l'instance. Le type détermine le comportement de l'objet, ce qu'on est capable ou non de faire dessus. Une fois l'objet créé, son type ne peut plus être modifié. On y accède via la *built-in function* ```type()``` (retourne un objet class d'où les "Python types are objects") qui en fait retourne la valeur de l'attribut ```__class__```. Tester si un objet est un type ou non se fait à l'aide de la built-in function ```isinstance(obj, type)```.
*Identity* (id) : Unique car propre à l'objet, elle ne peut être modifiée une fois l'objet créé. L'opérateur ```is``` assure de l'égalité de deux objets en comparant leurs id. On y accèdde via la *built-in function* ```id()```.
* *Value* : La valeur est contenue dans l'objet. Suivant que l'objet est mutable ou non (déterminé par son type), cette dernière peut être modifiée ou non une fois l'objet créé.

Remarque sur les types : tous les objets héritent de la classe ```object``` et de ses méthodes. Les classes sont également des objets dont le type est la métaclasse à partir de laquelle elles ont été créées (la métaclasse ```type``` le plus souvent : une classe est le plus souvent une instance de ```type```).

Certains objets possèdent des méthodes permettant d'en modifier le contenu (comprendre de les modifier in-place), certains n'ont que des méthodes permettant d'accéder à leur contenu. Certains n'ont pas de méthodes du tout. Une variable, un nom, **n'est pas** une propriété de l'objet qui lui-même ne sait pas comment il est appelé, par quel(s) nom(s) on se réfère à lui.

Remarque : les noms "vivent" dans des namespaces qui ne sont que des collections de paires (nom, référence d'objet) implémentées en pratique avec des dictionnaires. Quand on appelle une fonction ou une méthode, son namespace est initialisé avec comme noms la liste de ses arguments formels et comme objets ceux qui lui sont passés/donnés par défaut. Une opération d'assignation (*name binding operation* semble plus juste - cf. Python excecution model) ne modifie *pas* les objets se faisant assigner mais uniquement les namespaces (à l'opposé une opérarion comme ```x.append(1)``` modifie l'objet (car in-place) mais pas le namespace, le lien entre l'objet modifié et les noms y faisant référence).

En Python les variables ne sont que des noms et l'opération d'assignation ne fait que lier (bind) un nom à un objet. Chaque liaison a un scope (une portée) qui définit sa visibilité, le plus souvent le bloc (module, function body, class definition) dans lequel l'assignation a été faite.


Variables

On préfère parler de nom (*name*). Un nom n'est pas un objet mais simplement un pointeur, une **référence** vers un objet qui contient une valeur.
Plusieurs noms peuvent pointer vers un même objet. Ex :
````Python
a = 1
b = a
```

Quand plus aucun nom ne référence un objet, celui-ci est en principe garbage collecté.

Important sur l'assignation : Il n'y a qu'une seule lecture correcte de l'opération d'assignation : **Est associé au nom présent dans le LHS l'objet résultant de l'évaluation du RHS**. Si on opère sur un objet existant, il est possible si l'objet est mutable que l'objet retourné lors de l'évaluation du RHS soit le même.
Ex :
```Python
a = [1, 2, 3]
b = a + [4, 5]
# a et b pointent vers le même objet car les listes sont mutables
```
Si l'objet n'est en revanche pas mutable, un nouvel objet est retourné :
```Python
a = "Hello"
b = a + " World"
# a pointe vers l'objet str "Hello" là où b pointe vers la string "Hello World"
```

Autre exemple :

```
a = [1, 2, 3]

def changeList(x):
  x.append(41)

def changeListBis(x)
  x = [1000, 2000]

changeList(a)
print(a) # Retourne [1, 2, 3, 41]
changeListBis(a)
print(a) # Retourne également [1, 2, 3, 41]
```

Dans le second cas on a fait pointer le nom 'x' vers le nouvel objet [1000, 2000] (dont la portée ne dépasse d'ailleurs pas celle de la fonction).

Remarque : Certains sucres syntaxiques font ressembler des appels de méthodes à des assignations : Des expressions tels que ```x.y =``` ou ```x[y] =``` sont en fait des appels de fonctions (des méthodes ```__setattr__``` et ```__setitem__``` respectivment en l'occurence). ```x.y = 1``` n'est donc pas une assignation au sens de l'association n'un nom et d'un objet mais est équivalent à l'appel ```x.__setattr__('y', 1)```. L'assignation ```x = y``` n'est en revanche pas un appel de méthode/de fonction.


Remarque : les objets immutables correspondent notamment aux types "de base" (primitifs dans d'autres languages) comme les ints, booleans, chr, string, etc.

Call by object
Le calling model de Python n'est ni du call-by-value ou du call-by-reference (tel qu'il s'entend en C par exemple). Python utilise ce qu'on appelle du call-by-object (ou encore appelé call-by-sharing ou call-by-objet reference).

```Python
a = [1, 2, 3]

def someFunc(x)
  # some code

someFunc(x=a)
```

On parle de call-by-sharing car l'objet (ici la liste) est partagé à la fois par le caller (a fait référence à cet objet) et la méthode appelée (x fait référence au même objet). Ce n'est pas du call-by-value car d'éventuelles modifications faites à l'objet partagé peuvent être visibles du caller/de la méthode appelante ce qui est impossible dans du "vrai" call-by-value (où la valeur est copiée dans la (memory ?) stack de la fonction appelée impliquant qu'il est impossible que des modifications apportées à l'objet puissent ensuite être visibles par la méthode appelante).

"it is not call by reference because access is not given to the variables of the caller, but merely to certain objects." : à comprendre

C'est quoi le vrai call-by-reference ? C'est surtout que contrairement à C++ (et C) une variable n'est pas un pointeur, une adresse mémoire où se trouve la valeur et qu'une réassignation (a = 1 suivie de a = 2) n'implique pas que la première valeure est écrasée par la seconde (2 doit être écrite à l'adresse où se trove déjà 1 qui doit être écrasée). Dans ce cas avec Python, 1 aurait continué de vivre tant qu'il est référencé par d'autres noms, la réassignation ne fait que recréer un lien entre a et l'objet 2.

CALL BY OBJECT : on ne passe pas de référence car une variable n'est pas une référence, une adresse mémoire de la valeur. Le passage d'arguments à une fonction correspond (en fait sans faire exception) à une assignation. A l'initialisation du namespace de la fonction, on lie chaque nom (correspondant à chaque argument formel de la fonction) à l'objet produit par l'évaluation de l'expression passée à l'argument correspondant.

```Python
a = 1
def someFunc(x)
 # some code
```

Ecrire someFunc(a) est presque équivalent à

```python
a = 1
x = a
```

La seule différence étant que ```a = 1``` crée une liaison dans le namespace global (?) et ```x = a``` crée une liaison dans le namespace local de la fonction. La différence entre call-by-object et call-by-reference peut paraître subtile (le premier étant plus proche du second que du call-by-value si on devait chosir) car dans les deux cas, une modification de l'objet par la fonction appelée (callee) est visible de la fonction appelante (caller).

Ce qu'il y a derrière le nom n'est qu'un objet sur lequel on peut agir (ou pas) et non une zone mémoire qu'on peut réécrire, etc.

Call-by-reference vs call-by-value : le premier passe un pointeur aux arguments de la fonctions là où le second passe la valeur qui est copiée dans la memory (?) stack de la fonction. Le premier est plus memory efficient que le second mais on est plus protégé de l'impact d'une éventuelle modification de la valeur par la fonction. "Actual and formal parameters are created on the same (call-by-reference) / different (call-by-value) memroy stacks"


Extraits de http://www.cs.berkeley.edu/~jcondit/pl-prelim/liskov77clu.pdf traitant de l'object model d'un ensemble de languages auxquels on peut rattacher Python.

"Objects are the data entities that are created and manipulated by CLU programs.  Variables are just the names used in a program to refer to objects. [...] Each object has a particular _type_, which characterizes its behavior.  A type defines a set of operations that create and manipulate objects of that type.  An object may be created and manipulated only via the operations of its type. An object may _refer_ to objects.  For example, a record object refers to the objects that are the components of the record."

In practice, the space used by an object may be reclaimed when the object is no longer accessible to any [...] program.

Variables are names used in CLU programs to _denote_ particular
    objects at execution time.  Unlike variables in many common
    programming languages, which _are_ objects that _contain_
    values, CLU variables are simply names that the programmer uses
    to refer to objects.  As such, it is possible for two variables
    to denote (or _share_) the same object.  CLU variables are much
    like those in LISP and are similar to pointer variables in other
    languages.  However, CLU variables are _not_ objects; they
    cannot be denoted by other variables or referred to by
    objects.

```Python
a = 1
b = a
```
b va faire référence à l'objet auquel a fait référence. L'objet n'est pas copié mais partagé par les deux noms.

Procedure invocation involves passing argument objects from the
    caller to the called procedure and returning result objects from
    the procedure to the caller.  The formal arguments of a
    procedure are considered to be local variables of the procedure
    and are initialized, by assignment, to the objects resulting
    from the evaluation of the argument expressions.  Thus argument
    objects are shared between the caller and the called procedure.
    A procedure may modify mutable argument objects (e.g. records),
    but of course it cannot modify immutable ones (e.g. integers).
    A procedure has no access to the variables of its caller.

Call by value : Il s'agit de la stratégie d'évaluation la plus fréquente et utilisée dans des languages comme C par exemple. En call-by-value, l'expression passée en argument est évaluée et la valeur en résultant est liée à sa variable correspondante dans le scope de la fonction, la valeur étant aussi fréquemment copiée dans une nouvelle région mémoire. La principale caractéristique de cette stratégie est une pleine étanchéité entre les scopes de la fonction appelée et de la fonction appelante : le scope de la fonction appelante est laissé inchangé par l'exécution de la fonction appelée.
L'appelation call-by-value devient problématique lorsqu'on ne passe pas une valeur mais une référence à une valeur (comme un pointeur, la forme que prend cette référence est spécifique à l'implémentation). On a alors l'apparence syntaxique du call-by-value mais un effet plus proche du call-by-reference ou du call-by-sharing (qu'on décrit parfois comme du "call-by-value where the value is a reference") suivant les détails d'implémentation du language.

La raison principale conduisant à préférer passer une référence est que le language ne propose pas de représentation sous forme de valeur de types complexes représentés sous forme de data structures. On garde dans le code source une apparence de valeur alors qu'en fait on ne passe qu'une référence vers une data structure. Le passage d'une référence permet aussi un gain de performance par rapport à un pur call-by-value dans lequel une large data structure serait intégralement copiée. En revanche, si la structure est mutable, d'éventuellements modifications apportées par la fonction appelée seront visibles dans le scope de la fonction appelante. 
