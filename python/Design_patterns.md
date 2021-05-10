## Design patterns

### Relations entre objets
On distingue 4 principaux types de relations entre objets :
* L'association (trait simple dans un diagramme UML)
* L'agrégation (flèche à pointe diamant vide dans un diagramme UML)
* La composition (flèche à pointe diamant pleine dans un diagramme UML)
* L'héritage (flèche dans un diagramme UML)

Pour chacune de ces relation, on peut détailler la cardinalité de la relation (one-to-one, one-to-many, many-to-one, many-to-many). Par exemple, une relation d'association entre deux objets ne peut par exemple s'envisager qu'entre une instance d'un objet A et cinq instances d'un objet B. Plus concrètement une relation traduit une dépendance, un couplage, une communication entre ces objets, certains utilisant les fonctionnalités ou les services d'autres objets.

Association. Ex : Une Bank peut avoir plusieurs Employees. Il s'agit d'une relation d'association one-to-many. Une association est une two-way relationship. Il s'agit du type de relation le plus faible. Chaque objet a son propre lifetime et il n'y a pas d'owner. Chaque objet peut être créé et détruit indépendamment. On pourrait le voir comme une USING relationship entre les objets ou comme un HAS-A d'une agrégation mais en plus faible, sans ownership.
Agregation. Une agrégation est une HAS-A relationship. C'est une relation unidirectionnelle (one-way relationship) dont le sens est donné par la classe qui own l'autre classe. Les cycles de vie des objets reliés par une telle relation ne sont pas liés : les objets peuvent exister indépendamment les uns des autres. Ex : un Department peut avoir plusieurs Students mais l'inverse n'est pas vrai. Le Department persiste même s'il perd des étudiants et inversement, la disparition du Department n'implique pas la disparition des Students. Chaque objet a son propre lifetime mais il existe une ownership.
Composition. Une composition est une PART-OF relationship où les deux entités de la relation sont interdépendantes : chacune des entités ne peut exister sans l'autre. Dans la composition, on retrouve une ownership mais le lifetime de chaque partie est contrôlé par l'ensemble. Dis autrement, cette relation peut traduire le fait que les parties ne peuvent fonctionner sans l'ensemble, ne peuvent exister sans l'objet qui les contient. Ce contrôle dans la création et la destruction des "parties" peut être direct ou indirect (il est alors délégué à d'autres objets). Une relation de composition est une relation d'agrégation, la réciproque est fausse.
L'héritage (appelé aussi generalization) se place à part. Il s'agit d'une relation unidirectionnelle de type IS-A d'une classe spécialisée vers une classe plus générale. Il n'y a pas dans l'héritage de notion de lifetime ou d'ownership.
La classe parente va rassembler les méthodes communes à chacune des classes spécialisées que chacune peut surcharger (override) avec une implémentation spécialisée. Proposer une implémentation d'une méthode dans la classe parente peut ne pas avoir de sens. On souhaite toutefois imposer sa présence dans toutes les classes spécialisées. C'est le rôle des classes abstraites et des méthodes abstraites. Une méthode abstraite indique que l'implémentation de la méthode est exigée des classes concrètes héritant de la classe mais qu'on se refuse de spécifier une implémentation pour la classe parente. Pour des classes n'implémentant aucune méthode, on parle d'interface.

Une composition est une relation plus forte qu'une agrégation qui est elle même plus forte qu'une association.

Concrètement dans le code :
* Une association va se traduire par des objets utilisés côte à côte (?).


Ex d'agrégation :
```java
class Student
{
    String name;
    int id ;
    String dept;

    Student(String name, int id, String dept)
    {
        this.name = name;
        this.id = id;
        this.dept = dept;
    }
}

class Department
{
    String name;
    private List<Student> students;
    Department(String name, List<Student> students)
    {
        this.name = name;
        this.students = students;
    }

    public List<Student> getStudents()
    {
        return students;
    }
}
```

Exemple de composition :
```java
class Book
{
    public String title;
    public String author;

    Book(String title, String author)
    {
        this.title = title;
        this.author = author;
    }
}

class Library
{

    private final List<Book> books;

    Library (List<Book> books)
    {
        this.books = books;
    }

    public List<Book> getTotalBooksInLibrary(){

       return books;
    }

}
```

La différence se situe au niveau du modifier de l'attribut qui introduit une relation de dépendance entre les objets. De seulement ```private``` dans l'agrégation, on passe à ```private final``` dans la composition.

Remarque : Autres types de relations :
* Réalisation (Realization) : c'est une relation entre une blueprint class et l'objet contenant les détails d'implémentation correspondant, entre une interface et une classe implémentant cette interface.

Remarque : Une méthode implémente une action pouvant être effectuée sur un objet. Elle n'a pas à se borner à modifier l'état interne de l'objet sans effet de bord. Elle peut également retourner une valeur (ex: un getter) y compris l'objet modifié lui même (self).

Encapsulation : on peut sommairement distinguer parmi les membre d'un objet, les méthodes et attributs publics servant d'interface avec l'extérieur et par lesquels on peut communiquer avec l'objet, des membres privés nécéssaires au fonctionnement de l'objet mais qu'on ne souhaite pas rendre accessible aux autres utilisateurs. Bien penser l'interface publique est important car autant modifier des aspects internes est facile, autant modifier l'interface peut exiger de tous les utilisateurs de modifier leur code.

Abstraction : l'abtraction consiste d'extraire d'une interface publique les aspects relevant des détails de l'implémetation.

Points spécifiques Python :
Polymorphisme : Python pousse le concept un peu plus loin en permettant à n'importe quelle sous-classe d'être traité comme étant de sa classe parente (duck typing).

Héritage multiple : Python supporte l'héritage multiple. Son utilisation est toutefois déconseillée et on est invité à repenser son desgin dans les moments où on pense avoir besoin d'y recourir.

Classe : se crée avec la déclaration ```class MyClass:``` avec des noms qu'on préfère en CamelCase et commençant par une lettre ou un underscore (PEP-8). On peut créer des instances de la classe sans même avoir à écrire une méthode ```__init__``` ou ```__new__```, une nouvelle instance pouvant se créer simplement par la déclaration ```myObj = MyClass()```. Contrairement à des languages comme Java, on peut ajouter comme on veut des éléments à une classe (monkey-patching très facile). Le code suivant est par exemple valide :

```python
class Point:
  pass # Permet de dire qu'aucune action supplémentaire n'est envisagée

p = Point()

p.x = 1
p.y = 2
```

Une méthode se déclare comme une fonction avec la contrainte supplémentaire d'ajouter en tête de la liste des paramètres, un argument servant à faire référence à l'instance sur laquelle s'applique la méthode et le plus souvent nommée ````self```.

Exemple ```def someMethode(self, *args, **kwargs)```

Constructeur : La plupart des languages OO font appel à une méthode spéciale pour la création et l'initialisation d'un objet : le constructeur. Python sépare les deux étapes sur deux méthodes (dont l'implémentation n'est pas un préalable obligatoire à l'instanciation d'un nouvel objet), la création de l'objet étant assurée par ```__new__``` (prend un unique arguement : la classe de l'objet à construire et retourne le nouvel objet, rare d'emploi) et son initialisation par ```__init__```.

Remarque : Les déclarations d'import type ```from somePackage import *``` est déconseillée : on ne sait pas tout ce qu'on importe (d'autant qu'on importe aussi les dépendances du package) et peut créer des collisions dans le namespace qui peuvent être un cauchemard à débuguer.

Modificateurs d'accès : Il n'existe pas de mots clés tels que ```public```, ```protected``` ou ```private``` en Python. Tous les membres d'une classe sont publiques. Il existe deux principales astuces :
* Signaler à l'utilisateur les membres de la classes qui relèvent de son fonctionnement interne et qu'il ne devrait pas avoir à les utiliser en faisant commencer leur nom par un underscore. Ex : ```_someInternalMethod(self)```
* Faire commencer le nom du membre par un double underscore, l'attribut ou la méthode ne sera alors pas directement accessible. Ex : ```myObj.__someAttribute``` renvoie une erreur détaillant que ```__someAttribute``` n'est pas un attribut de ```myObj``` même s'il a été initialisé. En fait, un membre nommé ```__someName``` s'appelle en réalité ```_MyClass__someName``` (on appelle cela du *name mangling*), ainsi ```myObj._MyClass__someName``` va retourner une valeur.

On considère parfois que ```_someMember``` est l'équivalent de ```protected someMember``` et que ```__someMember``` est l'équivalent de ```private someMember```.

Remarque : variable globale, voir s'il n'y a pas des patterns plus élégants.
```python
import somePackage

last_id = 0

class MyClass:

  def __init__(self):
    global last_id
    last_id += 1
    self.id = last_id
```

Héritage :
Toutes les classes Python héritent (automatiquement, pas besoin de l'expliciter) au moins de la classe ```object```. On désigne souvent une classe parente sous le terme de superclass.

Exemple : ClassB hérite de ClassA : ```class ClassB(ClassA):```

Exemple d'application intéressantes : étendre les fonctionnalités des built-in types.

```python
class ContactList(list):

  def search(self, name):
    matching_contacts = []
    for contact in self:
      if name in contact.name:
        matching_contacts.append(contact)
    return matching_contacts
```

On pourra ainsi manipuler un objet ContactList comme n'importe quelle liste avec des fonctionnalités supplémentaires pour nos usages spécifiques : ```ContactList``` héritant de ```list```, on pourra écrire des choses comme ```someCL[:3]```, ```someCL.append('John')``` et bien sûr ```someCL.search('Bob')```.
Les built-in types les plus souvent étendus sont ```list```, ```dict```, ```set```, ```file```, ```str```, etc.

Surcharge de méthode : il s'agit du cas où on charche à modifier, à réimplémenter, étendre, le comportement d'une méthode de la classe parente qu'on ne souhaite pas utiliser telle quelle. Syntaxiquement, il n'y a rien à faire, on réimplémene la méthode à surcharger et c'est elle qui sera appelée en premier.

Si on souhaite explicitement faire appel à une méthode de la classe parente depuis une une classe spécialiées : utiliser ```super()```.

Ex :
```python
class SubClass(SuperClass):

  def __init__(self, sarg1, sarg2, arg3):
    # On surcharge __init__ pour étendre son comportement
    super().__init__(sarg1, sarg2)
    self.arg3 = arg3
```

Héritage Multiple

Forme la plus simple : le mixin. Un mixin est une classe qui n'a pas d'existence propre, dont le but n'est pas d'être instanciée mais qui est créée simplement pour être héritée et augmenter les fonctionnalités des classes qui en héritent des méthodes qu'elle implémente.

Donne un espèce d'équivalent des interfaces en Python (d'ailleurs les interfaces n'ont-elles pas été créées en Java car ce language ne supporte pas l'héritage multiple de ne permet pas de faire ce genre de choses ?)?

Ex :
```python
class Contact:
  def __init__(self, name, email):
    self.name = name
    self.email = email

class MailSender: # Notre mixin
  def send_mail(self, message):
    # Add buisness logic here

class EmailableContact(Contact, MailSender):
  pass

e = EmailableContact("John Smith", "john@mail.com")
e.send_mail('Hello!') # Va marcher
```

Alternatives possibles au mixin :
* S'en tenir à l'héritage simple et implémenter ```send_email``` dans la classe spécialisée mais doit être fait dans toutes les classes qui pourraient en avoir besoin.
* Créer une fonction ```send_mail``` "standalone". Ne parait pas génial du point de vue du packaging et du scope ?
* Préférer la composition à l'héritage : on garde l'héritage simple mais dote notre classe d'un attribut de type ```MailSender```.
* On monkey-patch notre classe après sa création avec une fonction possédant un argument ```self```.

Remarque : quand on choisit le nom de classes qui seront liées par de l'héritage, choisir les noms des classes en cohérence avec le fait que l'héritage est une relation IS A. Alternativement, se souvenir que la composition est une relation HAS A.

Ex :
```python
class Friend:
  def __init__(self, name):
    self.name = name

# On souhaite lui ajouter une adresse.
# 1) Le faire via l'héritage d'une classe dont les attributs sont les éléments
# de l'adresse.
# 2) Le faire par composition : on ajoute un attribut de type Adress.

# 1) Par héritage
class AdressHolder:
  def __init__(self, street, city, country):
    self.street = street
    self.city = city
    self.country = country

class Friend(AdressHolder):
    def __init__(self, name, street, city, country):
        super().__init__(street, city, country)
        self.name = name

# 2) Par Composition
class Adress:
  def __init__(self, street, city, country):
    self.street = street
    self.city = city
    self.country = country

class Friend:
    def __init__(self, name, street, city, country):
      self.adress = Adress(street, city, country)
      self.name = name

# Sur les noms :
# 1) Friend pourrait hériter de Adress mais Friend IS A Adress n'a pas de sens
# En revanche, Friend peut être vu comme membre des plus généraux AdressHolder
# 2) Inversement, pour la composition, Friend HAS A Adress a plus de sens que
# Friend HAS A AdressHolder.
```

L'héritage multiple fonctionne bien dans le cadre des mixins mais cela devient problématique, peu clair et déconseillé quand on a besoin de faire des appels à des méthodes implémentées par plusieurs superclasses (ne serait-ce que ```__init__```). C'est particulièrement craint avec le problème du diamant où chacunes des 4 classes du diamant implémente une méthode du même nom. Dans quel ordre seront appelées les méthodes ? Comment se prémunir contre des appels multiples de méthodes en amont du diamant ? Que ce passe-t-il quand on écrit super().some_method() "en bas" du diamant ? Encore pire : les méthodes appelées successivement n'ont pas les mêmes arguments (ex : ```__init__```).

Globalement, il est rare que le recours à l'héritage multiple soit la seule et/ou la meilleure solution. Préférer des alternatives comme la composition ou des design patterns dédiés (provenant de languages où seul l'héritage simple est supporté).

Polymorphisme
L'utilisation la plus fréquente du polymorphisme consiste à utiliser une référence à une classe parente pour se référer à une sous-classe. L'utilisation classique est nommée subtyping et permet de restreindre la gamme de types utilisées dans un cas de polymorphisme aux sous-types d'une même classe parente. Python n'étant pas statiquement typé, on perd cette possibilité.

En Python, le polymorphisme existe mais sous une forme un peu batarde à cause du duck-typing (procédé qui permet de savoir si un objet peut être utilisé pour un usage particulier ce qui en typage statique se fait avec le type - Le duck-typing détermine si un objet peut être utilisé s'il présente les bonnes méthodes et propriétés plutôt qu'en se basant sur le type de l'objet lui même): on peut utiliser n'importe quel objet pourvu qu'il implémente la méthode (sans qu'il soit forcément une sous-classe d'une classe parente). Cette possibilté qu'offre Python diminue le besoin de recourir à des superclasses communes. Plus largement, cela diminue le besoin de recourir à l'héritage multiple ou non en Python.

```python
class AudioFile:
  def __init__(self, filename):
    if not filename.endswith(self.ext):
      raise Exception("Invalid file format")
    self.filename = filename

class MP3File(AudioFile):
  ext = "mp3"
  def play(self):
    print("playing {} as mp3".format(self.filename))

class WavFile(AudioFile):
  ext = "wav"
    def play(self):
      print("playing {} as mp3".format(self.filename))

# Versus :
class FlacFile:
  def __init__(self, filename):
    if not filename.endswith(".flac"):
      raise Exception("Invalid file format")
  self.filename = filename

def play(self):
  print("playing {} as flac".format(self.filename))

# On peut aussi bien jouer (appeler play()) ce fichier sans qu'il hérite
# de AudioFile

# Dans un language à typage statique on aurait déclaré une variable audiof
# de type AudioFile. On lui assigne un objet WavFile ou autre et écrit
# audiof.play(). Par contre on aurait pas pu assigner FlacFile à audiof
# car il n'est pas du type AudioFile.
```
Remarque : Feature utile du duck typing : L'objet n'a à fournir que les méthodes et attributs appelés. L'objet doit seulement satisfaire à la partie de l'interface qui est accédée et non à l'ensemble.

Abstract Base classes

A cause du duck-typing, on est jamais sûr qu'un objet rempli complètement le protocole qu'on souhaite imposer. Les abstract base classes (ABC) vient palier à ce problème en définissant un ensemble de méthodes et de propriétés qu'un objet doit implémenter afin d'être considéré comme une instance de cette classe par le duck-typing.

Il existe un ensemble d'ABS dans la Standard Library (on peut les voir comme des patterns ?).

Ex : la classe ```Container``` de ```collections``` qui ne contient qu'une seule méthode asbtraite ```__contains__```. D'ailleurs, conséquence (et puissance) du duck-typing : si on crée une classe qui implémente une méthode ```__contains__``` alors elle sera considérée comme une instance de ```Container``` **sans** en avoir eut à en hériter! On peut créer grace au duck-typing une relation IS A sans l'overhead de l'héritage.

Remarque : les ABC seraient l'équivalent des interfaces (au sens où en Java (?) elles ne comportent que des méthodes abstraites la où une classe abstraire peut implémenter quelques unes de ses méthodes) qui sont les outils permettant à une classe d'implémenter obligatoirement des méthodes.

Remarque : quand l'objet n'est pas forcément la meilleure idée : on veut rassembler du code dans une fonction qu'on souhaite sortir de la classe et la maintenit ailleurs. Pas obligé de créer une classe qui ne sert à héberger des fonctions statiques qui n'accèdent même pas aux variables de la classe. Autant faire des 'module-level functions', des fonctions Python simples.

Remarque : les classes sont des objets comme les autres qu'on peut manipuler, assigner à des variables, etc. Voir l'exemple p. 92-93.

Remarque : Sur l'héritage, vérifier :
```python
class ClassA(ClassB):
  pass

obj = ClassA()

isinstance(obj, ClassB)
# True ? Comment celà se décide ? Polymorphisme, duck-typing ?
```

Exceptions

Une exception est un objet. Toutes héritent de la built-in class ```BaseException```. La plupart héritent de ```Exception```, elle-même dérivée de ```BaseException```. Il est naturellement possible de se créer ses propres exceptions en plus de celles disponibles nativement.

Lever une exception : Pour lever une exception, on utilise le mot clé ```raise``` suivi du type d'exception à lever.
Ex :
```python
if not isinstance(x, int):
  raise TypeError("Only integers are allowed")
```

Comment gérer une exception une fois qu'elle a été levée ? Comment intégrer la levée d'exception au flot de contrôle du programme ? Pour celà, on intègre tout bloc de code susceptible de lever une exception à l'intérieur d'un bloc ```try ... except```.

```python
# Va capturer toutes les exceptions quel que soit leur type
# Doit capturer BaseException mais comme tout le monde en hérite..
try:
  # Some code
except:
  # Some code

# On peut recourir à plusieurs blocs execpt afin de capturer une ou plusieurs exceptions spécifiques. On les place normalement de l'excetions la plus spécifique à la plus générique.
try:
  # Some code that can raise exceptions
except (ZeroDivisionError, ValueError):
  # Some code that handle raised exceptions
except TypeError:
  # Some code that handle raised exceptions
else:
  # Some code to execute if no exception is raised in the try block
finally:
  # Some code that is always executed
  # Useful to clean up DB connection, close file, etc.

# On peut vouloir référencer un objet Exception afin de pouvoir accéder à
# ses attributs
try:
  raise ValueError("This is an argument")
except ValueError as e:
  print("The exception arguments were", e.args)
  # Va imprimer les arguments passés à ValueError lors de son initialisation

# Dans le cas suivant le bloc traitant la TypeError ne sera jamais appelée,
# le bloc traitant l'Exception étant rencontré en premier et TypeError héritant
# de Exception
# C'est par ce genre d'astuce qu'on peut regrouper le traitement d'exceptions
# similaires du point de vue de la récupération.
try:
  # Some code
except Exception as e:
  # Some code
except TypeError :
  # Some code
```

Remarque : Si aucune n'exception n'est levée, se souvenir que le code des blocs ```else``` et ```finally``` sont exécutés. Redondance alors ? Non. ```else``` est exécuté si aucune exception n'est levée ou si une exception non capturée par un bloc ```except``` est levée. ```finally``` est toujours exécuté. La différence se situe au niveau des exceptions faisant l'objet d'un bloc ```except``` dédié.

Remarque : on peut apparemment utiliser un ```return``` statement dans un bloc try. Le bloc ```finally``` sera néanmoins exécuté avant la valeur soit retournée.

Toute exception doit étendre la classe ```BaseException``` ou une de ses sous-classes.

Ecrire ```except``` seul est imprudent et va conduire à capturer toutes les exceptions (équivalent à ```except BaseException```) y compris deux exceptions spéciales qu'on préfère souvent traiter spécifiquement : ```SystemExit``` et ```KeyboardInterrupt```. On les distingue du reste qui héritent toutes de ```Exception```. On préférera écrire ```except Exception``` qui ne capturera que les exceptions utiles.

Exceptions personnalisées :
On va généralement les faire hériter de ```Èxception```. Pas forcément besoin de réimplémenter ```__init__``` : celui implémenté par défaut pour ```Exception``` récupère tous les arguments qu'on peut passer au constructeur et les stocke dans un tuple assigné à un attribut ```args```. On peut donc simplement écrire :

```python
class InvalidWithdrawal(Exception):
  pass

try:
  raise InvalidWithdrawal("You don't have $50 in your account")
except InvalidWithdrawal as e:
  print("The exception arguments were", e.args)
```

Autre exemple :
```python
class UsernameAlreadyExistsException(Exception):
pass

username = 'Bob'
if not checkUsername(username):
  raise UsernameAlreadyExistsException('Username ' + username + ' already exists.')

# Exemple : si notre liste d'utilisateurs est rassemblée dans un dictionnaire
# on peut essayer userdict[username], en cas d'absence sera levée une KeyError
# On peut par exemple écrire un raise UsernameAlreadyExistsException à
# l'intérieur d'un bloc except KeyError:
```

Une des principales justifications de l'utilisation d'exceptions personnalisées est la création d'un framework, d'une API vouée à être utilisée par d'autres programmeurs. Des exceptions adaptées à notre framework peuvent venir pointer des erreurs dans le code des utilisateurs de celui-ci et aider le programmeur à la corriger où à voir comment la gérer.

Remarque : on voit que les blocs liés à la gestion des exceptions participent au flux de contrôle du programme. Toutefois, dans les cas où on peut faire la même chose avec un ```if ... else``` classique ou un bloc ```try...except``` avec une exception qui convient, la méthode ayant recours aux ```try...except``` n'est-elle pas un peu lourde? sous-performante ?

Chapitre 5 :
Quand utiliser l'objet ?
Rappel : un objet consiste en des données un des comportements (data and behavior). Si on a que des données, pourquoi préférer un objet qui ne sert à rien à une structure de données classique ? A l'inverse si on a que des comportements, de simples fonctions seraient sans doute préférables.

Au fur et à mesure dy dévloppement, on saura reconnaitre les données et fonctions qu'il serait pertinent d'encapsuler au sein de la même classe. D'autant plus utile si nos fonctions sont spécifiques à nos données.

Les décorateurs utiles :
* @classmethod : la méthode peut être appelée sur une classe au lieu d'une instance d'une classe.
* @staticmethod : transforme une méthode d'instance en méthode statique (liée à une classe et non à une instance). Pas besoin d'argument ```self```.
* @property
