# Apache Spark - The Definitive Guide
## Chapitre 1 : What is Apache Spark ?
Apache Spark is a unified engine and a set of libraries for parallel data processing on computer clusters.


*Unified* : L'idée centrale de Spark est d'offrir une plateforme unifiée pour le développement d'applications big data. Les différents modules de Spark sont destinées à des tâches aussi différentes que le machine learning, le streaming, SQL, etc. Une telle plateforme unifiée est comparable à ce qu'offrent Django ou Node.js pour le développement web. Un des avantages d'une plateforme unifiée est qu'une utilisation simultanée de différents modules (ex: machine learning + SQL) peut être optimisée et plus efficace par rapport à l'addition de différentes solutions techniques (interopérabilité). Certains modules de Spark ressemblent dans leur objet à d'autres projets Apache : SQL pour Apache Drill, GraphX pour Apache Giraph par exemple (?). Sauf qu'ici tout est intégré au sein d'une même plateforme et l'interaction entre les différents outils est donc a priori moins un problème.


*Computing engine* : Bien qu'aspirant à l'unification de différents usages au sein d'une même plateforme, Spark se borne à rester un moteur d'exécution (computing engine). Spark ne se veut pas attaché à un système de stockage permanent particulier avec les inconvénient que cela peut induire quand on voudrait utiliser le moteur de calculs sur un système de fichiers différents de celui pour lequel il a été utilisé (exemple de MapReduce et de HDFS). Cela permet à Spark d'être aussi bien utilisé avec HDFS que dans dans des environnements où l'architecture Hadoop n'est pas adaptée comme le cloud (où le stockage est acquis séparémment de la capacité de calcul) ou les applications streaming.


Spark a d'abord été une réponse à la difficultée de data scientists à exécuter des calculs de machine learning à grande échelle avec MapReduce. Organiser ces calculs demandant un accès répété aux données avec MapReduce était particulièrement laborieux et inefficace. C'est à ce problème que le Spark core a d'abord apporté une solution. Spark étant initialement conçu pour de l'analyse batch, sont venues ensuite se greffer des libraires pour de l'analyse interactive (SQL) puis le streaming. Les concepteurs ont particulièrement veillés à ce que toutes ces nouvelles API (auxquelles on peut ajouter MLib et GraphX) soit interopérables.


Avant Spark 1.0, l'API Spark pouvait largement être définie comme permettant d'effectuer des opérations fonctionnelles (tels que des maps ou reduces menés en parallèle) sur des collections d'objets Java. Avec l'introduction de l'API SparkSQL qui repose sur l'utilisation de données structurées avec un format de données non-contraint aux représentations mémoires Java (Java in-memory representations) a permis de puissantes optimisations et d'autres API ont depuis été développées sur ces bases structurées : DataFrame, Structured Streaming, machine learning pipelines.


Remarque : les CLI de Spark : elles correspondent chacune à un binary différent, ex :
- ./bin/pyspark : CLI Python
- ./bin/spark-shell : CLI Scala
- ./bin/spark-sql
- ./bin/spark-submit : CLI d'où on peut soumettre une application Spark déjà compilée


## Chapitre 2 : A gentle introduction to Spark
Les clusters de machines sur lesquelles Spark va exécuter ses taches sont gérés par des ressources managers comme YARN, Mesos ou le standalone cluster manager de Spark. Lorsqu'on soumet une Spark Application au ressource manager, ce dernier va allouer des ressources à notre application de façon à ce qu'elle puisse s'exécuter.


Spark Driver (SparkSession) et Executer, chacune de ces applications utilise une JVM pour s'exécuter. Une Spark Application par SparkSession. Il peut y avoir de multiples Sparks Applications s'exécutant en même temps sur un cluster
A comprendre : relation Spark driver / Spark language API : pour une même SparkSession en cours d'exécution, on peut interagir avec elle dans tous les langages qu'on veut : L'API languages traduit en code Spark les instructions passées dnas le langage de l'API.


Le driver Spark est l'application qui va appeler la méthode main() de celle-ci. Il est hébergé sur un des noeuds du cluster et a trois missions principales :
- remonter de l'information sur l'application
- répondre aux inputs de l'utilisateur
- ditribuer les taches entre les exécuteurs
Les exécuteurs sont simplements responsables d'exécuter les tâches qui leur sont assignées par le driver. Les exécuteurs vont principalement exécuter du code Spark, en revanche on peut interagir avec le driver avec de multiples languages (R, Python, Scala, Java, SQL) qui sont traduits en code Spark (code pouvant être exécuté sur JVM) via l'API Language.


Au démarrage d'une CLI Spark, une SparkSession est implicitement créée sous la variable ```spark```. Dans une standalone application, il revient au développeur d'explicitement instancier un objet SparkSession.


Remarque : Le DataFrame est une abstraction proposée par Spark dans sa Structured API pour la représentation de données structurées. On peut voir cet objet comme une collection d'observations, de lignes, distribuée sur le cluster. Le concept de DataFrame existe aussi dans R ou Python mais l'objet n'est en général pas distribué sur plusieurs machine. Spark supportant ces deux languages, il est cependant facile de passer d'un DataFrame Python ou R à un Spark DataFrame (et inversement).


Les abstractions telles que les Dataset, DataFrame ou RDD sont toutes des collections d'objets distribués sur le cluster. De façon à pouvoir exécuter les tâches en parallèle, l'objet et découpé en partitions. Une partition sera traitée par un exécuteur et correspond à la part des données physiquement présente sur une machine. Il peut y avoir plusieurs partitions par machine. Pour tirer parti au maximum de la parallélisation, il faut au moins avoir autant de partitions que d'exécuteurs. Notre degré de parallélisme correspond au min(nb_executeurs, nb_partitions).

Le logical plan de transformations que Spark construit pour chaque exécution permet aussi de définir le lignage (lineage) de chaque partition. Cette idée est à la base de la résilience des abstractions Spark : en cas de perte, Spark sait reconstruire n'importe quelle partition en réappliquant la chaîne de transformations aux données d'entrée. C'est aussi une conséquence directe du choix fait pour Spark d'utiliser la programmation fonctionnelle où pour une même transformation, l'application de celle-ci aux mêmes inputs donnera toujours les mêmes outputs.

Transformations Spark
En Spark, les abstractions sur lesquelles on travaille (RDD, DataFrame, etc.) sont immutables. Spark distingue deux types d'opérations :
- Les transformations qui agissent sur une abstraction (ex : DataFrame) et qui retournent un objet de même nature. Une transformation ne donne lieu à aucun calcul. Un DataFrame (par ex.) est en fait un objet ne représentant qu'une suite de transformations (d'où son immutabilité).
- Les actions qui entrainent l'exécutions des opérations correspondant à la suite de transformation située avant. Une action vise soit :
  - A visualiser les données dans la console
  - A collecter les données dans une structure de données du langage utilisé
  - A écrire l'output quelque part sous un format choisi.

Un ensemble de transformations constitue un DAG d'instructions. L'appel d'une action initie l'exécution de ce graph d'instructions en décomposant le job en étapes (stages) et taches (tasks) à exécuter sur le cluster.

Remarque : Même lire les données (Ex: spark.read.csv()) est une transformation. Exécuter cette commande ne produit pas d'effet (dans le cas de read.csv, Spark va éventuellement aller lire quelques lignes pour la schema inference si demandée).

Le fait qu'aucun calcul ne se lance avec l'appel d'une action fait dire que Spark pratique la lazy evaluation. Ce procédé a le grand avantage de permettre à Spark d'optimiser l'exécution de toute la suite de transformations qui lui est soumis. Ce plan d'exécution est visible avec la méthode explain() mais également dans l'UI Web Spark.
Remarque  : l'ordre du plan donné par .explain peut différer de l'ordre des transformations passées par l'utilisateur, la différence est créée par l'optimisation faite par Spark. Le plan d'exécution généré par Spark peut aussi être vu comme un DAG (Directed Acyclic Graph) de transformations.


On distingue deux types de transformations :
- Les narrow transformations : l'opération à exécuter sur une partition ne requiert que cette partition. Ex : filter, select. Il semble que pour ce genre d'opérations, Spark va procéder à du pipelining : Spark va exécuter toutes ces narrow transformations à la suite en mémoire.
- Les wide transformations : l'opération à exécuter sur une partition requiert d'autres partitions. Ex : sort, aggregation. Ces opérations vont physiquement exiger du shuffle : les données doivent être échangées. Malgré les optimisations que Spark va aussi apporter au shuffle, cette opération est critique pour la performance du fait qu'elle implique d'échanger des données sur un réseau à capacité limitée ainsi que de l'écriture sur disque. Le plan d'exécution retourné par explain semble faire apparaître à chaque fois (au moins pour les agrégations) deux étapes ressemblant à un Map et un Reduce.

Remarque : La web UI de Spark est accessible sur le port 4040 de la machine hébergeant le driver process. Elle permet notamment d'avoir des informations sur l'historique des jobs Spark, de l'avancement de leur exécution ainsi que des détails sur celle-ci (tasks, DAG, etc.)
si que des détails sur celle-ci (tasks, DAG, etc.)

Remarque : par défaut Spark retourne 200 partitions après un shuffle (quel que soit le nombre initial de partitions ?). Ce paramètre peut être modifié avec spark.conf.set("spark.sql.shuffle.partitions", "5"). C'est typiquement un paramètre qu'on va chercher à réduire quand on travaille en mode local (pas besoin de 200 partitions vu qu'on travaille avec peu d'exécuteurs). Ces paramètres permettent d'avoir plus de contrôle sur l'exécution physique des calculs et peuvent avoir un fort impact sur la performance.

Utilisation de requêtes SQL

Spark permet après création d'une table temporaire appelée aussi vue (view) de d'écrire sa chaîne de transformations directement sous la forme d'une requête SQL. La requête étant parsée, cette méthode conduit exactement au même plan d'exécution.

val myTable = spark.createOrReplaceTempView("myDataFrame")

spark.sql('requête FROM myTable')

Qu'est ce que .sql retourne ? A-t-on besoin de faire suivre d'une action ? En fonction, si .sql retourne un DataFrame par exemple, peut-on chaîner une requête SQL de transformations classique ? Dans les exemples, on appelle l'action (?) .show pour montrer le résultat de la requête dans la CLI.
L'idée derrière cette possibilité est de permettre à l'utilisateur de choisir la façon de spécifier ses transformations qui lui est la plus pratique.

## Chapitre 3 : A tour of Spark's toolset

spark-submit :
La CLI spark-submit permet de lancer le code de son application au cluster et de l'y exécuter. Une fois lancée, l'application va s'exécuter jusqu'à terminaison ou erreur.
On a accès à plusieurs options permettant de spécifier les ressources exigées par l'application ou comment elle doit être exécutée.
spark-submit peut exécuter toute application écrite dans un des languages supportés par Spark (Scala, Java, Python, R).

Remarque : pour les languages compilés, on doit fournir l'application déjà compilée ? Une application va sans doute consister en de multiples fichiers, il faut donc la passer sous forme packagée : d'où le fichier .jar de l'exemple Scala ? Parmi tous les fichiers .class, il faut préciser celui où se trouve la méthode .main() à exécuter (?), d'où l'option --class ?

Datasets :
L'API Dataset est la type-safe version de la Structured API de Spark destinée l'écriture de code Scala ou Java statiquement typé. L'API n'est donc pas disponible aux languages dynamiquement typés que sont R et Python.
Un DataFrame est une collection ditribuée d'objets Row. L'API Dataset permet d'assigner une classe Java/Scala aux enregistrements (records) du DataFrame et de le manipuler comme une collection d'objets typés (Ex d'objets typés en Java/Scala : ArrayList en Java, Seq en Scala).
L'idée de type-safe veut dire qu'on ne peut pas prendre accidentellement les objets constituant le Dataset comme étant d'une autre classe que celle déclarée initialement. Le Dataset permet de faire du type-safe coding, utilisant des fonction type-safe, etc. Cette idée est particulièrement utile dans le développement de larges applications dans lesquelles de nombreux développeurs interagissent via différentes interfaces bien définies.
Dans Spark 2.x, les classes supportées par l'API Dataset sont les case classes Scala ou les classes Java respectant la convention JavaBean.

Spark rend très facile le passage de DataFrame à Dataset (et inversement), permettant par exemple de n'utiliser un Dataset que là où on en a besoin.
Quand on appelle une action comme collect ou take sur un Dataset, ces méthodes ne vont pas collecter des Row de DataFrame mais bien les objets du bon type du Dataset.

Structured Streaming
Cette API est une nouveauté récente car elle n'est opérationnelle pour la production que depuis Spark 2.2 (semble être un ajout à la librairie Spark Streaming (?)). L'idée de l'API est de pouvoir exécuter en streaming les mêmes opérations que la Structured API propose pour le mode batch (pour lequel on parle de jeu de données statique - static dataset).

Un code écrit avec l'API Structured Streaming est très proche de ce qu'on pourrait écrire avec la Structured API pour le batch mode. Cela donne l'avantage qu'on peut prototyper en batch mode et convertir notre code pour le streaming avec très peu de modifications.

L'idée du streaming en Spark est de traiter les données incrémentalement.

Comme pour les données statiques, les opérations se divisent en transformations et actions (avec des actions spécifiques à Spark Streaming). De la même manière, les calculs ne s'exécutent qu'à l'appel d'une action (lazy evaluation).

Les actions Streaming sont un peu différentes. Un stream a la particularité qu'il se démarre (et s'arrête), les données sont récupérées et traitées à chaque déclenchement (trigger, qui doit pouvoir se paramétrer de plusieurs façons). Le produit des traitements est ensuite écrit dans une table le plus souvent en mémoire, table qu'on peut requêter avec le stream toujours actif. Les paramètres permettant de paramétrer le sink (ex: écrit-on à la suite pour avoir toutes les données depuis le début ou les dernières arrivées écrasent-elles les précédentes ?) vers lequel sont écrits les résultats des traitements sont nombreux (semblent être les options de la méthode .writeStream)

MLlib
La librairie ne propose pas uniquement un ensemble d'algorithmes de ML adaptés au cadre distribué mais aussi de nombreux outils de preprocessing et de nettoyage des données (feature engineering, etc). Ex : StringIndexer, etc.)

Le preprocessing est en général obligatoire car les algorithmes de MLlib ne prennent que des données mises au format Vector. Les traitements sont exécutés par des transformateurs (transformeurs) qu'il faut préalablement instancier. Les différents transformateurs peuvent ensuite être chainés au sein d'un objet Pipeline qui est ensuite appliqué aux donnés brutes.

Remarque : les transformateurs semblent agir sur des colonnes individuelles. Chacun retourne une colonne (un objet Vector ?). Pour constituer le set qu'on veut finalement passer à l'algorithme, le dernier transformateur du Pipeline sera un VectorAssembler qui réunira l'ensemble des colonnes transformées ou pas dans un objet du bon type.

Les transformateurs ont souvent besoin d'être initialisés sur les données (en anglais on parle comme pour un algo de ML de fit ou d'entrainent). Ces derniers peuvent être fittés tous ensemble au sein d'un Pipeline. L'objet Pipeline dispose en effet d'une méthode .fit qui retourne un nouveau Pipeline de transformateurs initialisés.

Les données transformées par le Pipeline fitté sont ensuite passées à un algorithme de ML qui dans Spark prend également la forme d'un objet à instancier.

Dans le cas où on a besoin de faire plusieurs passes sur les données comme pour du tuning d'hyperparamètres, on va vouloir éviter de refaire passer les données à traver le Pipeline de transformateurs à chaque fois. Les données transformées sont ainsi stockées en mémoire (mises en cache) avec la méthode .cache().

API de plus bas niveau
Toutes les abstractions utilisées pour la manipulation de données en Spark sont construites sur une même primitive, le RDD qui permet la manipulation d'objets Java / Scala / Python arbitraites (RDD d'objets Pythons ne semblent pas exactement équivalents aux autres pour des détails d'implémentation).
Aujourd'hui, l'utilisateurs ne devrait que rarement à avoir à manipuler des objets sauf pour maintenir du vieux code Spark ou pour effectuer des opérations sur des données brutes ou non-structurées. Pour le reste il est recommandé de s'en tenir aux API structurées.
Ex : On peut recourir aux RDD pour paralléliser des données initalement chargées sur le noeud du driver Spark.
Le RDD est une API de plus bas niveau donnant notamment accès aux détails de l'exécution physique des traitements (partitions, etc.).

## Chapitre 4 : Structured API
Remarque : La Structured API permet de manipuler des fichiers pas forcément structurés au départ. On peut manipuler des données issues du très structuré format Parquet, des données semi-strucutées (CSV) voire non strucutées (logs, etc.).

La Structured API regroupe trois API de collections distibuées : Dataset, DataFrame et les tables/views SQL. La majorité des outils de l'API s'applique aux traitements batch et streaming, le passage de l'un à l'autre pouvant se faire avec peu voire aucune modification.

Parmi les trois API décrites ci-dessus, on oppose API typée et non-typée.

Pour créer un nouveau Dataset / DataFrame, il suffit d'appeler une transformation. Comme dit plus haut, un ensemble de transformations constitue un DAG d'instruction à exécuter sur le cluster. Pour Spark, un Dataset / DataFrame représente un plan immutable et lazily evaluated spécifiant l'ensemble des opérations à appliquer à des données résidant à un certain endroit pour générer l'output désiré. Quand on appelle une action sur un Dataset / DataFrame, on demande à Spark d'exécuter l'ensemble de transformations et de retourner le résultat.

Un schéma définit le nom des colonnes ainsi que leur type. Le schéma peut être défini manuellement ou par inférence sur les données (schema on read).

Types Spark
Spark est dans une certaine mesure un language de programmation dans le sens où possède ses propres types. Quel que soit le language utilisé (Scala, Java, Python, etc.), la majorité des manipulations sont strictement opérées sur des types Spark (il existe une table de correspondance entre types Spark et ceux de Scala, Java, Python et R). Une fois typées, les données sont converties en une représentation interne à Spark pour ce type et toutes les manipulations suivantes se feront sur cette représentation.

Les types Spark peuvent sembler se confondre avec ceux des autres languages car beaucoup de types (surtout les types simples) partagent les mêmes noms dans les deux languages. Ex : le StringType de Spark est équivalent au StringType de Scala ou au DataTypes.StringType de Java. La différence est plus sensible sur les types complexes. Par exemple, les ArrayType et MapType de Spark sont en fait respectivement équivalents aux types Scala scala.collection.Seq et scala.collection.Map. Ces équivalences permettent ensuite de travailler sur les objets retournés par Spark à l'issue d'une action dans le language qu'on veut (on parle de "convert to native types").

DataFrame vs Dataset
Dire qu'un DataFrame est non-typé n'est pas totalement exact. Dans les deux API, Spark gère intégralement les types (maintains types). La seule différence provient du fait que Spark vérifie si les types sont bien alignés avec ceux spécifiés dans le schéma à la compilation pour les Datasets mais seulement à l'exécution pour les DataFrames.

Cela implique notamment que l'API Dataset n'est disponible qu'aux languages JVM (Scala et Java), les types étant spécifiés avec des case classes (Scala) ou des Java beans. Pour les languages Scala et Java, un DataFrame n'est qu'un Dataset d'objets de type Row (org.apache.spark.sql.Row), un objet Row représentant un enregistrement particulier (record). L'équivalent Spark du type Row est une représentation interne de son format optimisé pour les traitements en mémoire. Ce format permet d'éviter d'utiliser les types JVM (projet Tungsten) et d'économiser les coûts associés d'instanciation d'objets et de garbage collection qui sont potentiellement très importants. En Python ou R on n'opère en fait que sur des DataFrame et donc avec ce format Spark optimisé (utilisé notamment par le moteur d'optimisation Catalyst).

Remarque : le type Scala/Java Row (org.apache.spark.sql.Row) est équivalent au type Spark StructType qui est lui même un Array de StrucField. StructField ne semble en revanche pas avoir de champ pour les données.. comment on racroche tout ça ?

Remarque : l'action collect appliquée à un DataFrame retourne (en Scala) un Array de Row (pas de type, type Any). La même action sur un Dataset retourne en revanche des objets typés.

Remarque : l'information de type semble contenue dans l'objet Row mais n'est pas accessible au language natif.

Remarque : dans un language, un type est en fait une représentation interne propre au language pour un type de données particulier (?).

Exécution dans la Structured API
Ce qui suit concerne aussi bien les DataFrames que les Datasets.
- La première phase de l'éxécution consiste à convertir le code (si valide) de l'utilisateur en un unresolved logical plan. Un logical plan est simplement un ensemble abstrait de transformations que Spark va agencer de la façon la plus optimale possible.
- On dit que le plan est unresolved car même si le code est jugé valide, il se peut qu'il contiennent des noms qui ne se réfèrent à rien. Un analyzer va donc résoudre le plan à l'aide du Catalog Spark.
- Le resolved logical plan obtenu est ensuite optimisé par le Catalyst Optimizer à l'aide d'un large ensemble de règles. Par exemple et quand c'est possible, on va placer les opérations de filtrage ou de sélection le plus en amont possible du process. Dans le cas de données lues depuis un format Parquet par exemple, une opération de sélection peut être placée dès la lecture du fichier. Pas besoin alors de charger 200 colonnes en mémoire pour finalement n'en utiliser que 4.
- A partir de l'optimized logical plan est ensuite créé le phyical plan qui spécifie comment le premier va être exécuté sur le cluster. Spark dérive en fait un certains nombres de physical plans à partir du logical plan. Un cost model permet ensuite d'attribuer un score à chacun d'entre eux de façon à pouvoir finalement choisir le meilleur. Le cost model est en fait le moment ou on confronte une stratégie à notre situation physique (taille des partitions, etc.). Le physical plan qui est donc finalement sélectionné est donc normalement le plus adapté aux contraintes physiques des données et du cluster.
- Le selected physical plan est ensuite traduit en termes de RDD et de transformations sur ceux-ci (voila pourquoi on parle parfois de Spark comme d'un compilateur qui traduit des requêtes Scala, Java, SQL, etc. dans le language de bas-niveau optimisé pour l'exécution physique : les RDD). Spark réalise aussi d'autres optimisations durant l'exécution même (at run-time).

Remarque : Il ne semble pas forcément exact de dire qu'un DataFrame / Dataset est un RDD (je ne crois pas que ça en hérite par exemple) bien qu'au bout du compte toutes les opérations décrites par l'utilisateur à l'aide des API Dataset/DataFrame sont finalement traduite (et ont donc leur équivalent) dans l'API RDD.

## Chapitre 5 : Basic Structured Operations
Chapitre orienté sur les transformations de base, principalement narrow : select, withColumn, filter mais aussi quelques wide (sans s'attarder sur les implications pour la performance : distinct, sample, randomSplit, union (narrow ?), sort/orderBy, limit (narrow ?). Aborde rapidement la gestion des partitions : repartition vs coalesce. Agrégation, window functions et jointures sont traitées spécifiquement plus loin.

Role des expressions SQL à comprendre. Column expressions toujours des expressiosn SQL valides ? => Column expressions = expressions SQL ?

Schéma
Un schéma qui regroupe noms et types des colonnes d'un DataFrame/Dataset peut être défini manuellement avec les objets StructType et StructField. Les types du schéma sont les types Spark. N'a de sens que pour le DataFrame ? Pour un Dataset, le schéma est donné par la classe qu'on map sur l'objet Row ? Si les types ne matchent pas ceux donnés dans le schéma : run-time error.

Remarque : "We cannot simply set types via the per-language types because Spark maintains its own type information." (p. 61)

Remarque : créer un DataFrame. Ce n'est pas quelque chose qu'on fait souvent. Retenir que ça peut se faire entre autres avec spark.createDataFrame qui prend un RDD et un schéma en argument.

Colonnes :
Une colonne de DataFrame / Dataset n'a pas de réalité au sens où ce serait un objet contenant toutes les données d'une même colonne (contrairement aux lignes, aux enregistrement d'un DataFrame / Dataset qui sont chacune représentées par un objet : Row, case class, Java bean). Une colonne en Spark n'est qu'une expression décrivant une opération à exécuter sur l'enregistrement correspondant de chaque ligne du DataFrame/Dataset (opération pouvant être l'identité).

On comprend au passage l'efficacité particulière du format Tungsten : étant orienté colonne et compact, effectuer des opérations sur les colonnes sera particulièrement rapide.

On peut se référer à une colonne de plein de façons :

- Avec les fonctions (de org.apache.spark.sql.functions) col ou column. Ex : col("myCol"). ''myCol' peut ne pas exister : cette expression passe à la compilation et n'est résolue avec l'aide du Catalog qu'à l'analyse. Il existe des sucres syntaxiques (Scala) équivalents : $"myCol" ou `myCol.
- Référence explicite ne demandant pas de résolution avec la méthode .col ou .column : df.col("myCol").

Expressions colonnes : comme mentionné, les colonnes ne sont que des expressions d'opérations à exécuter ligne par ligne. De telles expressions peuvent être écrites de deux façon totalement équivalentes (au sens où elles aboutissent au même logical plan et donc à la même performance) :

 - Avec les fonctions col() (ou des références directes type df.col()) : on écrit en fait une suite d'opération sur des objets Column. Ex : (col("mycol") + 5)*200 < col("anotherCol").
 - Avec une expression SQL passée à la fonction expr() sous forme de String (expr() retourne un objet Column) : expr(("mycol" + 5)*200 < "anotherCol")

Il faut voir expr() comme strictement équivalent à col() ou column(). La seule différence est la façon dont on spécifie la colonne, expr() permettant de construire une Column par analyse (parsing) d'une expression SQL. En particulier et comme expr() retourne un objet Column, cette fonction peut cohabiter avec d'autres façons de spécifier une colonne dans des fonctions pouvant prendre un ensemble de Column en arguments.
Ex : df.select($"Country", col("CountryCode"), floor("Price"), expr(round(Quantity))).show()

Remarque : il semble que toutes les méthodes (transformations) prenant en argument des colonnes acceptent en fait des expressions de colonnes. Peut permettre de créer des colonnes simples en même temps qu'on effectue l'opération justifiant la création.

Rows :
En réalité les lignes (objets Row) ne sont manipulées qu'avec des column expressions :

Spark manipulates Row objets using column expressions in order to produce usable values. Row objets internally represent array of bytes. The byte array interface is never shown to users because we only use column expressions to manipulate them.

Remarque : Un objet Row n'a pas de schéma mais le DataFrame en a un.

Récupérer une valeur d'un objet Row : peut se faire avec un ensemble de méthodes. En R ou Python la valeur retournée est forcée dans le bon type. Ce n'est pas le cas en Scala / Java, en Scala la valeur retournée sera de type Any, il faut la forcer manuellement dans le bon type ce qui n'est globalement pas une bonne pratique. Apparemment on peut aussi se faire retourner les valeurs sous la forme des objets JVM correspondant (chapitre 11).

On peut créer un objet Row :
Ex : val myRow = Row("Hello", null, 1, false) :

Accéder aux éléments d'un objet Row :
En scala :
myRow(0) // type Any
myRow(0).asInstanceOf[String] // type String
myRow.getString(0) // type String
En Python :
myRow[0] # directement du bon type (String)

select / selectExpr
Permet de sélectionner une ou plusieurs colonnes voire d'en créer de nouvelles ou d'en renommer et/ou d'en modifier certaines en même temps. select prend des objets colonnes **ou** un ensemble de noms de colonnes sous la forme de chaînes de caractères (sinon erreur de compitlation). selectExpr prend en argument des expressions passées sous forme de chaînes de caractère.

df.select(df.col("myCol"), col("myCol"), column("myCol"), $"myCol", `"myCol", expr("myCol"))
df.select("myCol", "anotherCol")
df.select(df.col("myCol").alias("newColName"))
df.selectExpr("*", "(myCol1 = myCol2) as newCol")
df.selectExpr("avg(myCol) as AvgCol1") Possible aussi avec select ? avg retourne bien une Column ?

Quand on veut créer une colonne composée d'une seule valeur (dite littérale), on utilise la fonction spéciale lit() qui convertit la valeur en type Spark. Ex : df.select("myCol", lit(1).alias("One"))

Remarque : pour tout sélectionner on peut utiliser expr("*"). L'étoile a la même propriété qu'en SQL.

Remarque : en cas de nom de colonne comportant des caractères réservés ou spéciaux, entourer le nom de la colonne de backticks.

Ajouter de nouvelles colonnes (ou modifier les colonnes existantes) : withColumn
Il suffit de passer en argument une String pour le nom de la colonne à créer / sur laquelle agir et une expression renvoyant un objet colonne. De même expr() permet de passer une expression respectant la syntaxe SQL si cela est plus pratique.
df.withColumn("One", lit(1))
df.withColumn("newCol", expr("myCol1 == myCol2"))
df.withColumn("newCol", $"myCol1" === $"myCol2")
df.withColumn("newCol", $"myCol1" =!= $"myCol2")

Remarque : en Scala, les opérateurs === et =!= sont des alias pour les méthodes de Column equalTo et notEqual. Utiliser == ou != comme dans les expressions SQL ne marchera pas. En Python en revanche, les opérateurs == et != auront bien l'effet recherché.

Remarque : withColumnRenamed permet de renommer simplement une colonne. Ex : df.withColumnRenamed("oldName", "newName")

Remarque ; changer le type d'une colonne se fait avec la méthode .cast par exemple au sein de withColumn : df.withColumn("myCol", col("myCol").cast("string"))

Supprimer une colonne se fait avec la méthode .drop.

Filtrer
Spark propose deux méthodes équivalentes : where et filter :

- where prend aussi bien une String correpondant à une expression SQL pouvant retourner des booléens qu'un objet Column de booléen
- filter est un peu plus large et peut aussi pour Java ou Scala prendre en argument une fonction retournant un booléen et pouvant être appliquée à chaque ligne.

df.where("Pays != "United States"") // Syntaxe SQL ? Equivalent à df.where("Pays <> "United States"") ?
df.where($"Pays" =!= "United States")
df.where("Col1 == Col2") // Quel type de syntaxe est-ce ? Si on compare deux colonnes en SQL c'est == ? df.where("Pays == "United States"") ou df.where("Pays = "United States"") ?
df.where($"Col1" === $"Col2")

Remarque : si on veut renvoyer uniquement la première ligne d'un Dataset, utiliser la méthode .first, si on souhaite plus de lignes, utiliser .limit. Ces opérations sont-elles wide ou narrow ?

Autres opérations sur les lignes :

- Ne garder que les lignes uniques : .distinct, si on ne veut conserver que les lignes uniques suivant quelques variables uniquement, utiliser dropDuplicates. dropDuplicates sans arguments est équivalent à distinct.
- Prélever un échantillon : sample
- Subdiviser aléatoirement en blocs (utile pour construire les training/validation/test sets en machine learning) : randomSplit
- Concaténer deux Datasets suivant les lignes : union (équivalent à rbind en R)

Trier
Deux méthodes équivalentes : sort et orderBy. Les fonctions asc, desc, asc_null_first, asc_null_last, desc_null_first, desc_null_last peuvent venir compléter si on passe des objet Column. Si on préfère utiliser des expressions, la syntaxe doit être conforme à SQL.

df.orderBy(asc("col1"), desc("col2"))
df.orderBy(col("col1").asc(), col("col2").desc())
df.orderBy(expr("col1 asc col2 desc"))

Il existe une version narrow de cette transformation permettant de n'exécuter un tri qu'au sein de chacune partition : .sortWithinPartitions.

Partitionnement :
On peut manuellement décider de repartitionner un Dataset. Noter qu'on peut le faire suivant les valeurs prises par un ensemble de colonnes ce qui peut permettre de grandement réduire la magnitude de shuffles pouvant intervenir ensuite. On a deux méthodes :

- .repartition() qui va rerépartir les données entièrement (full shuffle) que cela ait été nécessaire ou non.
- .coaslesce() qui s'utilise pour réduire le nombre de partitions. .coaslesce de va pas occasionner de full shuffle et va chercher à combiner les partitions en réarrangeant le moins possible les données.

df.repartition(15)
df.repartition(col("myCol"))
df.repartition(15, col("myCol"))
df.coalesce(5)

Actions de collecte
Actions permettant de collecter les données sur la machine du driver pour les manipuler ensuite en local sur notre machine (opération potentiellement assez couteuse, prudence) :

- collect : rapatrie tout le dataset sur la machine. Attention suivant la volumétrie impliquée, cela peut facilement faire crasher le driver.
- take : comme collect mais ne récupère qu'un nombre n de lignes.
- show : imprime un nombre n de lignes dans la console.

## Chapitre 6 : Working with different types of data

Rappel : la fonction lit() permet de convertir les types natifs en types Saprk (retourne une colonne du type Spark correspondant).
Ex : df.select(lit(5), lit("five"), lit(5.0))

Booléens
Rappel en Scala les opérateurs == et != sont (sûrement) déjà réservés. Pour tester l'égalité entre deux objets colonnes, Spark met à disposition les opérateurs === et =!= qui sont des alias pour les méthodes equalTo et notEqual. L'opérateur ! (alias de la fonction not) existe en revanche.
Spark met à disposition les méthode and et or. Il est conseillé de ne pas utiliser and et juste de chainer les filter/where pour plus de clarté, Spark les fusionnera de toute façon à l'optimisation.

Comme les Column ne sont que des expressions, déclarer ses column expressions à côté ne pose pas de problème de gaspillage de ressources et apporte de la clarté au code.

Ex :
val priceFilter = col("UnitPrice") > 600
val descripFilter = col("Description").contains("PHONE")

df.where(col("StockCode").isin("DOT"))
  .where(priceFilter.or(descripFilter))
  .show()

Présence de null : il existe une méthode null-safe pour évaluer l'égalité de deux colonnes : eqNullSafe qui correspond à l'opérateur <=>.

Nombres
Spark fournit un nombre important de fonctions de base (org.apache.spark.sql.functions) permettant de faire des opérations sur des Column. A cela s'ajoute les méthodes de DataFrameStatFunctions permettant de décrire notre jeu de données (corrélation, table de contingence, etc.). Certaines fonctions se trouvent dans les deux ensembles (comme corr). Les méthodes de DataFrameStatFunctions retourne le plus souvent des types élémentaires (et non des DataFrame) et sont donc plutôt faites pour une analyse interactive dans la CLI.

Ex :
df.stat.corr("Quantity", "UnitPrice") // méthode corr de DataFrameStatFunctions. Retourne un Double.
df.select(corr("Quantity", "UnitPrice")).show() // fonction corr
df.stat.crosstab("Item", "Weekday").show() // Table de contingence : retourne un DataFrame pour lequel il faut demander explicitement l'affichage.

Remarque : équivalent du group_by %>% tally pour l'exploration des données ? df.stat.freqItems ?

String
org.apache.spark.sql.functions fournit de nombreuses fonctions optimisées correspondant à un certain nombre d'opérations de base :

- Nettoyage : lower, upper, initcap, trim, ltrim, rtrim, lpad, rpad
- Analyse des strings à l'aide de regex : contains (instr pour Python et SQL), regex_replace, regex_extract

Exemple intéressant p.96 de code permettant de générer un nombre arbitraire de colonnes.

Datetime
Il semble qu'en Spark les dates et les timestamps sont souvent stockés sous forme de String et convertis en types Date ou Timestamp à l'exécution (run-time).
De même, org.apache.spark.sql.functions fournit de nombreuses fonctions optimisées correspondant à un certain nombre d'opérations de base : current_date, current_timestamp, date_add, date_sub, datediff, etc.

Si on passe à Spark des String sous le format yyyy-MM-dd et que ces dernières sont ensuite impliquées dans des opérations avec des dates, pas besoin de les convertir, Spark s'en charge automatiquement :
Ex : df.filter(col("Date") > lit("2017-10-01"))

Pas besoin ci-dessus d'utiliser to_date car on utilise le format par défaut. Cela aurait été par contre nécessaire avec un autre format :
Ex : df.filter(col("Date") > to_date(lit("01/10/2017"), 'dd/MM/yyyy'))

Remarque : to_date ne requiert pas obligatoirement un format ('yyyy-MM-dd' par défaut) contrairement à to_timestamp ou to_utc_timestamp (où on précise le fuseau horaire).

Valeurs null
Là encore, org.apache.spark.sql.functions donne quelques fonctions utiles :
- isNull et isNaN pour le filtrage
- coaslesce : prend une ou plusieurs Column en entrée pour n'en retourner qu'une. Pour chaque ligne, on retourne le premier enregistrement non-nul de la ligne.

Comme pour les opérations statistiques, on a un sous-package de Dataset dédié aux opérations liées aux valeurs nulles (méthodes de DataFrameNaFunctions) qui fournit trois méthodes polymorphiques :
- drop : on supprime les enregistrements ayant au moins un ("any") ou tous ("all") leurs enregistrements null pour partie ou l'ensemble des colonnes. Ex : df.na.drop("all", Seq("Quantity", "UnitPrice"))
- fill : son utilisation la plus classique permet de remplacer les null par une valeur qu'on peut rendre spécifique à chaque colonne.
Ex : val fillColValues = Map("Code" -> 5, "Description" -> "No value")
df.na.fill(fillColValues)
- replace : plus large que fill, permet de remplacer n'importe quelle valeur par celle de notre choix.
Ex : df.na.replace("Description", Map("" -> "Unknown"))

Types complexes :
On peut avoir des colonnes d'un des trois types dit complexe de Spark : Struct, Array et Map.
Cela ressemble aux nested DataFrames de dplyr en R. On s'intéresse ici à comme créer ces strucutres, accéder à un élément particulier et à les "déplier" (opération unnest en R).

Création
On peut globalement soit créer ces structures emboitées manuellement soit à l'aide de fonctions qui pour chaque enregistrement retourne leur résultat sous la forme d'un type complexe.
Struct
df.select(struct("Description", "InvoiceNo").alias("complex_col")).show()
Array
Exemple ou on utilise la fontions split qui d'une String retourne un Array de sous-éléments :
df.select(split(col("Description"), " ").alias("complex_col")).show()
Map
df.select(map("Description", "InvoiceNo").alias("complex_col")).show()

Accès
Struct
df.select(col("complex_col").getField("Description")).show()
Array
df.select(col("complex_col").getItem(0)).show()
df.selectExpr("complex_col[0]").show()
Map
df.select(col("complex_col").getItem('WHITE METAL LANTERN')).show() //On utilise une valeur de clé
df.selectExpr("complex_col['WHITE METAL LANTERN']").show()
"Désemboitement"
Se fait à l'aide de la fonction explode (ou explode_outer) qui ne semble être disponible que pour les Column d'Array ou de Map. Pour chaque élément de l'Array ou du Map sera créée une nouvelle ligne (duplicant les autres éléments de l'enregistrement qui contenait initialement la structure). explode_outer se différencie par rapport à la gestion des nulls.

User Defined Functions (UDF)
L'avantage des UDF est qu'on peut programmer n'importe quelle opération que les fonctions de base fournies par Spark ne prennent pas en charge. Spark a l'avantage de permettre d'écrire ses UDF dans le language qu'on souhaite n'imposant pas d'utiliser et d'apprendre un DSL ou une syntaxe ad hoc ésotérique.

L'utilisation d'UDF n'est pas sans impact sur la performance, c'est pourquoi Spark recommande d'utiliser le plus possible les fonctions disponibles.

Comment cela se passe ? Il faut tout d'abord créer et enregistre sa fonctions. Les UDF sont par défaut enregistrées comme des fonctions temporaires à utiliser dans une SparkSession particulière. Initialement enregistrées dans le driver node, les UDF sont sérialisées et envoyées à chaque exécuteur à travers le réseau.
Il faut ensuite distinguer le cas des languages JVM (Scala, Java) de Python. Pour Scala et Java, la fonctions va être exécutée sur la JVM mais ne pourra pas profiter des capacités de code generation des built-in functions. Comprendre : la fonction n'a pas accès au format Tungsten et doit travailler sur des objets JVM (?). L'impact sur la performance sera d'autant plus grand qu'on utilise un grand nombre d'objets.
Dans le cas de Python, l'UDF ne peut pas être exécutée sur la JVM, Spark démarre donc un processus Python sur le worker node auquel sont passées les données dans un format sur lequel Python est capable de travailler. Les résultats sont ensuites retournés à la JVM et Spark. Ce procédé est très couteux et non-recommandé par Spark (préférer des UDF Scala ou Java). La perte de performance provient du coût de démarrer le processus Python mais surtout de la sérialisation des données à destination de Python. Cette dernière étape est d'autant plus un problème que Python et la JVM sont en compétition pour l'utilisation de la mémoire sur laquelle les deux processus sont hébergés. De plus, une fois que les données sont dans Python, Spark n'est plus capable de gérer la mémoire du worker node. Si jamais la contrainte de mémoire mord à cause de cette compétition, le worker peut échouer (fail) dans l'exécution de ses taches.

Une recommandation importante : il est une bonne pratique que les UDF aient un type de retour. Veiller à ce que ce type de retour soit également le même que le produit des calculs sinon Spark retournera null. Cela peut par exemple arriver si le type de retour précisé est un Long mais que les calculs produisent des Integers.

Ex:
// Enregistrement de l'UDF
import org.apache.spark.functions.udf
def power3(num:Double):Double = num*num*num
val power3udf = udf(power3(_:Double):Double)

// Utilisation sur un DataFrame
df.select(power3udf(col("num_col"))).show()

Remarque : on ne peut pas utiliser la fonction dans une syntaxe SQL (l'interpréteur SQL n'arrivera pas à résoudre son nom). Pour cela, il faut enregistrer notre UDF comme une fonction SparkSQL :
spark.udf.register(power3udf, power3(_:Double):Double)
df.selectExpr("power3udf(num_col)").show()

Remarque : UDF et type-safety ?

Il semblerait qu'un autre désavantage des UDF soit qu'elles sont opaques à Catalyst qui n'est pas capable d'optimiser une ligne en comprenant.

## Chapitre 7 : Aggregations
Les aggrégations sont dans le cas général des wide transformations mais est-ce un gros problème ? Si les fonctions réduisent toutes les colonnes de n à 1 ligne, les shuffles sont négligeables ? Toutes les opérations d'aggrégations sont elles compatibles map/reduce ? Surtout : contrairement aux jointures, aggréger n'implique pas de shuffle les données avant de procéder à l'opération même (et donc quand les données sont encore volumineuses) ? => Les aggrégations sont-elles donc de "vraies" wide transformations : les opérations sur chacune des partitions de requièrent pas les infos des autres partitions. C'est vrai mais lors de la phase de reduce uniquement ?

L'aggrégation demande :

- Une ou plusieurs variables discrètes (grouping variables, keys) suivant lesquelles les groupes sont constitués.
- Une fonction d'aggrégation qui à l'ensemble des ligne d'un groupe associe un unique résultat. Le produit de l'aggrégation est donc le plus souvent une unique valeur d'un type simple (Long, String, etc.) mais Spark laisse aussi la possibilité que le produit d'une aggrégation puisse être d'un type dit complexe (puisque les colonnes de tels types sont supportées).

DataFrames vs Datasets
On ne s'intéresse ici qu'aux transformations non typées de l'API Dataset. La transformation de groupage groupBy (tout comme rollup ou cube) retournent un objet de classe RelationalGroupedDataset sur lequel peut ensuite être appelé une méthode d'agrégation (notamme via .agg qui peut prendre en argument n'importe quel Column expression pouvant faire office de fonction d'agrégation) qui retournent toutes un DataFrame.
Il existe une fonction de groupage typée : groupeByKey retournant un objet KeyValueGroupedDataset dont les méthodes retournent ensuite toutes un Dataset. Cette feature reste marquée expérimentale (Spark 2.3).

Agrégation sans groupage
Deux façons :

- Utiliser une des fonctions d'agrégation de org.apache.spark.sql.functions dans un select. Ex : df.select(count("CustomerId")).show()
- Faire la même chose mais au sein de la méthode .agg Ex : df.agg(count("CustomerId")).show(). Effet identique si agg est précédée d'un groupBy sans arguments : df.groupBy().agg(count("CustomerId")).show().

Remarque : on peut tirer partie que agg prend des column expressions en argument pour utiliser des expressions SQL. Ex : df.groupBy().agg(count("CustomerId"), expr(avg("BasketValue"))).show()

Remarque : Il faut voir la méthode .agg de Dataset comme un raccourci (short-hand) de .groupBy().agg.

Remarque : La méthode .agg (de Dataset comme de RelationalGroupedDataset) peut aussi recevoir ses arguments via un objet Map ou une suite d'expressions respectant un certain format.
Ex :
df.agg(Map("age" -> "max", "salary" -> "avg"))
df.agg("age" -> "max", "salary" -> "avg")

Remarque : il semble qu'existe associé à un certain nombre de fonctions d'agrégation, une version calculant l'agrégat de façon approchée (avec une erreur choisie)

Obtenir un type complexe :
 org.apache.spark.sql.functions propose deux fonctions retournant un type complexe (apparemment un Array) : collect_list et collect_set. La différence est que collect_set ne retourne une liste d'éléments uniques.
 Ex : df.agg(collect_list("Countries"), collect_set("Countries")).show()

GroupBy
Prend en argument des Column expressions (ce qui peut permettre de créer la variable groupante du même coup) ou (exclusif) des noms de colonne sous la forme de Strings.

Les window functions Spark
Les window functions Spark partagent avec leurs équivalents R d'associer à une colonne, une nouvelle colonne de même nombre de lignes. Comme en R on peut appliquer ces fonctions sur des sous-groupes des données, par exemple rank("Sales") après un groupby va créer une colonne donnant le classement de chaque enregistrement à l'intérieur de chaque groupe pour le critère donné (Sales).
Les window functions sont un sous ensemble particulier de org.apache.spark.sql.functions dans lequel on peut distinguer fonctions de classement (ranking) : rank, dense_rank, percent_rank, ntile, row_number; et fonctions analytiques : cume_dist, lag, lead.

L'usage qui est présenté ci-dessus utilise groupBy comme on pourrait le faire dans d'autres languages :
df.groupBy("Country").select(lead(col("Year")).show() // ou withColumn ? Les deux marchent ?

Les window functions de Spark intègrent une fonctionnalité supplémentaire ayant trait au fait que les fenêtre sont aussi très utilisée pour des tâches d'agrégation (fonction appliquée sur une fenêtre glissante). On peut ainsi faire de fonctions d'agrégation des window functions au sens où leur action sur une colonne retourne une valeur par enregistrement. Une fonction d'agrégation (max, avg, etc.) doit ainsi être "rendue" window function via l'application de la méthode .over qui elle-même prend en argument un objet WindowSpec (package org.apache.spark.expressions) décrivant comment pour chaque enregistrement, la fenêtre de calcul sera construite.

Ex : df.select(avg(col("Revenue")).over(WindowSpec).alias("AvgRollingRevenue")).show()
On remarque qu'on a pas utilisé de groupBy (le groupage entre en fait dans la construction de la fenêtre et est intégré dans WindowSpec), l'expression avg(..).over(..) est en fait une Column expression qui peut être directement passée à select.

Une WindowSpec comprend trois éléments :

- A quel sous-ensemble de lignes doit-ont s'intéresser ? Cela se définit exactement comme un groupe avec groupBy sauf que la méthode s'appelle ici partitionBy.
- Au sein de la partition, comment sont ordonnés les enregistrement (important puisqu'il s'agit de calculer des valeurs de façon glissantes). Ce paramètre est contrôlé par la méthode orderBy.
-  Au niveau de chaque enregistrement, comment choisit-on les deux limites de la fenêtre. Spark permet deux définitions possibles des limites de la fenêtre à chacune est associée une méthode :

	- Les limites sont fixés de façon absolues autour de la cellule courante. C'est la méthode .rowsBetween. Ex : .rowsBetween(1, 2) signifie que la plage intègre toutes les lignes de la cellule précédente jusqu'à la 2e cellule après la cellule courante.
	- Les limites sont fixées par rapport aux valeurs de la variable suivant laquelle on a ordonné les lignes (impose qu'une seule variable ait été passée à orderBy et que celle-ci soit numérique). C'est la méthode .rangeBetween. Ex : .orderBy("Revenue").rangeBetween(1000, 2000) signifie que la plage de calcul va inclure toutes les cellules dont la variable Revenue est compris entre le Revenue de la cellule courante moins 1000 et ce même Revenue plus 2000.
	- Si on souhaite qu'une des limites soit la cellule courante, le debut ou la fin de la partition, on peut passer à rowsBetween / rangeBetween les objets suivants : Window.currentRow, Window.unboundedPreceding, Window.unboundedFollowing.

Exemple complet :
val windowSpec = Window
	.partitionBy("CustomerId", "Date")
	.orderBy(desc("Quantity"))
	.rowsBetween(Window.unboundedPreceding, Window.currentRow)

df.select(max(col("Quantity")).over(windowSpec)).show()

On remarque que la fenêtre est définie à partir d'un objet Window (de org.apache.spark.expressions) dont les trois méthodes .partitionBy, .orderBy et rowsBetween/rangeBetween permettent de définir les paramètres (comme pour la lecture de sources de données par exemple).

Certaines window functions classiques données plus haute peuvent aussi être utilisées comme summary functions.
Ex : df.select(rank().over(windowSpec)).show()

Groupages particulier
Spark propose en plus de groupBy + agg, deux autres possibilités : rollup + agg et cube + agg. Les tables retournées sont équivalentes à groupBy + agg mais incluent en plus des sous-totaux par groupe (comme dans un TCD Excel où on a chosit d'afficher les sous-totaux). La différence entre rollup et cube se fait sur quels sous-totaux sont calculés. Ces commandes n'existent pas dans SQL où elle sont remplacées par l'instruction GROUPING SETS.

Ex : df
	.drop // le calcul des sous-totaux peut être faussé par la présence de null
	.rollup("Date", "Country")
	.agg(sum("Quantity").alias("TotalQuantity"))
	.select("Date", "Country", "TotalQuantity")
	.show()

Pivoter une table : l'approche est similaire aux TCD d'excel et prend la forme d'un enchaînement groupBy + pivot + agg. A noter que .pivot renvoit un RelationalGroupedDataset, il doit donc être obligatoirement suivi d'une méthode d'agrégation pour récupérer un DataFrame.

Ex :
df.groupBy("Date").pivot("Country").agg(sum("Revenue")).show() // Dans ce cas on aurait juste pu faire .sum

Remarque : reshaper les données. L'équivalent d'un tidyr::spread serait un pivot + agg(first) sachant qu'on ne doit avoir qu'une ligne par combinaison possible des variables passées à groupBy et pivot. Equivalent pour tidyr::gather ?

User Defined Aggregation Functions (UDAF)
Les UDAF se distingues des UDF dans le sens qu'il agissent sur des groupes de lignes et non sur des lignes individuelles.
Leur définition (avant Spark 2.3) est par rapport aux UDF, assez compliquée : on doit en fait définir une classe héritant de UserDefinedAggregateFunction et implémentant un certain nombre de méthodes. Notre UDAF est en fait une classe, il suffit ensuite de l'instancier et/ou de l'enregistrer comme on faisait pour les UDF. Cette procédure implique que les UDAF ne sont disponibles qu'en Java/Scala.
Pour Spark 2.3 et suivantes, l'objectif est de rendre la définition d'UDF aussi facile que celle des UDF.

## Chapitre 8 : Joins
Spark permet de réaliser tous les grands types de jointures :

- Les inner, (full) outer, left outer et right outer joins
- Les jointures filtrantes :

	- (Left) semi-join : on ne garde dans la table de gauche que les enregistrements dont la clé est présente dans la table de droite.
	- (Left) anti-join : on ne garde dans la table de gauche que les enregistrements dont la clé n'est PAS présente dans la table de droite.
- La jointure "cartésienne" ou cross-join : pour chaque ligne de la table de gauche est dupliquée autant de fois qu'il y a des lignes dans la table de droite.

Il est conseillé de bien expliciter l'appartenance des colonnes sur lequelles on joint surtout si elles ont le même nom (sinon risque d'erreur).

Ex :
val joinExpression = leftTable.col("Id") === rightTable.col("Id")
val joinType = "left_outer"
leftTable.join(righttable, joinExpression, jointype).show()

Attention : Pour la jointure cartésienne, l'opération peut faire exploser le nombre de lignes (si on a 1000 lignes dans chacune des tables à joindre, la jointure produira une table de 1 000 000 de lignes). N'utiliser cette opération que si on est absolument certain de sa nécessité et du résultat qu'elle produit.

De façon assez intéressante, Spark permet les jointure avec des colonnes contenant des types complexes. Une joinExpression valide peut alors prendre n'importe quelle forme pouvu qu'elle retourne un booléen (cf. p.146). Par exemple pour la colonne sur laquelle on joint, on a à gauche un Array[String] et à droite [String], pour une inner join, on va joindre si les clés de droites se trouvent dans l'Array de gauche. Une ligne de la table de gauche sera alors dupliquée autant de fois que son Array contient des clés de la table de droite.

Comment sont effectuées les jointures ?
Les jointures sont un gros enjeu du point de vue de la performance. Suivant les précautions prises, la performance peut en effet être très variables.
Spark n'a pas une façon de faire des jointure et choisit ce qui lui semble être la meilleure stratégie (avec semble-t-il un cost-based optimizer amené à évoluer) notamment en fonction de la taille des tables à joindre. Le livre illustre le scénario le plus courant pour chaque extrémité du spectre :

- Si les deux tables sont "grosses" : on va avoir ce qu'on appelle une shuffle join : tous les noeuds communiquent et s'échange des données basé sur qui possède quel ensemble de clés. Ce type de jointure est potentiellement couteux car le réseau peut se trouver congestionné. Cela sera d'autant plus le cas que les données sont mal partionnées. Un repartionnement intelligent et pensé pour la ou les jointures à suivre peut économiser beaucoup plus que ce qu'il coûte.
- Si une des tables est "petite" : on entend par "petit" une table qui peut tenir dans la mémoire de chacun des worker nodes (avec un peu de marge). On va alors procéder à une broadcast join (on pourrait aussi utiliser une shuffle join) : la petite table est envoyée à chaque worker node qui procède ensuite à la jointure. On a donc du traffic sur le réseau qu'une seule fois puis les noeud n'ont plus besoin de communiquer entre eux (faisant dans ce cas là de la CPU le principal bottleneck potentiel). On peut donner un indice à l'optimisateur en demandant explicitement une broadcast join (sans garantie qu'il choisisse finalement cette option) : leftTable.join(broadcast(rightTable), joinExpression, joinType).show()

Ces faits sont très stylisés, la réalité est beaucoup plus complexe et demande d'être explorée pour une meilleure optimisation.

## Chapitre 9 : Data Sources
 Le chapitre présente les 6 sources de données desquelles on peut lire et vers lesquelles on peut écrire, prises en charge par défaut par Spark : CSV, JSON, Parquet, ORC, connections JDBC/ODBC, fichiers textes. Il faut rappeler que la communauté Spark est très actives et que de nombreux connecteurs sont disponibles sous la forme de packages (ex : Cassandra, HBase, MongoDB, AWS Redshift, XML, etc.).

 Grands principes
 Lecture
 On crée un objet DataFrameReader en appelant la méthode .read sur la SparkSession. L'appel de la méthode spécifique au format à importer (éventuellement associé à quelques mutateurs .option - au moins un pour passer le chemin vers le fichier - pour passer des options) retourne ensuite un DataFrame.

Ex : spark.read.csv.
          .option("path", "path_to_file")
          .option("inferSchema", "true")
          .option("mode", "FAILFAST") // Ce qui se passe si enregistrement mal formé

Rappel : La lecture correspond à une transformation et sera donc lazily evaluated. Si on a fait une erreur en spécifiant nos options, Spark n'échouera qu'à l'exécution du job.

Remarque : Le format du fichier peut aussi être passé sous forme de String via la méthode .format. Cette dernière ne retournant qu'un DataFrameReader, il est nécéssaire de la compléter par la méthode .load qui retourne un DataFrame.

Ex : spark.read
          .format("csv")
          .option("path", "path_to_file")
          .option("inferSchema", "true")
          .option("mode", "FAILFAST")
          .load()

Remarque : On remarque que même avec un schéma (inféré ou explicitement donné), la lecture du fichier retourne un DataFrame et non un Dataset, preuve que le DataFrame n'est pas strictement non-typé.

Ecriture
On crée un objet DataFrameWriter en appelant la méthode .write sur le DataFrame à enregistrer. Comme pour la lecture, on appelle ensuite les méthodes .option nécéssaires ainsi que la méthode spécifique au format souhaité (.csv, .text, .parquet, etc.). Cette dernière méthode procède à l'écriture et n'a que ce side effect (retourne Unit).

Remarque : on peut aussi passer le format sous la forme d'une String via .format mais il faut alors lancer l'écriture explicitement avec .save.

Ex : df.write.csv.
          .option("path", "path_to_file")
          .option("dateFormat", "yyyy-MM-dd")
          .option("mode", "OVERWRITE")

Remarque : Dans le cas général pour les sources de données correspondant à des fichiers (par opposition aux DBMS), un DataFrame sera écrit non pas sur un seul fichier mais sur un ensemble de fichers (un par partition, tous contenus dans un répertoire du nom spécifié pour le fichier). Le DataFrameWriter propose ainsi les méthodes .partitionBy, .bucketBy et orderBy qui donne plus de contrôle sur la façon dont le DataFrame sera écrit sur plusieurs fichiers.

Remarques spécifiques aux formats :
CSV
Les fichiers semi-structurés CSV (par oppositions aux formats structurés comme Parquet ou ORC) peuvent prendre des formes très diverses, d'où un nombre élevé d'options.
On peut en particulier pour la lecture passer explicitement via la méthode .schema, un schéma qu'on aura spécifié manuellement à l'aide d'un objet StructType(Array[StructField]).

JSON
Spark privilégie les fichiers JSON line-delimited par rapport aux multiline, le premier format étant plus stable et permet facilement d'ajouter de nouveaux enregistrements à un ficher existant. Ces fichiers ont l'air plus normés que les CSV, d'où un nombre d'options plus réduit.

Remarque : le JSON contient-il des informations de schéma ?

Parquet
Particulièrement optimisé pour Spark, Parquet est son format de fichier par défaut. Parquet est un format de stockage open source et orienté colonne et type-aware. Chaque colonne est compressée spécifiquement suivant son type, permettant un gain d'espace. L'orientation colonne permet un accès efficace aux données : on ne lit (scan ?) que les colonnes dont on a besoin plutôt que de charger le fichier entier. C'est un format recommandé si on envisage de réutiliser les fichers : il est beaucoup plus efficace de lire un Parquet que de parser un fichier CSV ou JSON en entier. Un autre avantage de Parquet est que contraitement à d'autres formats comme CSV ou JSON, il supporte les types complexes de Spark (Map, Array et Struct).
Particulièrement bien aligné avec les spécifications de Spark, on a donc très peu d'options pour la lecture / écriture des fichiers Parquet.
Une des options est le choix de la méthode de compression. Spark recommande Parquet avec gzip.

ORC (Optimized Row Columnar)
Semblable à Parquet dans sa dimension type-aware et orienté-colonnes, ORC est un format conçu pour Hadoop et optimisée pour de grosses lectures (large streaming reads) et l'accès rapide aux lignes demandées. Les différences avec Parquet sont faibles (à creuser), Parquet est présenté comme plus optimisé pour Spark là ou ORC l'est plus pour Hive. De même, assez peu d'options sont disponibles pour ce format adapaté à Spark.

Fichiers textes
Ce format est typiquement celui de problèmes comme l'analyse de logs, u language, etc. Chaque ligne du fichier texte lu devient un enregistrement du DataFrame. Spark distingue deux méthodes à la lecture : .text et .textFile suivant si on souhaite lire un fichier suivant ses partitions ou pas (.textFile doit lire l'ensemble des partitions comme un seul fichier alors que .text doit permettre de "tenir compte" des différentes partitions à la lecture).
A l'écriture, la principale précautions à prendre est de s'assurer que le DataFrame consiste en une unique colonne de String. Ecrire plusieurs colonnes semble possible mais ce n'est pas très clair (p. 173).

Bases SQL
Spark permet de lire depuis n'importe quelle base de type SQL (MySQL, SQLite, postgreSQL, Oracle, etc.) pourvu qu'on inclut le driver JDBC/ODBC adapté. Celà demande deux choses :
- Inclure le driver JDBC/ODBC au classpath de Spark
- Fournir le JAR du driver
Cela peut se faire en une seule commande dans le Spark shell (p.166)

Suivant la base de données, plus ou moins de paramétrage sera requis. Par exemple, certaines comme postgreSQL vont demander un identifiant et un mot de passe.

Query pushdown
On avait vu que si la source était une base SQL, Spark etait capable de déplacer l'exécution de certaines transformation directement lors du requêtage de la base (chose permise par le fait que la lecture est aussi une transformation lazily evaluated : on a le temps de voir quel est l'ensemble des traitements à effectuer pour voir si certains ne peuvent pas déjà être déjà fait dès la lecture de la source). Cela ne sera pas le cas de toutes les transformations, Spark n'étant pas capable de tout traduire en SQL. Ce sera par exemple fréquemment le cas de transformations select ou filter simples.
On aussi spécifier à la lecture la table qu'on veut récupérer. Il faut alors passer à l'option "dbtable" une requête sous un format particulier (subquery). Là encore, cela nous économise la montée en mémoire d'une table qui ne nous sert que partiellement.

Lectures parallèles :
Spark est capable en fonctions de la taille, du nombre, de la divisibilité et de la compression des fichiers à importer de les lire en une ou plusieurs partitions. Dans le cas des bases de données, cette fonctionnalité demande un peu de paramétrage : on doit par exemple spécifier un nombre maximal de partitions (option "numPartitions") de façon à limiter le nombre d'accès parallèles en lecture/écriture à la base de données afin d'éviter de la surcharger.

On peut aller plus loin en contrôlant la localisation physique de certaines données dans des partitions. On peut ainsi spécifier et passer ce qu'on appelle des prédicats qui sont en fait ce qu'on passerait à une clause WHERE en SQL. Le produit de chaque prédicat est chargé dans une partition. Si plusieurs prédicats, veiller à ce qu'ils ne se recouvrent pas ou on peut finir avec de nombreux doublons.

I/O concepts
Divisibilité : dans ce paragraphe elle semble s'entendre comme la capacité contribuant à augmenter la vitesse de lecture, de ne lire que les parties d'un fichier qui nous intéressent plutôt que le fichier entier. Cette caractéristique peut se heurter à la compression car tout les formats comprimés ne sont pas divisibles. Ces deux concepts et les choix faits pour eux peuvent avoir d'importantes conséquences sur la performance des jobs Spark.
Parallélisme :
De multiples exécuteurs ne peuvent pas nécéssairement lire d'une même source de données en mêmes temps, il peuvent par contre lire différents fichiers simultannément (chacun devenant une partition).
Partitionement à l'écriture
Comme déjà dit, lorsque Spark écrit un fichier, il ne crée par un seul fichier. Il crée en fait un répertoire du nom de fichier qu'on lui a passé et y écrit par défaut un fichier par partition.
On peut choisir de partitionner le répertoire en différents sous répertoire suivant les valeurs d'une colonne par exemple, tous les fichiers d'un même sous répertoire contenant alors les enregistrement d'une même valeur de la colonne utilisée pour la partition. Cela est particulièrement utilse si on filtre souvent sur cette colonne : on ira alors chercher uniquement les fichiers qui nous intéresse dès la lecture avec le gain de perfomance associé. Ex: on analyse souvent que la dernière semaine de logs, on va donc partionner le stockage sur le jour.
Cette propriété est gérée par la méthode .partitionBy du DataFrameWriter.

Bucketing
Le bucketing permet d'avoir un contrôle sur quelles données sont physiquement écrites sur chaque fichier. Cela permet quand on les charge d'avoir directement un partionnement qui minimise les shuffles pour les transformations à venir. Les données avec la même bucket ID seront toutes regroupées dans la même partition. On prépartionne en fait les données suivant les transformations qu'on sait effectuer plus tard.
Cette propriété est géré par la méthode .bucketBy du DataFrameWriter.

Contrôler la taille des fichiers :
Cela peut être nécessaire car trop de petits fichiers sont souvent un facteur de baisse de performance pour des outils comme Spark ou HDFS par exemple. A l'opposer, avoir de trop gros fichiers peut aussi s'avérer inefficace si on ne les charge que pour quelques lignes.
Depuis Spark 2.2, Spark propose l'option maxRecordPerFile permettant à l'utilisateur de limiter la taille des fichier à une valeur lui semblant optimale.

Pour plus de détail sur ces notions, voir : https://www.youtube.com/watch?v=F9QhzT_YTWw

## Chapitre 10 : Spark SQL
Ce chapitre est d'autant plus clair qu'on est familier du fonctionement des bases de données relationnelles dont SparkSQL repend la terminologie.

SQL est un DSL permettant d'exprimer des opérations relationnelles sur des données. C'est un language extrêmement répendu, utilisé dans toutes les RDBMS et duquel beaucoup de bases dites NoSQL dérivent leur propre dialecte pour faciliter l'adoption de leur système.

Avant Spark, Apache Hive était le point d'accès SQL du big data. Depuis notamment Spark 2.x, Spark ne fait plus simplement que supporter Hive mais s'est doté de son propre parser SQL capable d'analyser aussi bien des requêtes ANSI-SQL que du HQL. L'interopérabilité avec l'API DataFrame est un vrai facteur favorisant l'adoption.

De plus, Spark peut aussi devenir l'engin d'exécution de requêtes anciennement passées à d'autres systèmes (comme Hive) en mettant à disposition le Thrift Server (JDBC interface) via lequel des applications extérieures peuvent soumettre leurs requêtes (exemple : on veut connecter notre outil de BI comme Tableau à Spark). Il semble que le Server Thrift JDBC/ODBC actuellement implémenté est le même que le HiveServer2 de Hive 1.2.1.

SparkSQL s'incrit aussi dans un ensemble d'API plus large visant à offrir aux data scientists (et donc pour les pousser à adopter) l'ensemble des traitements qu'ils pourraient réaliser au sein d'un même outil : on extrait les données avec SparkSQL, les transforme avec DataFrame puis les passe à MLlib par exemple.

Remarque : Spark SQL est conçu pour un contexte OLAP (OnLine Analytic Processing) et non OLTP (OnLine Transaction Processing) : l'outil n'est pas conçu pour réaliser des requêtes avec une très faible latence.

Comment exécuter une requête SQL Spark ?
- via le Thrift Server JBDC/ODBC
- via la CLI Spark SQL (./bin/spark-sql) qui pour information n'a pas accès au Thrift Server (passer par la CLI n'est pas équivalent à passer par le Thrift Server)
- via l'interface de programmation : on passe la requête sous forme de String à la méthode .sql de la SparkSession. Preuve le l'interopérabilité avec l'API DataFrame, la méthode .sql retourne un DataFrame, on peut dont passer de l'un à l'autre suivant ce qu'on trouve de plus facile.

Quand on passe une requête SQL pure, sur quoi s'éxécute-t-elle ? Où Spark va-t-il chercher ce qu'on passe au FROM ?
Que les traitements soient décrits via les API SparkSQL, DataFrame ou Dataset, après analyse, tout passe dans l'optimisateur Catalyst. Une des premières étapes est la name resolution faite à l'aide du Catalog Spark. Si le nom passé à FROM (comme tous les noms de colonnes ou de fonctions) s'y trouve, le traitement va s'effectuer. (Rq : dire que Spark SQL va chercher n'est pas vrai, il faut retenir que quelque soit l'API utilisée tous les traitements s'effectuent de la même manière).

Peut-on comparer le Catalog Spark au Hive Metastore ? Peut-on faire communiquer les deux pour qu'une requête passée à SparkSQL puisse s'exécuter sur des données décrites dans le Hive Metastore ?

Dans le cas de SparkSQL, la table doit être disponible depuis une base de données (Spark doit donc avoir un moyen de savoir que la table X se trouve dans la base Y) soit on a crée une table à partir d'un DataFrame via createOrReplaceTempView, createTempView, createOrReplaceGlobalTempView ou createGlobalTempView (qui ne retourne rien, Unit). On peut aussi directement créer des tables via SQL à partir d'une source de données (CREATE TABLE ... USING ...).

Le Catalog est un abstraction reouvrant le stockage des métadonnées à propose de nos donnés mais aussi d'éléments comme des databases, tables, views et functions :
- Une database se définie comme un ensemble de tables. Si on change de database, il va falloir s'y prendre autrement pour requêter les tables de l'ancienne. On peut voir cela comme un environnement. Rejoignant ce qui a été dit un peu plus haut : "Any SQL statement that you run from within Spark (including DataFrame commands) execute within the context of a database".
- Une table est une structure de données sur laquelle on exécute des commmandes. Remarque : la différence entre une table et un DataFrame est que la première est définie à l'intérieur d'une database là ou le second l'est dans le scope du language de programmation (ex : le nom du DataFrame est dans le scope de Scala, le nom d'une table est stocké ailleurs). Comme un DataFrame, une table peut être cached ou uncached.
- Une view est un ensemble de tranformations à réaliser sur une table existante. Une view peut être globale ou locale à une Session. La différence entre supprimer une view et supprimer une table est que le premier cas n'implique pas de suppression de données (contrairement au second) mais seulement la définition de la view.

Remarque : SparkSQL permet d'utiliser les types complexes Spark dans des requête SQL. SparkSQL met aussi à disposition un large ensemble de fonctions optimisées et laisse aussi à l'utilisateur la possibilité d'utiliser ses propres UDF à l'intérieur d'une requête SQL. Comme rappelé, quelle que soit l'API utilisée logical plan sera le même.
Comme surement de nombreux moteurs SQL, Spark autorise l'utilisation de sous-requêtes (sub-queries : la requête doit agir avec ou sur le résultat d'une autre requête intégrée à l'ensemble). On distingue deux types de sub-query : corrélé et non-corrélé.

## Chapitre 11 : Datasets
Les Dataset sont uniquement une feature des languages JVM Java et Scala  (pour lesquels DataFrame = Dataset[Row], pour les autres languages, il n'y a que l'API DataFrame) . Les Datasets permettent de définir en quel objet consiste chaque ligne (case class en Scala, Java Bean en Java).

Spark possède ses propres types auquels correspondent des types équivalents dans les différents languages natifs. Dans l'API DataFrame, on ne crée pas de types comme String, Integer, etc., Spark manipule les données à l'aide du type complexe Row. Dans les Dataset[T], Spark a recourt aux Encoders pour faire la correspondance entre de domain-specific type T et ses types internes.

Pour un Dataset[Person] (Person ayant deux attributs, age et name), un Encoder permet à Spark de générer du code à l'exécution lui permettant de sérialiser l'objet Person dans un format binaire. Dans l'API DataFrame, cette structure binaire est une Row. Dans un Dataset, pour chaque ligne du Dataset, Spark convertit l'objet Row vers le type d'objet spécifié. Cette conversion s'accompagne d'un impact sur la performance.

La documentation confirme que les Encoders permettent de profiter de Tungsten :
"To efficiently support domain-specific objects, an Encoder is required. The encoder maps the domain specific type T to Spark's internal type system. For example, given a class Person with two fields, name (string) and age (int), an encoder is used to tell Spark to generate code at runtime to serialize the Person object into a binary structure. This binary structure often has much lower memory footprint as well as are optimized for efficiency in data processing (e.g. in a columnar format). To understand the internal binary representation for data, use the schema function"

Pourquoi alors utiliser un Dataset ? Deux principaux arguments :
- Quand les opérations qu'on souhaite réaliser ne peuvent pas être exprimées comme manipulations de DataFrames.
- Quand désire la compile-time safety au détriment d'un peu de performance.

Sur le premier point : il existe des opérations qui ne peuvent pas être exprimées via Spark SQL ou DataFrame et qui pourraient être encodées dans une fonction par exemple. C'est un usage approprié pour les Datasets qui sont en plus type safe : si l'opération n'est pas valide pour certains types, Spark va échouer à la compilation et non à l'exécution. => Les Datasets peuvent permettre d'encoder une opération custom sans utiliser d'UDF ? et donc de perdre moins de performance ?

Il faut voir les API DataFrame et Dataset comme complémentaires : on utilise les Dataset quand on en a besoin comme par exemple juste avant de collecter les données sur le driver. Elles seront ainsi directement du bon types pour d'éventuelles manipulations en local. Le plus souvent on utilisera un Dataset au tout début ou à la toute fin d'un data pipeline.

Créer un Dataset a une dimension manuelle équivalent à la définition manuelle d'un schéma. En Scala on va ainsi définir sa case class T puis convertir un DataFrame df à l'aide de la méthode .as : df.as[T] (on parle de "casting Rows into our specific type T").

Actions : quand on collecte les données sur le driver on obtient avec un Dataset un Array[T] et non un Array[Row]. Conséquence, on s'économise une pénible type coercion nécessaire dans le second cas si on souhaite travailler sur des données typées.

Transformations : les transformations s'appliquant aux DataFrames s'appliquent de la même façon aux Datasets. Les Datasets possèdent aussi quelques transformations qui leurs sont spécifiques (sur les jointures (joinWith) et le groupage (groupByKey et les méthodes associées à l'objet retourné)).

Il semblerait que les DataFrame présentent une alternative moins couteuse aux UDF : pas sûr, les lambdas qu'on peut facilement utiliser sur les Dataset car typés semblent tout aussi opaques à Catalyst que les UDF, la différence semble être qu'utiliser ces lambdas est moins lourd (on a pas à les enregistrer). Les fonctions (dite génériques) sont quand mêmes opaques pour Catalyst mais les Encoders permettent quand même de profiter du format Tungsten. **Il faut surtout comprendre que quand on passe une expression à un filter, withCol, map, etc. : il faut le plus possible utiliser les expressions optimisables par Catalyst, en particulier, utiliser des lambdas est déconseillés car ils sont opaques pour l'optimisateur.** Même si on a plein de syntaxes possibles pour un filtre par exemple, toutes n'ont pas la même performance.
Ex :
df.filter($"ORIGIN_COUNTRY_NAME" === $"DEST_COUNTRY_NAME") // Optimisable par Catalyst

def originIsDestination(flight_row: Flight): Boolean = {
  return flight_row.ORIGIN_COUNTRY_NAME == flight_row.DEST_COUNTRY_NAME
}
df.as[Flight]
  .filter(flight_row => originIsDestination(flight_row))
  // Opaque à Catalyst => voir avec .explain qu'il n'y a pas de pushdown.

Les Datasets ont une untyped view appelée DataFrame correspondant à Dataset[Row].

Remarque : certaines transformations (retournant d'ailleurs un Dataset) ne prennent qu'un lambda en arguments (et ne sont disponibles qu'en Scala ou Java) : map, flatMap, mapPartitions. La version type-safe de filter ne prend qu'un lambda en argument. groupByKey

UDF vs lambdas : p.202, laisse entendre que les UDF ne profitent pas de Tungsten. UDF de DataFrame : rôle du typage ?

Jointure : Les Datasets on une jointure spécifique : joinWith qui retourne une structure complexe sous la forme d'un tuple2 : chaque colonne est un Dataset, la colonne de gauche contient les lignes où la jointures était possible et celle de droite un Dataset regroupant l'ensemble des lignes pour lesquelles la jointure était possible.

Agrégation : Les Datasets on accès à des méthodes d'agrégation typées, retournant un Dataset. Il faut pour cela en passer par groupByKey qui ne prend pas d'expressions colonnes mais uniquement un lambda (ex: df.groupByKey(x => x.DEST_COUNTRY_NAME)) et qui retourne un objet KeyValueGroupedDataset. Les méthodes de KeyValueGroupedDataset sauf exception (.count) ne prennent en argument que des fonctions (génériques) définies pour agir sur chacun des groupes. Cela induit plus de travail pour en plus utiliser des fonctions qui n'auraient pas forcément accès à toutes les optimisations qu'offrent Spark (à préciser). Pourquoi utiliser des Datasets, quels bénéfices pour tous ces coûts ?

Attention : comme pour toutes les transformations prenant un lambda en argument, on perd en performance du fait que ces fonctions ne peuvent pas être optimisées par Spark et qu'on "introduit des types JVM" (p.203) et donc des de la pression sur le GC (?). Je croyais que les Encoders permettaient d'avoir accès aux optimisations Catalyst et donc à la Ser/Deser ?

## Chapitre 12 : Resilient Distributed Datasets (RDDs)
L'API RDD fait partie des Low-Level APIs qu'on au normalement depuis Spark 2.x assez peu à utiliser sauf :
- Si on a besoin d'accéder à des fonctionnalités que les APIs de plus haut niveau ne sont pas capable d'apporter comme un contrôle fin de la distribution des données sur le cluster (en implémenant un Partitioner custom).
- Si on doit maintenir du legacy code écrit avec des RDDs.
- Si on a besoin d'une gestion des variables partagées custom.
Les API de plus bas-niveau permetten un contrôle plus fin mais contrairement aux APIs de plus haut-niveau qui optimisent pour nous, laissent au développeur la responsabilité d'optimiser les performance. Vu autrement, étant responsable de nos optimisations, Spark n'est plus là pour nous empêcher de nous tirer une balle dans le pied. On doit avoir une vraie bonne raison d'utiliser les Low-Level APIs, pour les reste, préférer les DataFrame qui sont plus performants, plus stables et dont le code est plus expressif (car conçu comme DSL).

Remarque : les Low-Level APIs sont accessibles via l'attribut SparkContext de la SparkSession : spark.SparkContext

Un RDD est une collections immutable et distribuée d'enregistrement pouvant être traités en parallèle. L'API RDD est compile type-safe. Contrairement aux DataFrames où chaque ligne contient un ensemble de champs dont le schéma est connu, un RDD est très général, les enregistrements consistant en des objets Scala/Java/Python. On peut stocker ce qu'on veut dans ces objets, en revanche du fait de la généralité du RDD, l'API ne propose que peu de méthodes applicables un RDD quelqu'il soit : au programmeur de redéfénir tous les outils nécessaires à l'interaction avec les données.
Comme déjà dit, les objets des RDD sont opaques à Spark : ne pouvant s'en donner une représentation interne compatible avec ses méthodes d'optimisation, aucune des optimisations possibles dans la Structured API par exemple ne peut s'appliquer aux RDD. Par ailleurs, les Dataset visaient à réunir le meilleur des DataFrames (optimisations) et des RDD (type-safety) : les Encoders permettent de faire le pont, de donner à Spark une compréhension, une représentation optimisable des objets constituant le Dataset. Un Dataset n'est pas un simple RDD de case classes du fait de ces optimisations, par exemple qu'on utilise des types Spark et non des types JVM.

Il existe de nombreux types de RDD mais l'essentiel ne constitue que des représentations internes utilisées par l'API DataFrame. Un usage normal de la Low-Level API ne fait normalement appel qu'à deux types de RDD :
- Le RDD classique
- Le key-value RDD qui offre des fonctionnalités supplémentaires notamment pour l'aggrégation et le partionnement par clé.

Formellement, un RDD se caractérise par :
- Une liste de partitions
- Une fonctions pour calculer chaque split (?)
- Une liste des dépendances à d'autres RDDs (lineage ? pour la fault-tolerance ?)
- Pour les key-value RDD, un Partitioner (qui peut être une des raisons pour lesquelles on vient utiliser ces API de bas niveau)
- Optionnellement, une liste des emplacements à privilégier pour le calcul de chaque split (ex : localisation des blocs pour HDFS) (data localisation ?)

La capacité de Spark à planifier et exécuter l'exécution d'un programme repose sur ces propriétés.

Remarque : Les performances des RDDs Scala et Java sont voisines, elles sont en revanche substantiellement inférieures pour les RDDs Pythons pour les mêmes raisons que l'utilisation d'UDF Python dégradent la performance.

Créer un RDD :
On peut facilement passer des API RDD à DataFrame/Dataset (.toDF) ou l'inverse (.rdd). Dans le dernier cas, on obtient un RDD[Row] et opérer alors sur ces données va demander de convertir les Row vers le bon type d'objet ou d'extraire les éléments de chaque type.
Ex: spark.range(10).toDF().rdd().map(rowObject => rowObject.getLong(0))

Pour créer un RDD depuis une collection locale, utiliser parallelize :
val myCollection = range(100)
val numbers = sparl.SparkContext.parallelize(myCollection, 2)
// On crée deux partitions
On peut aussi créer des RDD à partir de sources de données, le SparkContext possède quelques méthodes pour celà. Sinon on importe des données sous la forme d'un DataFrame et qu'on convertit ensuite.

Différence majeure entre RDD et les autres API comme les DataFrames : on manipule des objets Scala / Java bruts plutôt que des types Spark (p.215). C'est la différence avec les DataFrame qui utilise le type Spark Row pour manipuler les données, ou les Dataset qui imposent des restrictions sur les objets Scala/Java en même temps que les Encoders permettent à Spark de se donner une représentation de ces objets dans ses types internes.

Remarque : comme pour les DataFrames, les opérations sur les RDD distinguent tranformations et actions. Une transformation retourne un nouvel RDD et un ensemble de tranformations est lazily-evaluated. En même temps qu'on effectue une transformation, on ajoute au RDD retourné une dépendance au RDD transformé.

Les RDD possèdent tout de même un ensemble de méthodes classiques mais contrairement aux DataFrames, on a pas la syntaxe du DSL, à chaque méthode doit être passée une fonctions / lambda adapté. On a par exemple : filter, distinct, map, flatMap, sort, etc. En actions on compte entre autres : count, reduce, take et ses variantes, saveAsTextFile, etc.

Caching / Checkpointing
Comme un DataFrame, un RDD peut être mis en cache (on dit aussi persister) (méthode .cache). Le type de stockage peut être choisi parmi les valeurs de org.apache.spark.storage.StorageLevel.

Un RDD peut aussi être checkpointé. Cette action consiste à sauver le RDD sur le disque de façon à ce qu'on puisse utiliser ses partitions plus tard sans avoir à tout recalculer.

Autres fonctions :
pipe : la méthode pipe retourne un RDD donc chaque élémént est le produit d'un élément du RDD d'entré passé à une commande système (shell).

On peut aussi agir, appliquer des fonctions à l'échelle de la partition (mapPartitions, foreachPartition qui est son pendant sans valeur de retour), chaque partition étant représentée par un objet Iterator.

## Chapitre 13 : Advanced RDD
Le chapitre aborde principalement les key-value RDD (pairRDD) dont il existe des tonnes d'exemples sur internet (vu que les RDD ont été l'unique API disponible pendant longtemps).
Il existe un grand nombre de méthodes qui demandent que le RDD sur lequel elles s'appliquent soient un PairRDD (méthodes en *ByKey).
Pour créer simplement un PairRDD, on peut utiliser la méthode .keyBy.
Ex : val keyword = words.keyBy(word => word.toLowerCase.toSeq(0).toString)
On peut ensuite appliquer des méthodes comme map ou flatMap qui s'appliqueront aux valeurs, Spark partant du principe que le premier des deux éléments de chaque tuple est toujours la clé.

On peut facilement récupérer les clés ou les valeurs : myRDD.keys / myRDD.values.

Aggrégation : groupByKey vs reduceByKey
Les PairRDD proposent deux principales stratégies d'agrégation :
- groupByKey : avant d'agréger, chaque exécuteur doit posséder toutes les clés à agréger. L'agrégation se fait ensuite au niveau de chaque partition. Cela a deux principaux désavantages : un shuffle potentiellement important et en cas de key-skew important, certaines partitions ne tiendront plus en mémoire (OutOfMemoryErrors). Peu recommandé.
- reduceByKey : on agrège par clé au sein de chaque partition puis shuffle pour l'agrégation finale. Méthode plus stable. Exige certaines propriétés pour la fonction d'agrégation ?

Spark propose d'autres méthodes d'agrégation peu utilisées permettant un contrôle plus fin de l'exécution : se fait-elle par partition, par clé, combien de partitions en sortie, utiliser deux fonctions d'agrégation : une à l'intérieur de chaque partition, une pour entre les partitions, etc.

Remarque : Il semblerait que l'agrégation avec groupBy sur les RDD de base suive le même principe que le groupByKey. Vu que l'agrégation n'est pas vraiment abordée dans le chapitre 12, il semblerait que le PairRDD soit l'objet recommandé pour les agrégations sur RDD.

Jointures :
On retrouve les 4 types de jointures pour joindre des RDD par clés. On y ajoute .cogroup qui donne des résultats dans le même esprit que joinWith pour la Structured API. Ajouter zip qui permet de juxtaposer (col_bind) deux RDD de même nombre de partitions et de partitions de même taille pour former un PairRDD.

Contrôle du partitionnement :
Se fait principalement à l'aide de
- coalesce : permet de réduire le nombre de partition sans shuffle (ou le moins possible). On essaye d'atteindre la cible de nombre de partitions le plus possible en fusionnant des partitions situées sur la même machine.
- repartition (ou repartitionAndSortWithinPartitions): permet d'augmenter ou de réduire le nombre de partitions mais sans restrictions sur l'utilisation du shuffle.

Repartionnement custom :
Le seul objectif d'une telle opérations est d'égaliser la distributions des données au sein des différentes partitions, d'atténuer un data skew (e qui peut faire la différence entre un job qui termine vite et un autre qui ne termine jamais). Cette possibilité n'est offerte que par l'API RDD, si on travaille avec des Dataset/DataFrame, on sera obligé de basculer sur des RDD avant de revenir sur l'API de plus haut niveau.

Saprk possède deux Partitioners : HashPartioner pour les valeurs discrètes et RangePartitioner pour les valeurs continues. Bien qu'utiles ils sont assez rudimentaires et travailler sur des données très volumineuses avec un fort key-skew impose de repartionner ces clés pour améliorer le parallélisme de l'appliation et éviter les OutOfMemoryErrors pendant l'exécution.
Pour définir notre propre Partioner, il faut définir une classe héritant de Partioner et réimplémenter les méthodes numPartitions et getPartition. On passe ensuite l'objet à la méthode partitionBy : myRDD.partitionBy(new myPartitioner).

Remarque : je ne comprends pas comment l'exemple de la page 236 repartionne de façon plus équilibrée.

Sérialisation custom (utiliser Kryo sur ses propres classes)
Spark utilise la sérialisation Java qui peut être assez lente et propose Kryo (utilisée par défaut depuis Spark 2.0 pour les types les plus simples/communs) qui est une alternative plus compacte et jusqu'à 10 fois plus rapide. Problème, Kryo ne supporte pas tous les types sérialisables et impose d'enregistrer les classes utilisées dans le programme (et sur lesquelles on souhaite utiliser Kryo) à l'avance pour une meilleure performance. Si on souhaite donc utiliser Kryo sur certaines de nos classes (devant hériter de Serializable), il va falloir les enregistrer dans un objet de configuration SparkConf avant d'instancier son SparkContext (val sc = new SparkContext(myConf)).

## Chapitre 14 : Distributed shared variables
Autre "API" de bas niveau, Spark propose deux types de variables partagées distribuées : les broadcast variables et les accumulators.

Broadcast variables:
Les broadcast variables permettent de partager une valeur immutable eficacement sur l'ensemble du cluster sans avoir à encapsuler la variable dans une closure. Référencer une variables dans une closure peut en effet être assez inefficient, notamment si la variables est assez volumineuse (grosse LU table, modèle de machine learning) car une variable incluse dans une closure doit être désérialisée à chaque task (les UDF sont en effet propagées à chaque noeud via une sérialisation).

Une broadcast variable est une variable partagée et imutable mise en cache sur chacune des machines du cluster (économisant la désérialisation). Pour broadcaster une variable, on utilise la méthode .broadcast du SparkContext, la valeur est alors répartie (lazily) sur l'ensemble du cluster au déclenchement d'une action en dépendant.

Ex : val myBvariable = spark.sparkContext.broadcast(someLUTable)

On y accède à l'intérieur d'une fonction via la méthode .value :

Ex : myBvariable.value

Les fonctions y faisant référence sont sérialisées mais pas les broadcast variables éventuellement sollicitées, ce qui économises des coûts de SerDe. Le gain présenté par l'utilsation de telles variables dépend du nombre d'exécuteurs et surtout du volume de données à partager : les gains sur les coûts de SerDe sont d'autant plus importants que le volume de données est élevé.

Accumulators :
Un Accumulator est une variable mutable (contrairement à la broadcast variable) stockée sur le driver et dont la valeur peut être updatée par une variété de transformations, on a per row basis, la nouvelle valeur étant remontée de manière efficiente et fault-tolérant au driver (la valeur updatée ou l'incrément à passer ?). L'opération d'accumulation doit être associative et commutative pour être efficacement supportée en parallèle. Spark supporte nativement des Accumulators de type numériques mais le développeur peut ajouter le support pour d'autes types.

Un exemple classique est l'implémentation de compteurs pour le débugage. On distingue les named et unnamed Accumulators, les named Accumulators seront visibles dans la web UI de Spark.

On distingue les Accumulators updatés par une action de ceux incrémentés par une transformation. Pour ceux updatés à l'intérieur d'une action (comme foreach), Spark garantit que l'incrément n'est appliqué qu'on fois par task (il n'est pas réappliqué si une task doit se réexécuter).

Un Accumulator ne change pas la lazy-evaluation : un accumulator situé dans une transformation n'est updaté que lorsque le RDD concerné est calculé, c'est à dire quand une action est lancée sur lui ou sur un RDD en dépendant.

Un Accumulator doit être instancié puis enregistré. On écrit ensuite une simple fonctions générique qui appliquée à chaque ligne, détermine si et de combien l'Accumulator est updaté. Dans le cas du LongAccumulator nativement supporté par Spark, on update simplement à l'aide de la méthode .add à laquelle on passe une valeur numérique. On peut accéder à la valeur de l'Accumulator avec .value (ou aller la voir dans l'UI Spark s'il est named).

Ex :
import org.apache.spark.util.LongAccumulator
val myNamedAcc = new LongAccumulator
// val myNamedAcc = spark.sparkContext.accumulator("name") marche aussi
spark.sparkContext.register(myNamedAcc, "name")
def myAccFunc(single_row: T) = {
...
myNamedAcc.add(...)
...
}

Custom Accumulator
Si on veut créer sont propre Accumulator, il va falloir créer une nouvelle classe héritant de org.apache.spark.util.AccumulatorV2 et réimplémenter un certain nombre de méthodes.

## Chapitre 15 : How Spark runs on a cluster
On s'attache ici à décrire l'éxécution de code par Spak de façon agnostique quant au language de programmation et au cluster manager utilisé.

Architecture d'une application Spark :
Le driver : ce process contrôle l'exécution de l'application Spark. Il doit interagir avec le cluster manager dans le but d'obtenir des ressources physiques et de démarrer des exécuteurs.
Les exécuteurs : les exécuteurs sont des process chargés d'exécuter les tâches qui leur sont assignées par le driver et de remonter à ce dernier l'état de cette exécution (succès ou échec).
Le cluster manager : il est responsable de la gestion du cluster sur lequel tournent une ou plusieurs applications Spark (entre autres). Lui aussi son driver node et ses worker nodes (quoique ceux-ci sont attachés à une machine physique plutôt qu'à un process). Sur chacun de ces noeuds tourne un deamon à qui incombe la gestion. Au démarrage de l'application Spark, on demande des ressources à ce cluster manager, le détail de cette demande dépendant de la configuration de l'application.

Modes d'exécutions
On en distingue trois :
- Cluster mode : C'est le cas le plus fréquent, on soumet un JAR ou un script R/Python au cluster manager qui va ensuite lancer le driver de l'application sur un des worker nodes du cluster. Le cluster manager gère alors le driver et les exécuteurs.
- Client mode : Identique au cluster mode sauf qu'on impose que le driver Spark reste sur la machine cliente qui a soumis l'application. Cette derière a alors la charge de gérer le driver, le cluster manager ne gérant que les exécuteurs. La machine du driver ne fait pas partie physiquement du cluster (pas de colocalisation) et est souvent appelée gateway machine ou edge node.
- Local mode : L'intégralité de l'application tourne sur une même machine physique. Le parallélisme est permis par d'utilisation de multiples threads. Ce mode permet un développement et test aisé d'une application Spark.

Cycle de vie d'une application Spark (vu de l'extérieur de l'application):
- Requête du client : On soumet le code de notre application en contactant le cluster manager auquel on demande des ressources physiques pour le démarrage du driver process de l'application. S'il accepte, le driver est lancé sur des worker nodes du cluster.
- Démarrage de l'application : le driver étant lancé sur le cluster, il peut commencer à éxécuter le code du client. Ce code doit instancier une SparkSession permettant d'initialiser le cluster Spark (driver + exécuteurs). La SparkSession va s'adresser au cluster manager pour pouvoir démarrer les exécuteurs à travers le cluster. Le nombre d'exécuteurs et leur configuration se règle dans la configuration de l'application (?) ou via la ligne de commande passée à spark-submit.
- Exécution : le driver réparti les tasks sur chaque exécuteur. Ces derniers communiquent entre eux, exécutent les instructions, déplacent des données sur le cluster et reportent le statut de chaque task au driver.
- Complétion : L'application se complète, le driver se ferme avec un statut échec ou succès. Le cluster manager se charge de fermer les exécuteurs. On peut connaître le statut de l'application (échec ou succès) auprès du cluster manager.

Cycle de vie d'une application Spark (vu de l'intérieur de l'application)
La SparkSession
En dehors des outils interactifs (CLI Spark), l'utilisateur doit explicitement créer une SparSession pour son application. Sans celle-ci le code de l'application ne pourra être exécuté.
Ex : 
import org.apache.spark.sql.SparkSession
val spark = new SparkSession.builder().appName("mySparkApp")
		.config(...)
		.getOrCreate()
		
L'objet SparkSession est une nouveauté introduite dans Spark 2.0. Du code utilisant les versions 1.x utilisera vraisemblablement les objets SparkContext mais aussi d'autres contextes suivant s'il fait appel à d'autres API (typiquement le SQLContext ou le HiveContext pour la Structured API). Ces legacy contexts restent accessibles depuis l'objet SparkSession. La SparkSession reste à privilégier car elle déclare les différents contextes de manière plus robuste et sans conflits (il arrivait avant que différentes librairies essayent de créer plusieurs contextes au sein de la même application). 

L'objet SparkContext de la SparkSession représente la connexion au cluster et permet aussi la communication avec des APIs de plus bas niveau comme les RDD. A travers le SparkContext on peu créer des RDD, des Accumulators, des broadcast variables et exécuter du code sur le cluster. 

Intructions logiques
Un code Spark consiste essentiellement de transformations et d'actions que celui ait été élaboré à l'aide de RDDs, de SQL, d'algorithmes de ML, etc. In fine tout est traduit en termes de RDDs.

Jobs/Stages/Tasks
Jobs : En général on a un job Spark par action appelée. Chaque job se décompose en stages.
Stages : On en a une par shufle operation. Elle se subdivise en tasks. Une stage regroupe un ensemble d'opération exécutable sur une même machine sans avoir à réallouer les données. Spark essaye naturellement de compacter le plus possible d'opérations dans une seule stage ou dit autrement, de minimiser le nombre de stages nécessaires à l'exécution du job. Un shuffle représente un repartionnement (physique) des données sur le cluster qui implique une coordinations des différents exécuteurs et des mouvements de données au sein du cluster.
Remarque : à l'issue d'une opération de shuffle (sauf celles déclanchées par .repartition), Spark retourne par défaut (paramètre spark.sql.shuffle.partitions) un nombre (200) de partitions. Globalement il faut choisir un nombre de partitions qui soit un multiple du nombre d'exécuteurs pour exploiter le parallélisme (chaque exécuteurs pouvant utiliser plusieurs coeurs et/ou lancer plusieurs threads).
Tasks :  Une task correspond à une combinaison d'un ensemble de transformations appliquée à une partitions des données (consistant elle-même physiquement de plusieurs blocs de données) prise par un seul exécuteur. Ainsi si on a qu'une seule partition pour nos données, on aura qu'une task. Une task est une unité de travail appliquée à une partition (unité de données). Plus on a de partitions, plus on peut profiter de la parallélisation (jusqu'à un certain point).

Pipelining :
Contrairement à ses prédécesseurs comme MapReduce et c'est ce qui fait de Spark un "in-memory computation tool", Spark exécute le plus possible d'étapes d'un calcul avant d'écrire les données de la mémoire sur le disque. Pour ce faire, Spark réalise une optimisation appelée Pipelining qui se fait au niveau RDD et en dessous. Avec le pipelining, toute séquence d'opérations dont les données de sortie de l'une peuvent être les données d'entrée de l'autre sans nécessiter de transfert physique des données sont chaînées au sein d'une même task. Il s'agit en fait de suites de narrow-transformation, cette optimisation est réalidées quelle que soit l'API utilisée au départ car in fine tout est transcrit en RDD. Ce pipeline permet de garder les données en mémoire et est ainsi par construction plus efficace que d'écrire les données intermédiaires sur le disque à chaque fois. Cette optimisation est réalisée automatiquement et est donc transparente.

Shuffle persistence
Lorsque Spark doit effectuer un shuffle, il demande d'abord aux source tasks d'écrire des shuffle files sur leurs disques locaux. Les tasks de grouping/reduction vont aller chercher dans les shuffle files les enregistrements les intéressant, les rapatrier sur leurs machines puis réaliser les calculs demandés. 
Sauver les données sur le disque permet deux choses :

- Si jamais une reduce task (task en aval du shuffle) échoue, on peut retenter les calculs sans voir à refaire tous les calculs précédent le shuffle. 
- Si jamais on a trop peu d'exécuteurs pour réaliser toutes les reduces tasks en parallèle (donc en une fois), on va pouvoir réaliser un ensemble de ces taches sur une partie des données, puis ce qui reste dans un second temps (ou plus).

Autre avantage, si on veut lancer un nouveau job sur des données déjà shuffled, Spark ne va pas reexécuter toutes étapes précédent le shuffle (skip) ce qui fait gagner du temps. Imaginons qu'on exécute un job impliquant un ou des shuffle. A l'issu de ce jobs, les données sont partitionnées d'une certaine façon sur le disque. Imaginons qu'on veuille lancer un 2e job qu'on a pensé en tenant compte de cette nouvelle distribution, à son lancement Spark ne va pas réexécuter le 1er job.
 
Pour une meilleure performance, on peut réaliser son propre caching (mise en cache) avec la méthode .cache des RDD / Datasets. A comprendre. Quel est le lien ? .cache lance-t-elle un job pour effectivement mettre en mémoire le produit de ce job ? Quel est l'objet mis en mémoire pour une suite de transformations se finissant par .cache ?

## Chapitre 16 : Developing Spark Applications
Chapitre à reprendre plus tard, donne des conseils pour structurer une application, paramétrer des outils de build (sbt, Apache Maven) et réaliser des tests unitaires. 

Ecrire une application Spark
Cette section s'intéresse à la configuration d'un build pour une application Scala. L'outil choisit est sbt mais cela fonctionnerait de manière similaire pour Maven. L'idée est notamment d'écrire un built file (ici un .sbt) dont le but est de rassembler les métadonnées du projet, où résoudre les dépendances et les différentes dépendances demandées par le projet. 

Remarque : pour chaque type de projets, il existe une structure standard pour organiser les différents fichiers du projet (cf. p.265), ex : src/main/ressources, etc.

Une fois le projet en place et le code rangé correctement dans la structure. On peut générer le build : sbt va nous générer un JAR (pouvant inclure toutes les dépendances) qu'on pourra ensuite passer directement à spark-submit. 

Remarque : Il n'y a pas de grandes différences pour les applications Java si ce n'est apparemment la spécification des dépendances. 

En Python pas de JAR, on a juste des scripts Python. Le script passé à spark-submit est celui instanciant la SparkSession. Il est cepandant fréquent de packager de multiples scripts dans un fichier .zip ou .egg. Ces fichers sont joints au script .py principal donné à spark-submit via l'option --py-files (ces fichiers sont alors placés sur le PYTHONPATH. 
Remarque : il est une bonne pratique de n'instancier la SparkSession qu'une fois et de ne pas le refaire dans chaque classe Python, la variable contenant la session leur sera passée à l'exécution. 

 Tester des applications Spark
 Les principaux éléments qu'on cherchera à tester (à l'aide de unit testing frameworks comme JUnit, Scala Test, etc.) pour des applications Spark peuvent être : 

- Résilience aux changements dans les données d'entrées : un pipeline Spark doit y être résilient jusqu'à un certain point ou traiter élégamment les erreurs. 
- S'assurer qu'on déduit bien des données ce qu'on veut en déduire 
- S'assurer que notre output a bien la structure attendue vu que l'output d'un pipeline est souvent l'input d'un autre. 

C'es là que le choix des API utilisées peut se reposer : est-ce que l'équipe de développement préfère les moins strictes SQL et DataFrame, privilégiant la vitesse de développement ou les type-safe RDD ou Dataset. Les type-safe APIs permettent notamment de faciliter la construction d'autres applications sur la notre. Elles sont également recommandées pour la création de larges applications. Python et R présentent d'autres avantages comme notamment l'utilisation de librairies qui leur sont propres.  
 
 Remarque : spark-shell (ou spark-sql ou pyspark ou sparkR) : mode interactif pour le développement vs spark-submit pour le déploiement sur le cluster d'applications production-ready.

Remarque : client mode vs cluster mode : en mode cluster on a plus de chances de réduire la latence entre le driver et les exécuteurs.

Configuration
La configuration d'une application Spark (et du cluster) peut reposer sur : 

- Les propriétés Spark qui sont définies à l'aide de l'objet SparkConf
- Les propriétés système de Java
- Des fichiers de configuration hard-codés, des templates sont disponibles dans le répertoire /conf situé au niveau du root directory (SPARKHOME) de Spark. 

Cf. page 275 pour d'autres réglages un peu plus fins notamment à l'aide de spark-env.sh (script contribuant suivant le mode, à fixer certains paramètres comme les variables type HOME) et de log4j.properties (pour le logging). 

Parmi tous les domaines susceptibles de se livrer à des ajustements de configuration, citons:
 
- Les propriétés de l'application : nom (affiché dans la Spark UI), master, mémoire et CPU allouées au driver et aux exécuteurs. 
- L'environnement d'exécution : classpaths supplémentaires, etc.
- Les propriétés liés à l'exécution : nombre de coeurs par exécuteurs, taille maximale des partitions, etc. 
- Shuffle behavior
- Spark UI
- Compression, serialisation
- Gestion de la mémoire
- Networking
- Scheduling
- Allocation dynamique (des ressources du cluster)
- Sécurité
- SparkR, Spark Streaming, SparkSQL
- etc.

Sur le job scheduling 
On se place dans le cadre d'une seule application Spark. Un job désigne alors l'ensemble des tâches concurrent à l'évaluation d'une action. Il est possible que plusieurs jobs s'exécutent en parallèle s'ils ont été lancés par des threads séparés (peut poser problème dans le cas où plusieurs clients utilisent l'application). Il est précisé que le scheduler Spark est thread-safe (ça veut dire qu'il tient compte de cela ?). 
Par défaut le scheduler Spark est FIFO mais si le job de tête n'accapare pas l'ensemble des ressources, les jobs suivants peuvent être lancés sans attendre. En revanche, si le job de tête est important, le jobs suivants peuvent être significativement retardés.
Il est possible de mettre le scheduler en mode fair (Spark fair scheduler, fortement inspiré du Hadoop Fair Scheduler) où les jobs se voient assigner des ressources à tour de rôle, un "petit" job peut ainsi se voir allouer des ressources même quand un "gros" job s'exécute. 
Autre possibilité laissée par le scheduler : on peut regrouper les jobs par pools. Cela peut permettre d'assigner des options de scheduling différentes pour chaque pool comme une priorité par exemple. On peut aussi ainsi regrouper tous les jobs d'un utilisateur dans un même pool (il est facile d'assigner tous les jobs soumis par un même thread à un même pool) et ainsi donner à chaque utilisateur une part des ressources peut importe le nombre de jobs soumis (plutôt que de donner les ressources par job faisant que ceux qui soumettent moins de jobs on toujours moins de ressources que ceux qui en soumettent plus). 

## Chapitre 17 : Deploying Spark 
 Spark supporte trois cluster managers : 

- Standalone mode (le cluster manager intégré de Spark)
- Apache Mesos
- Hadoop YARN
- Et depuis Spark 2.3 : Kubernetes

Deux types de clusters pour le déploiement : on-premises cluster (cluster sur site) vs cloud

On-premises cluster : C'est le cas d'organisation manageant leurs propres datacenters. Comme pour tous les arbitrages, un équilibre, un compromis est à trouver. Pour un cluster on-premises, on a un contrôle total du hardware, corolaire :  notre cluster est de taille fixe (par opposition à élastique) et ne peut pas s'adapter à la charge à la hausse comme à la baisse. Soit cela peut poser problème pour un besoin ponctuel de grosses capacités (very large analytics query, entrainement d'un nouvel algorithme de ML), soit on peut avoir plus ou moins de capacités non utilisées. Si on opère son propre cluster, on doit aussi gérer son propre système de stockage comme HDFS ou un key-value store scalable (comme Apache Cassandra). Celà induit en particulier de mettre en place une géoréplication ainsi que des mesures de disaster recovery. 

Par opposition au cloud où il est facile de donner à chaque application un cluster de la bonne taille pour d'exécuter, sur un cluster on-premises, la taille fixe des ressources impose l'utilisation d'un cluster manager pouvant exécuter plusieurs applications (Spark ou non-Spark) simultanément et au mieux réallouer dynamiquement ces ressources entre elles. Le cluster permet donc au cluster on-premises d'optimiser l'utilisation de ses ressources. 

Cloud : le principal avantage du public cloud  est son élasticité : on peut mobiliser les ressources dont on a besoin uniquement quand on en a besoin. On ne paye que pour les machines qu'on utilise.
Tous les principaux providers de cloud (AWS, Microsoft Azure, Google Cloud Platform, IBM Bluemix) proposent des clusters Hadoop avec HDFS et Spark à leur clients. Cependant on ne profite pas de l'élasticité car cela revient à utiliser un cluster de taille fixe lié à un système de stockage. Il est préférable d'utiliser un  système de stockage découplé d'un cluster spécifique (Amazon S3, Azure Blob Storage, Google Cloud Storage, etc.) et de ne démarrer les machine que dynamiquement, en fonction de la workload Spark. Ce découplage du stockage permet de ne mobiliser les ressources de calcul qu'au besoin, de les scaler dynamiquement et de mélanger les types de hardware (si par exemple on veut de la GPU). Attention : faire ses calculs dans un cloud ne signifie pas ou n'est pas équivalent à migrer une installation on-premises sur des machines virtuelles (à comprendre).
Plusieurs entreprises de services cloud fournissent des services Spark could-native pouvant évidemment se connecter à un cloud storage. Cela permet notamment de lancer simplement des workload Spark en s'économisant la lourdeur d'une installation Hadoop. S'intéresser aux cluster managers peut alors paraître superflu puisqu'on crée pour chaque job un cluster ad-hoc pour lequel le standalone cluster manager peut suffire.

Standalone cluster manager 
Ce cluster manager est une plateforme légère conçue pour les workloads Spark. Elle ne supporte pas d'autres applications que Spark. Il peut être la façon la plus rapide de lancer des applications Spark sur un cluster si on ne possède pas encore l'expérience sur YARN ou Mesos.

On doit d'abord fournir les machines : les démarrer, s'assurer qu'elles communiquent à travers le réseau et leur fournir la version de Spark à utiliser. On peut ensuite démarrer le cluster (le cluster manager), manuellement ou à l'aide de built-in launch scripts.

Manuellement celà se fait en deux étapes : 

- On démarre le master process du cluster manager sur le noeud dont on souhaite qu'il héberge le service (master node) à l'aide de $SPARK_HOME/sbin/start-master.sh. Le master retourne alors une URI (Uniform Ressource Identifier) destiné à être comuniquée aux worker nodes. C'est sur cette machine qu'est également hébergée la Spark UI.
- On se log ensuite sur chaque worker node pour y lancer le script $SPARK_HOME/sbin/start-slave.sh <master-spark-uri\>. Le master node doit être accessible du réseau qu'utilisent les worker nodes. 

A l'aide de cluster launch scripts 
On doit simplement créer un fichier conf/slaves dans le Spark directory qui va contenir les hostnames de toutes les machines qui feront office de workers. Au démarrage du cluster, la master machine va accéder à chaque worker via SSH pour les démarrer (ce qui demande une configuration de SSH au préalable). On peut ensuite utiliser les deploy scripts disponible dans $SPARK_HOME/sbin : start-master.sh, start-slaves.sh, start-all.sh, stop-master.sh, etc.

Il est évidemment possible d'ajuster la configuration du cluster manager : ressource des workers (CPU, mémoire), que faire des fichiers hérités de l'exécution à la terminaison d'une application, etc. Cela se manage via des variables d'environnement ou les propriétés de l'application.

On peut finalement lancer une application depuis n'importe quel noeud via spark-submit.

Spark sous YARN
 "Hadoop YARN is a framework for job scheduling and cluster ressource management". Remarque : Spark ne fait pas strictement partie de l'écosystème Hadoop : Spark supporte certes nativement YARN mais ne requiert rien de plus de Hadoop.

Lancer une application sur un cluster managé par YARN demande simplement de passer la valeur yarn à l'argument --master de spark-submit. Spark ira ensuite automatiquement récupérer les fichiers de configuration de YARN (sous le chemin donné par la variable d'environnement HADOOP_CONF_DIR ou YARN_CONF_DIR). spark-submit permet cependant de choisir certains de ces paramètres (cf. chapitre 16).

Remarque : en cluster mode, le driver Spark est géré par YARN et le client peut sortir après avoir lancé l'application. Spark ne s'exécutant pas forcément sur la machine qui a lancé l'application, il est nécessaire de distribuer les libraires et les JAR externes sur le cluster (passés via l'argument --jars). En client mode, le driver Spark est exécuté sur la machine cliente (dans le process client pour être plus général), YARN n'est alors chargé que de l'allocation de ressources aux worker nodes.

Pour plus de détail sur la configuration de YARN et notamment des aspects pouvant influencer la façon dont une application Spark va s'exécuter, cf. le site de Databricks.

YARN n'est pas conçu pour fonctionner sur le cloud, s'attendant notamment à ce que les données soient disponibles sur HDFS. Etant lié à Hadoop où capacités de calcul et de stockage sont liées, le scaling du cluster implique de scaler stockage et capacité de traitement ensemble. 

Spark sous Mesos :
Mesos semble plus général là où YARN est forcément lié à Hadoop (et très bien pour gérer des applications basées sur HDFS). 
"Apache Mesos abstracts CPU, memory, storage and other compute ressources away from machines (physical or virtual), enabling fault-tolerant and elastic distributed systems to be easily built and run effectively."
Mesos est une grosse infrastructure pensée pour être un datacenter scale-cluster manager. Il est recommandé de soumettre ses applications en cluster mode, le client mode demandant par ailleurs plus de configuration (le driver a besoin de plus d'informations pour travailler avec Mesos).

Remarque : globalement si le cluster n'est destiné qu'à exécuter des applications Spark, le plus simple reste de s'en tenir au standalone cluster manager. Cependant et contrairement à Mesos ou YARN, le standalone manager ne propose pas de solution simple out of the box pour le logging  (utile au débuggage) par exemple.

Networking configuration
Peut être une source de gain étant donné l'importance des shuffles. 

Application scheduling 
Le cluster manager propose des solutions pour faire du scheduling entre applications Spark. A l'intérieur d'une même application, différents jobs peuvent s'exécuter en même temps s'ils ont été soumis par des threads différents (c'est par exemple le cas si notre applications répond à des requêtes qui lui sont passées via le réseau). Spark dispose d'un fair scheduler pour allouer les ressources au sein d'une même application.

Comment allouer les ressources entre différentes applications : 

- Static ressources partitioning : on alloue à chaque application le maximum des ressources qu'on a prévu de lui donner et elle les garde pendant toute la durée de son exécution. 
- Dynamic ressources allocation : on laisse la possibilité à l'application de scale up et de scale down dynamiquement en fonction de la charge, i.e. du nombre de tasks qu'elles ont à exécuter. L'application peut ainsi rendre ponctuellement des ressources au cluster pour les récupérer plus tard. Cette feature est désactivée par défaut (propriété spark.dynamicAllocation.enabled) et disponible sur le standalone manager, YARN et Mesos en coarse-grain mode. Pour l'activer, on doit : 
	
	- Passer spark.dynamicAllocation.enabled à true
	- Mettre en place un service de shuffling externe sur chaque worker node et passer spark.shuffle.service.enabled à true. Le but de ce service est de permettre de supprimer des exécuteurs sans effacer leurs shuffle files. Ce set up se fait de façon différente suivant le cluster manager : cf la documentation Dynamic Allocation Configurations.        

Metastore
On peut avoir besoin de maintenir les métadonnées de nos datasets pour par exemple permettre un cross-referencing efficace de datasets entre applications. Hive fait typiquement l'affaire.

## Chapitre 18 : Monitoring and debugging
Que peut-on contrôler : 

 - Les applications Spark / Spark jobs : c'est la première chose qu'on veut suivre pour mieux débugger et/ou comprendre comment une applications ou un simple job s'exécute sur le cluster. Cela se fait principalement avec des outils comme les Spark logs et la Spark UI. Spark s'appuie sur un système de métriques configurables basé sur la Dropwizard Metric Library. Les métriques sont paramétrées à l'aide d'un fichier de configuration et peuvent être versées vers une variété de sinks et notamment des cluster-level monitoring solutions comme Ganglia. La Spark UI permet également d'avoir accès aux détails d'exécution d'une application à différentes échelles : querie, job, stage et task. 
 - Les JVM : driver comme les exécuteurs s'exécutent sur des JVM dont l'étude peut fournir des détails sur la façon dont notre code s'exécute. Ce sont des éléments d'assez bas niveau demandant d'être familier des internes des JVM. De telles études sont permises par des outils tels que jstack, jmap, jstat, etc. Certaines métriques utiles relatives aux JVM sont disponibles dans la Spark UI. 
 - Les OS/machines : il est important de s'assurer que les machines exécutant le code sont saines (on suit des éléments comme les CPU, le réseau, l'I/O. Cela peut se faire à l'échelle du cluster avec des outils dédiés au cluster monitoring comme Ganglia ou Prometheus. 

Solutions proposées nativement par Spark pour le monitoring / debugging : 

- Spark logs : Spark permetque les logs de notre applications (définis par le programmeur) apparaissent avec les logs Spark permettant un rapprochement aisé des deux. Suivant les contextes (modes d'exécutions ?) on peut  les imprimer dans la console et/ou (?) les faire écrire dans un fichier par le cluster manager. Il peut aussi être utile de collecter les logs périodiquement, ne serait-ce que pour éviter des les perdre si la machine qui les produit crashait (auquel cas il serait utile d'avoir les logs pour essayer de comprendre pourquoi).
- Spark UI : il en est lancé une par chaque Spark Context sur le port 4040 (par défaut) de la machine du driver (attention, elle n'est normalement accessible tant que le Spark Context s'exécute). Elle consiste en plusieurs onglets: 
	
	- Jobs : donne des informations sur l'exécution de chaque job lancé par l'application avec un détail par stage. 
	- Stages : permet d'avoir pour une stage donnée le détail par task ainsi que des statistiques descriptives sur les temps d'exécution, les quantités de données traitées, etc. Cette vue peut par exemple permettre de détecter des distributions déséquilibrées de donnés.
	- Storage : donnes des informations sur les données actuellement mises en cache sur le cluster. Peut permettre d'identifier des données vidées du cache à certain moments.
	- Environment : permet de consulter les informations de configuration en vigueur pour l'application.
	- Executors : permet d'obtenir des détails sur les exécuteurs utilisés par l'application.
	- SQL : permet de visualiser les requêtes (queries) passées via la Structured API. On y trouve une représentation graphique du DAG (et de ce qu'on pourrait obtenir avec .explain) de chaque requête où les tasks sont visuellement regroupées par stages séparées par les opérations de shuffle.
- Spark REST API : en plus de la Spark UI, Spark permet d'accéder au statut des applications et à leurs métriques via une API REST. L'information disponible via cette API est la même que celle accessible via la Spark UI moins les infos de l'onglet SQL. Cela permet à l'utilisateur de construire ses propres solutions de reporting et de visualisation basées sur les données disponibles dans la Spark UI. 
- Spark UI History Server : La Spark UI n'est accessible que lorqu'un Spark Context est en cours d'exécution. Comment y avoir accès dans le cas où l'application crash ou se termine ? Le Spark UI History Server permet de reconstruire la Spark UI (et son API REST) pourvu que l'application ait été configurée pour sauvegarder un event log. On peut alors lancer l'history server comme une application standalone qui va reconstruire la web UI à partir de ces logs. Certains cluster managers / cloud services configurent automatiquement un tel logging lancent un history server dans leur comportement par défaut.

Exemples d'erreurs et de causes possibles : 

- Les jobs ne démarrent pas : Il est possible que le driver ne puisse communiquer avec les exécuteurs : cela peut être un problème de configuration, on a oublié/fait une erreur dans les IP/port à ouvrir/écouter. In est aussi possible qu'on demande au cluster manager plus de ressources qu'il est capable d'en donner à ce moment là, le driver attendant son tour.
- Un code qui marchait ne marche plus : Au delà d'une typo ou d'un nom de colonne, de fichier ou de chemin incorrect, s'assurer que la connectivité entre driver, exécuteurs et système de stockage fonctionne. Il peut aussi s'agir d'un problème de classpath qui charge la mauvaise version d'une libraire (pour accéder au système de stockage par exemple).
- Un job qui fonctionnait hier ne fonctionne plus, dans une requête (query) à plusieurs jobs, un job fonctionne mais pas le suivant : s'assurer que les données attendues sont bien de la bonne forme, que le schéma est adapté (si on attend un champ qui ne s'annule jamais mais qui en vient à présenter des valeurs manquantes).
- Certaines tasks mettent beaucoup plus de temps à s'exécuter que d'autres même en augmentant le nombre de machines, certains exécuteurs lisent/écrivent beaucoup plus que les autres : Il est vraisemblable que le jeu de donnés soit distribué de façon déséquilibrées (ex : on a partitionné suivant une colonne avec beaucoup de null). On peut alors repartitionner avec une autre colonne, augmenter la mémoire allouée aux exécuteurs (ils vont alors spill to disk moins souvent et potentiellement finir plus vite), voir si la lenteur est liée à une machine en particulier (unhealthy machine dont le disque serait presque plein). Si on utilise des UDF, voir si elle sont inefficaces dans leur object allocation (l'utilisation d'UDF imposant l'instanciation de nombreux objets afin de convertir les enregistrements en objets Java, la garbage collection peut être particulièrement couteuse : vérifier avant que les métriques de la GC sont cohérentes avec l'utilisation de l'UDF dans la task lente). On peut aussi activer une option appelée "speculation" où Spark va automatiquement lancer une copie des tasks lentes sur d'autres machines. Cela a un coût en terme de performances et peut poser des problèmes avec certains systèmes de stockages (output dupliqué) si les opérations d'écriture ne sont pas idempotentes (consistent file system).
- Agrégations lentes (diagnostic renforcé si les tasks après l'exécution sont aussi lentes) : une partie des pistes présentées ci-dessus s'appliquent encore : repartitionner, augmenter la mémoire allouée aux exécuteurs. S'assurer que tous les filter ou select statements qui peuvent être mis avant l'opération d'agrégation le sont bien (fait automatiquement avec l'API Dataset). Certaines opérations d'agrégation comme collect_list ou collect_set sont lentes par construction car elle doivent retourner les objets correspondant au driver. 
- Jointures lentes (diagnostic renforcé si les tasks après la jointure sont plus rapides) : jouer sur l'ordre des jointures (les jointures filtrantes d'abord), repartitionner si le coût en vaut le bénéfice, augmenter la taille des exécuteurs, s'assurer que les filtres et select pouvant être déplacés avant les jointures le sont bien, broadcast (explicitement) la ou les tables à joindre si elles ne sont pas trop grosses.
- Lectures/écritures lentes sur le système de fichiers distribué / stockage extérieur : Peut être difficile à diagnostiquer. Vérifier que le cluster Spark a assez de bande passante pour accéder au stockage. Si on travaille sur des systèmes distribués comme HDFS où Spark s'exécute sur les mêmes noeuds que le stockage, s'assurer les hostnames des noeuds vus par Spark soit le même que ceux de HDFS, cela lui permettra de faire du locality-aware scheduling (colonne "locality" dans la Spark UI). 
- Driver qui ne répond plus / DriverOutOfMemoryError : le plus classique peut être qu'on a essayé de collect un dataset trop volumineux sur le driver ou tenté une broadcast join avec une table trop lourde. Cela peut ussi être lié à une saturation de la mémoire de la JVM d'objets qui restent toujours accessibles, une analyse de la heap avec jmap peut être utile, voir aussi si cela n'est pas lié à l'utilisation d'un language annexe comme Python pour lequel la conversion des données peut requérir beaucoup de mémoire. Une augmentation de la mémoire allouée au driver peut être une première solution facile à implémenter.
- Exécuteur qui ne répond plus / ExecutorOutOfMemoryError : comme pour le driver on peut commencer par essayer si possible d'augmenter la mémoire allouée aux exécuteurs et/ou de repartitionner les données de façon à augmenter le parallélisme. L'utilisation d'UDF peut impliquer une importante création d'objets mettant le garbage collector sous pression, essayer d'en limiter l'usage quand celui des fonctions Spark n'est vraiment plus possible. A noter que Spark peut récupérer automatiquement de ce problème. 

## Chapitre 19 : Performance Tuning
Le chapitre distingue deux types d'amélioration de performance : direct et indirect. Le type indirect s'applique à l'ensemble des jobs d'une application via des ajustements de configuration ou de l'environnement d'exécution. Le type direct vise à améliorer la performance de jobs voire de stages particuliers à l'intérieur de l'application.

Améliorations indirectes (indirect performance enhancements) : 

Choix dans le design de l'application : 

- Quel language ? Scala, Python, R ? Dans le cadre de la Structured API, les différents languages sont équivalents en terme de stabilité et de performance. R et Python peuvent cependant souffrir de moindre performance lors de l'utilisation d'UDF dans la Structures API (garantir les types dans le passage d'un language à un autre a un coût) et des RDD. Celà provient de la façon dont des opérations particulières sont exécutées.
- Quelles APIs ? DataFrame, Dataset, SQL, RDD ? Les API DataFrame, Dataset et SQL sont équivalentes en termes de performance (petit écart pour Dataset ?) et de stabilité puisqu'elles aboutissent toutes au même code RDD. L'utilisation d'UDF va diminuer la performance mais cette baisse sera moindre pour Java/Scala que pour R/Python. Le recours aux RDD doit être limité et on doit essayer de recourir le plus possible aux Structured APIs. Pour l'utilisation de RDD, il est recommandé de recourir à Scala/Java, R et Python impliquant comme pour les UDF une SerDe pour l'échange avec le R/Python process. 

Choix de la sérialisation :

Si on ne peut pas utiliser le format interne Spark (la p. 317 parle de cette situation pour les transformations des RDD - dans l'utilisation des Structured API, le format interne doit être présent par défaut => l'utilisation directe de l'API RDD implique-t-elle que la sérialisation est Java/Kryo, le format interne Spark - Tungsten - n'étant utilisé que dans le cadre précis de l'optimisation des performances de la Structured API), on peut préférer utiliser la sérialisation Kryo qui est bien plus performante que la sérialisation Java. Cela implique lors de l'utilisation de types personnalisés d'enregistrer (register) les classes concernées.

Choix des configurations du cluster 

- Paramétrisation du partage des ressources et de l'ordonnancement (scheduling) pour les cluster exécutant de multiples applications (Spark ou non). On rappelle que Spark possède un FAIR scheduler. 
- Allocation dynamique des ressources : désactivée par défaut, elle est supportée par les différentes cluster managers.
- On peut aussi jouer sur l'allocation des ressources à l'aide de paramètres de configuration comme max-executor-cores qui va par exemple permettre de limiter que l'application ne s'accapare la totalité des ressources du cluster. 

Arrangement des données (data at rest - à opposer à data in flight)

L'idée consiste à arranger le stockage permanent de ses données de façon à assurer l'efficacité des (nombreuses) futures lectures de ces données. Il s'agit d'exploiter les avantages du système de fichiers choisi, du format des données et des possibilités de partitionnement laissée par certains d'entre eux. 

- Format des données : privilégier Parquet à CSV par exemple. 
- S'assurer que le format fichier lui permet d'être "splittable" c'est à dire que différentes tasks peuvent venir lire le fichier en parallèle (ce qui permet entre autres que la lecture d'un même fichier peut être parallélisée sur plusieurs coeurs rendant un scan d'autant plus rapide). Certains formats ne le sont pas ce qui impose que la lecture soit assurée par une seule task/coeur réduisant d'autant le parallélisme et créant probablement un bottleneck dans l'application. Par exemple les formats compressés .zip ou .tar ne sont pas splitables contrairement aux .gzip, .bzip2 ou .lz4. 
- On conseille de faire des fichiers de l'ordres que quelques dizaines de Mb minimum. Un nombre important de petits fichiers va demander un cout important pour ce qui est de les lister (listing) et de les récupérer à travers le système de fichier (fetching), le sheduler va aussi avoir plus de travail pour localiser les données et lancer les tasks de lecture. Plus on fragmente nos fichiers, plus on augmente le network et scheduling overhead (de même, de trop nombreuses partitions qui sont associées à de très nombreuses tasks viennent augmenter l'overhead associé au démarrage de chacune d'entre elles). Les overhead sont des coûts fixes qu'on répartit sur des quantités de plus en plus faibles à mesure qu'on diminue la quantité traitée à chaque fois. Quelques gros fichiers permettent d'éviter ces écueils mais les tasks de lecture seront beaucoup plus longues (ce que le parallélisme vient atténuer si le format est splittable). 
- Partitionnement : cela consiste à stocker des fichiers dans différents répertoires séparés déterminés par les valeurs d'une clé. Ce concept est supporté par de nombreux storage managers comme Apache Hive et de nombreuses sources de Spark. Un tel stockage logique permet à Spark de sauter (skip) de nombreux fichiers au chargement des données. 
- Bucketing : Le contenu de chaque fichier étant placé dans au moins une partition, on peut contrôler le contenu de des partitions issues de la lecture (de façon à optimiser les agrégations/jointures à suivre) en contrôlant en amont le contenu des fichiers stockés de façon permanente dans le système de fichiers.  
- Data locality : Si Spark détecte que le système de fichier propose cette option, il va l'utiliser. Cela va permettre au scheduler de planifier les tasks au plus près physiquement des données dans la mesure du possible. 
- Collecter des statistiques sur les données : le cost-based optimizer des Structures APIs utilise entre autres des statistiques sur les données d'entrée (qui permettent par exemple de décider automatiquement de faire une broadcast join). Ces statistiques sont de deux types, par ordre de coût croissant : table-based et column based. Cette feature est en développement actif (SPARK-16026).

Configuration des shuffles 
L'external shuffle service de Spark peut permettre d'améliorer les performance par le fait qu'il permet de lire des données sur des machines distantes même lorsque les exécuteurs de ces machines sont occupés (par de la GC par exemple).
Les paramètres du shuffle "normal" peuvent aussi être optimisées. On le rappelle ici, le choix de la sérialisation a un impact important sur la performance du shuffle.  

Memory pressure et garbage-collection

La memory pressure apparaît quand une application a du mal à terminer ses tasks car elle consomme trop de mémoire / manque trop de mémoire et/ou quand la GC se déclenche trop souvent et/ou qu'elle est lente à s'exécuter dû à l'abondance d'objets. Une stratégie est de s'en tenir le plus possible aux Structured APIs. 

On peut aller beaucoup plus loin après étude fine de la GC (en la rendant plus verbeuse, en récoltant des statistiques sur le nombre de déclenchements de minor/major GC, et sur leur durées) en ajustant l'allocation de ressources faite aux différentes zones mémoire de la JVM (la heap est divisées en Young et Old (generations), la première se subdivisant encore en Eden, Survivor1 et Survivor2).
Le but de l'affinage de la GC dans Spark est de faire en sorte que les long-cached datasets sont stockés dans la Old generation et que la Young generation est suffisamment importante pour stocker tous les objets à faible durée de vie (ce qui évite de faire des full/major GC pour juste collecter les objets temporaires produits par l'exécution).

Si par exemple la full GC est appelée plusieurs fois avant la fin d'une task, c'est qu'il n'y a pas assez de mémoire disponible pour la Young generation, on peut alors ajuster la répartition entre Young et Old (spark.memory.fraction). 

Si autre exemple, on remarque qu'on a de nombreuses minor GC mais pas ou peu de major GC, allouer plus de mémoire à l'Eden pourrait aider.

On peut aussi essayer d'autres GC comme le G1. Il y a plein de choses à essayer mais à la grosse maille, réduire la fréquence des full GC est une des premières contribution à la réduction des GC overhead. 

Améliorations directes (direct performance enhancements)
On s'intéresse ici à l'amélioration de la performance d'une stage ou d'un job particulier. 

- Parallélisme : Essayer d'en tirer le maximum. Le livre recommande de l'ordre de 2-3 tasks par coeur. Les paramètres pouvant permettre de s'y ajuster sont spark.default.parallelism ou spark.sql.shuffle.partitions.
- Filtrer le plus possible le plus tôt possible.
- Repartition/coalesce : bien que repartition puisse avoir un coût plus élevé que coalesce, les gains peuvent valoir ces coûts. Un repartition peut être particulièrement utile avant une jointure ou un cache afin de reéquilibrer la répartition des données. 
- Minimiser l'emploi d'UDF / maximiser l'utilisation des fonctions mises à disposition dans la Structured API. Le coût d'une UDF provient de la contrainte de se représenter les données comme des objets dans la JVM afin de procéder au calcul. Se renseigner sur le projet des Vectorized UDF.
- Jointures : certaines ont des propriétés filtrantes (inner join, etc.), changer l'ordre des jointures peut donc être particulièrement utile. On peut aussi aider Spark avec des broadcast joins, en collectant des statistiques sur les données pour qu'il choisisse la meilleure stratégie de jointure ou en ayant bucketé convenablement ses données pour minimiser le shuffle. 
- Aggrégations : beaucoup de techniques peuvent être employées pour les optimiser, penser à placer le plus possible de filtres avant et si on utilise des RDD, comparer reduceByKey à groupByKey. 
- Broadcast variables : Si une quantité importantes de données va être utilisée dans de multiples appels d'UDF, on peut broadcaster ces données de façon à placer sur chaque noeud une copie read-only des données à utiliser (LU table, un modèle de ML, etc.) afin d'éviter de les renvoyer à chaque fois. 
- Stockage temporaire (mise en cache) : Si des mêmes données sont réutilisées de très nombreuses fois (ML, interactive data science, etc.), un gain évident est de les mettre en cache. Le caching consiste à placer dans le stockage temporaire (mémoire ou disque) de chaque exécuteur un DataFrame, RDD ou table afin de rendre leurs lectures ultérieures plus rapide. Ce n'est pas une panacée : la mise en cache (et la lecture du cache) implique des coûts des SerDe et de stockage. Attention, l'opération cache est lazy : elle n'est réellement effectuée que lors de la première action (on peut forcer la mise en cache par un simple df.count() immédiatement après df.cache()). Attention également, les objets mis en cache ne sont pas les mêmes pour les API RDD et Structured (à comprendre). Les principaux modes de stockage disponibles pour la mise en cache sont mémoire uniquement (RDD stockés désérialisés dans la mémoire de la JVM, si le RDD ne rentre pas en mémoire, les parties non stockées seront recalculées à la volée au besoin), mémoire et disque (idem que précédemment sauf que ce qui ne tient pas en mémoire est stocké sur disque et lu quand besoin), disque uniquement et mémoire ou mémoire/disque avec RDD sérialisé (prend moins de place mais la lecture est plus CPU intensive, s'assurer d'utiliser un fast serializer). Pour contrôler les niveaux de stockage, utiliser .persist (.cache étant un alias pour .persist("MEMORY_ONLY")).

De manière générale :

- Ne lire que le strict minimum de données : utiliser des formats où on peut faire du filter push-down, partitionner les données.
- S'assurer qu'on bénéficie d'un bon niveau de parallélisme et que les données sont réparties de façon équilibrées (repartition, bucketing).
- Utiliser au maximum les API de haut-niveau (et fortement optimisées : Tungsten + Catalyst) comme la Structured API.