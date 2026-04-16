# Introduction

## Données

Le dataset est accessible avec ce lien : https://www.kaggle.com/datasets/harshvgh/olympics?select=athlete_events.csv 

Les données proviennent de la plateforme Kaggle, qui propose des jeux de données publics pour la data science. Elles sont issues de sources officielles liées au International Olympic Committee et ont été structurées pour faciliter leur analyse.

Nous avons choisi ce dataset à la fois pour son intérêt personnel, le sport étant un sujet qui nous intéresse toutes les quatre, et pour la quantité importante de données disponibles. Sa richesse (variables démographiques, physiques et sportives) et sa profondeur historique (depuis 1896) offrent un fort potentiel d’analyse.

Ce jeu de données s’inscrit dans un contexte d’analyse exploratoire de données appliquée au sport, et constitue un bon support pour manipuler des données réelles avec R.


Dans notre analyse de ce dataset, nous allons nous concentrer sur le document ***athletes_event.csv***, le document *noc_regions.csv* permettant uniquement de lier le NOC et la région, deux colonnes présentes également dans le document *athletes_event.csv*


Ce document contient des données concernant tous **les athlètes ayant participé aux Jeux Olympiques modernes**, depuis la première édition en 1896 à Athènes.

Il y a environ **136k observations**, et chaque observation correspond à la **participation d'un athlète à une épreuve**. 

Ce dataset est décrit par 15 variables : 
| **Variable** | **Description**                                       | **Type de valeur** | **Nature des données** | **Remarques**                                                                          |
| ------------ | ----------------------------------------------------- | ------------------ | ---------------------- | -------------------------------------------------------------------------------------- |
| **ID**       | Identifiant du participant                            | Numérique          | Discrète               | Unique par participant, mais peut apparaître plusieurs fois (plusieurs participations) |
| **Name**     | Nom et prénom du participant                          | Texte              | Nominale               |                                                                                        |
| **Gender**   | Genre du participant                                  | Texte              | Nominale               | "F" (femme) ou "M" (homme)                                                             |
| **Age**      | Âge du participant                                    | Numérique          | Continue, ordinale     |                                                                                        |
| **Height**   | Taille du participant                                 | Numérique          | Discrète, ordinale     | Peut être "NA" (Not Available)                                                         |
| **Weight**   | Poids du participant                                  | Numérique          | Discrète, ordinale     | Peut être "NA"                                                                         |
| **Team**     | Équipe représentée (souvent son pays)                 | Texte              | Nominale               |                                                                                        |
| **NOC**      | Code du comité national olympique (3 lettres)         | Texte              | Nominale               |                                                                                        |
| **Games**    | Édition des JO (année + saison)                       | Texte              | Nominale               | Exemple : "1912 Summer"                                                                |
| **Year**     | Année de participation                                | Numérique          | Continue, ordinale     |                                                                                        |
| **Season**   | Saison de JO                                          | Texte              | Nominale               | "Summer" ou "Winter"                                                                   |
| **City**     | Ville hôte des JO                                     | Texte              | Nominale               |                                                                                        |
| **Sport**    | Discipline sportive correspondante à la participation | Texte              | Nominale               |                                                                                        |
| **Event**    | Épreuve correspondante à la participation             | Texte              | Nominale               |                                                                                        |
| **Medal**    | Médaille obtenue lors de l'épreuve                    | Texte              | Nominale, ordinale     | "Gold", "Silver", "Bronze" ou "NA"                                                     |

## Plan d’analyses

**1. Évolution historique et participation**
- **Croissance globale :** Quelle est l'évolution du nombre d'athlètes et de nations (NOC) de 1896 à nos jours ?
- **Impact des saisons :** Comment la participation aux JO d'hiver se compare-t-elle à celle des JO d'été en termes de volume ? regarder si des nations sont plus présentes en hiver ou en été ?
- **Analyse du genre :** Quelle est la proportion d'hommes et de femmes au fil du temps ? Observe-t-on des sports qui ont atteint la parité plus rapidement que d'autres ?
- **Stabilité des délégations :** Certaines nations envoient-elles des délégations de taille constante ou observe-t-on des tailles anormales liées au contexte historique ?

**2. Morphologie et caractéristiques physiques des athlètes**
- **Profils types par sport :** Existe-t-il une distribution spécifique de la taille et du poids pour chaque discipline (ex: comparaison entre le Basket-ball et la Gymnastique) ?
- **Évolution corporelle :** La taille ou le poids moyen des médaillés a-t-il changé en un siècle pour un même sport ?
- **Âge de la performance :** Quel est l'âge moyen des médailles par sport ? Existe-t-il des disciplines de précocité versus des disciplines de maturité ?
- **Indice de Masse Corporelle (IMC) :** Peut-on comparer l'IMC des athlètes pour identifier des clusters de performance ?

**3. Analyse de la performance et des médailles**
- **Domination par nation :** Quels pays (NOC) possèdent le plus grand nombre de médailles cumulées ? Evolution des médaille pour les grosse d'élégations. 
- **Efficacité des délégations :** Quel est le ratio “Médailles obtenues / Nombre d'athlètes envoyés“ par pays ? Une petite délégation peut-elle être plus efficace qu'une grande ?
- **Spécialisation sportive :** Certaines nations sont-elles ultra-spécialisées dans un sport précis (en nombre de participants ou en médailles obtenues) ?
- **Avantage du terrain :** Les pays hôtes (variable City) obtiennent-ils systématiquement plus de médailles l'année où ils reçoivent les Jeux ? Impact sur les prochains jeux ?

**4. Analyse des disciplines et des épreuves**
- **Diversité des sports :** Comment le nombre de disciplines (Sport) et d'épreuves (Event) a-t-il évolué ?
- **Popularité et pérennité :** Quels sont les sports historiques présents depuis 1896 et quels sont les sports éphémères qui ont disparu du programme olympique ?
- **Athlètes multi disciplines :** Existe-t-il des athlètes qui participent à plusieurs types d'épreuves (meme style de sport ou different type de sport) ?


**Limitations et défis**
- **Biais historique :** Pour les données anciennes, on a moins de données sur la morphologie (taille, poids) avant la seconde guerre mondiale. 
- **Changements géopolitiques :** Le dataset prend en compte une grande période, alors vient la question des changement de nom pour les pays (on considère L’URSS comme la Russie ou comme un autre pays, …).
- **Surreprésentation des sports collectifs :** Dans le fichier, une médaille d'or en Football compte pour 11 à 20 lignes (une par joueur), tandis qu'une médaille en 100m compte pour une seule ligne. Il faudra décider si l'on compte les médailles par athlète ou les médailles par épreuve.
