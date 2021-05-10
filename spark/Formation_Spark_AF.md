Optimiser s'entend aussi comme la capacité à bien dimensionner les ressources demandées (CPU, RAM) pour son application.

Hadoop
Application node / edge node / client node
Nomenclature AF : TN (name node) NO (data node) AN (application node)

Hive stagne. Pour du transactionnel ça va (OLTP), mais pas pour de l'analytique (OLAP). Il semble que ce n'est plus porté que par Hortonworks mais ce n'est pas leur vitrine.

Conteneur YARN : avantage est que l'exécuteur peut être relancé (retry de 3 par défaut). Si ça continue de ne pas marcher. YARN va relancer l'exécuteur sur un autre noeud.

Mode client à éviter par rapport au mode cluster. => Mode cluster le driver est dans un conteneur YARN : s'il plante il peut être relancé. En mode client le driver est sur l'application node qui est beaucoup moins costaud que les data nodes. On peut détruire l'application node sur un collect trop ambitieux par exemple. Problème : on est pas le seul à utiliser l'application node. Si jamais on fait la même chose en cluster mode, on fait juste crasher le contenaur YARN (même pas le data node).

Mode cluster avec code mixte PySpark / Scikit : où s'exécute le code scikit ? S'exécute sur un data node ? Quand Spark démarre un process Python (ex : UDF), il le sort d'où ? Quel environnement d'exécution ? Quelles dépendances, ils les sort d'où ? C'est possible d'embarquer ça ? Dans le pex ? Attente de Spark conteneurisé (Kubernetes) : on a plus à reposer sur un cluster manager (mort future des clusters YARN / Mesos ?) pour l'exécution du job. On garde l'avantage du conteneur (on ne gêne pas ce qu'il y a ). Avec un conteneur une application ne peut pas dépasser les limites qu'on lui donne avec le conteneur et aller jusqu'à s'accaparer toutes les ressources physique de la machine sur laquelle elle s'exécute.

Pour les fichiers suffisement gros, on a une partitiion par bloc HDFS (ou nombre de "region server" si on utilise HBase) par défaut (au départ, après il existe des transformations qui peuvent modifier le partitionnement : si shuffle impliqué : groupBy, join, distinct, orderBy).

Remaque : la réunion de df préserve le partionnement ?

Remarque : groupBy => nombre de partitions à l'issu du groupement égal au nombre de clés ? => peut sous/sur-paralléliser ? Sous-paralléliser = data skew, il faut repartionner.

Comment voir le skew : on va voir les stats descriptives sur l'exécution des tasks dans la web UI. Si par exemple la distribution de la durée d'exécution des tasks est très skewed, on a un data skewed. Ca fait partie du boulot de s'assurer dans le code que ça ne va pas skewed, de contrôler le partionnement des données le long du pipe. Repartition : on repartitionne suivant un champs dont on sait que les valeurs, dont les clés sont réparties de façon plus homogènes sur les données. Si on a pas, il faut créer une fonction qui va créer ces clés (homogènes) de repartitionnement (peut aussi passer par la création d'un nouveau champ qui y juste dédié au repartitionnement).

RAPPEL : UN REPARTIONNEMENT CA COUTE.

Shuffle :
Tri des données par les exécuteurs et éventuellement regroupement sur un même datanode si celui-ci héberge plusieurs exécuteurs.
Ecriture sur disque sur le datanode des exécuteurs
Echanges réseau pilotés par le serveur
Tri des données sur les exécuteurs destinataires : On récupère des données de différents noeuds qu'il faut réallouer entre les exécuteurs du noeud destinataire.
Opération sur les données

Spark Web UI : métriques shuffle read/shuffle write.

Task : c'est la chaîne de transformations d'une stage appliquée sur une partition des données.

Intercaler des count() dans le code : permet de ne pas avoir qu'un seul plan Catalyst mais n+1 plans quand on place n count. Ca permet d'éviter si des bouts sont opaques à Catalyst qu'il se contraignent avec le bout opaque. Mais employé sans .cache() ou .persist() il se passe quoi ? Les données sont mises en mémoire quand meme ???

Executor = JVM ; Core = Thread de la JVM ; Executor memory = Taille du heap. ATTENTION : la mémoire est partagée par les cores. Si 16 cores mais 12 Gb par executor => la mémoire moyenne par thread est en fait pas énorme. Attention aux nombres de cores qu'on demande par rapport à la mémoire demandée. 60% de la mémoire demandée comme spark memory (spark.memory.fraction) celle ci se répartissant globalememnt à 50%/50% entre execution memory (utilisée pour le fonctionnement => résultats temporaires de shuffle) et storage memory (où on peut mettre des données en cache) => seule ~30% de ce qui est demandé peut être utilisé pour la mise en cache.

Que se passe-t-il quand on sature la mémoire. Globalement la partie éjectée de la mémoire (Least Recent Use) est sérialisé sur disque sauf pour la storage memory où ça dépend de l'option choisie.

Garbage collection : peut prendre pas mal de CPU pour s'exécuter (genre 30%).

spark.yarn.memoryOverhead : paramètre qui est une marge par rapport à la memory overhead. On attend pas d'avoir saturé la mémoire : sinon Exception et le programme se termine. YARN surveille et déclenche le spill quand on dépasse la marge. Ex : si on demande 10Gb et que le paramètre est à 2Gb, dès qu'on arrive à 8Gb YARN réagit. Par défaut la marge est max(10% de ce qu'on a demandé, 384Mb).

Mode de persistence par défaut : MEMORY_ONLY : problème si des données se font éjecter : pas de spill sur disque, les données sont perdues et devront être recalculées si on en a besoin plus tard => utiliser MEMORY_AND_DISK qui implique un spill sur disque.

On met quoi en méméoire : ce qui coûte très cher à calculer et/ou données qu'on utilise très souvent. Si c'est trop volumineux : le résultat interméidaire est caché en DISK_ONLY.

De combien on a besoin en mémoire : faire le test. Dur de savoir quelle taille fera le dataset à stocker (ex : s'il est chargé à partir de fichiers parquet).

Tungsten = la SerDe de Hive

Gain à la compaction (au delà du fait que Tungsten est beaucoup plus rapide en encodage/décodage) : sur les mêmes données, un RDD va prendre 150Mb, un DataFrame bénéficiant de la SerDe ne va prendre que 15Mb. Remarque : Kryo a adapté sa sérialisation pour faire comme la SerDe Hive (Kryo Unsage) disponible depuis Spark 2.1 mais buggé.

Dataset n'a pas de sens en Python right ? On a pas à se préoccuper des Encoders ??

Broadcast : ne pas oublier de libérer la mémoire : bcDf.unpersist() pour supprimer le DataFrame de la mémoire des exécuteurs seulement ou bcDf.destroy() pour le supprimer de la mémoire des exécuteurs et du driver. Par défaut sur une jointure, si la plus petite des deux tables fait moins de 10Mb, Catalyst va automatiquement broadcaster la table => on économise un shuffle ET conserve le partitionnement. Pour les tailles intermédiaires, entre broadcaster la table et faire un shuffle, ça peut être kiffkiff.

Quand on lit du disque, avoir l'ahabitude de faire suivre d'une .repartition().

Remarque : Avro est en déclin. Surtout utile pour les appli codées en Java/C++. Parquet est mieux.

Remarque : de l'importance d'avoir un schéma fournit avec ses données : l'occupation mémoire. Ex : on importe un csv sans schéma ni inférence de schéma => tout est chargé en String et globalement des String ça occupe beaucoup de mémoire (10x plus que du numérique par exemple). Fournir le schéma permet aussi un chargement beaucoup plus rapide. Pas forcément un enjeu en batch mais utile en streaming où on doit charger plein de petits fichiers. En plus si celui des données change : si on fournit un schéma ça va planter et pas retourner des résultats bizarres qu'on ne va pas voir tout de suite (idem, l'inférence de ce point de vue c'est pas la fiabilité max).

Web UI => s'accède via ambari. Cliquer sur "Spark" correspond au Spark History Server. Si on veut voir ce qui se passe en live, il faut cliquer sur "YARN" (pour avoir le temps d'aller voir, insérer des pauses dans l'exécution du script).

La page "Event timeline" peut permettre de voir des skew.

DAG montré dans la web UI = physical plan de Catalyst ?? Plan d'un job => onglet SQL, le DAG est plus général (?) et concerne tout le déroulé de l'appli (?).

PAr définiton : nombre de tasks d'une stage = nombre de partitions.

Onglet Storage : vide si l'application ne tourne plus (history server)

Case rouge dans dans onglet exécuteur = temps GC > 10% temps CPU (veut dire qu'on a pas assez de mémoire). Quand on lit 1.6min (29s) veut dire que l'exécuteur s'est exécuté 1.6min (temps CPU) dont 29s de temps de GC. Onglet Executor => pour vérifier la parallélisation. Onglet Stage => Vérifier s'il y a des skew ou pas.

Onglet SQL va donner par exemple les temps d'exécution de chaque étape.

Logs Spark : peut être très verbeux, tellement que ça peut en devenir inexploitable et prendre une place folle sur le disque.

Partitions
128Mo idéal (50-200Mo ok) => efficacité ~gaussienne de la taille de la partition centrée sur 128Mo. Si trop petit : on a beaucoup d'overhead. Si trop gros : on parallélise mal.
On chosit le nombre en regardant la taille de nos données (on s'aide de la webUI / de la mise en cache).
Attention : quand on repartitionne, les partitions ne vont pas forcément être allouées de façon homogènes aux exécuteurs. Ex : si on fait un repartition(12) et qu'on a 6 exécuteurs, c'est pas garanti qu'on ait 2 partitions par exécuteurs.
Remarque : Spark ne gère pas les partitions pareil qu'on en ait plus ou moins de 2000.

Si on décide de repartitionner (en cas de skew ou d'écart à l'optimum de parallélisme), évaluer les gains.

Globalement : quand on repartitionne on a pas la main sur la taille des partitions (d'autant que la taille peut évoluer au fil des transformations. Ex : après un filtre on peut se retrouver avec un skew, des partitions vides etc.) et leur allocation entre les exécuteurs. Ca sera globalement équilibré mais c'est pas 100% garanti. Autre ex : df.sample(false, 0.01) => risque de quasi vider des partitions. On va donc ajouter une réduction du nombre de partitions.

Pourquoi 200 partitions après un shuffle quel que soit le nombre de partitions initial ? Il y a une taille max (2Gb) pour les shuffle blocks. Pour éviter d'avoir des blocs trop gros, on partitionne plus finement par précaution. On peut aussi changer le paramètre spark.sql.shuffle.partitions dynamiquement, entre deux actions.
Ex : spark.sqlContext().sql("SET spark.sql.shuffle.partitions=10")
On modifie ce paramètre sur les petits datasets (< 10Gb), plus de 200 cores (sinon on a moins de 1 partition par core), gros datasets (> 40 Gb), si on fait du Structured Straming.

Nombre de partitions recommandées = 1 à 3x le nombre de core si les partitions sont de taille raisonnable.

Attention : coalesce(1) pas une bonne pratique, préférer hdfs dfs -getmerge

Sur les UDF : ne pas les utiliser si possible, elles ne sauront pas travailler directement sur les données sérialisées en mémoire. Sinon il faut déserialiser voire pire, en plus démarer un process Python. Les lambdas c'est pareil, c'est comme une UDF en fait, c'est opaque à Catalyst.

Ressources
Combiens d'exécuteurs, de cores, de mémoire ?
Remarque : trop de cores par executor : ça va bouchonner dans l'accès à HDFS. On peut avoir max 5 cores qui peuvent accéder en même temps à HDFS => 5 cores max par executor.
1 core par executor : on ne profite pas de la mutualisation de la mémoire entre cores.
Remarque : ne pas oublier que le driver va prendre un conteneur.
Ne pas oublier les ressources du driver. Ne pas hésiter à lui en donner, il peut devenir un goulot d'étranglement. 
