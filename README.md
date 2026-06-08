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
    - **Variables :** Year, ID (en comptant les valeurs uniques : n_distinct(ID)), NOC (n_distinct(NOC)).
    - **Graphique :** Line chart avec une courbe pour les athlètes et une pour les nations.
    - Remarque : Ajoute des geom_vline pour marquer les événements historiques majeurs
- **Impact des saisons :** Comment la participation aux JO d'hiver se compare-t-elle à celle des JO d'été en termes de volume ? regarder si des nations sont plus présentes en hiver ou en été ?
    - **Variables :** Year, Season, ID (unique).
    - **Graphique :** Stacked area chart
    - Remarque : JO Hiver et ete avaient lieux la même année jusqu'en 92
- **Analyse du genre :** Quelle est la proportion d'hommes et de femmes au fil du temps ? Observe-t-on des sports qui ont atteint la parité plus rapidement que d'autres ?
    - **Variables :** Year, Gender, ID (unique).
    - **Graphique :** 100% Stacked bar chart
    - Remarque : marqueur de l'année d'atteinte de la parité pour chaque sport ? 
- **Stabilité des délégations :** Certaines nations envoient-elles des délégations de taille constante ou observe-t-on des tailles anormales liées au contexte historique ?
    - **Variables :** Year, NOC, ID (unique).
    - **Graphique :** Boxplots par décennie, pour voir la dispersion de la taille des délégations.

**2. Morphologie et caractéristiques physiques des athlètes**
- **Profils types par sport :** Existe-t-il une distribution spécifique de la taille et du poids pour chaque discipline (ex: comparaison entre le Basket-ball et la Gymnastique) ?
    - **Variables :** Height, Weight, Sport, Gender
    - **Graphique :** Scatter plot avec le poids en X et la taille en Y
    - Remarque : utilsation du 2D Density plot (courbes de niveau) pour éviter le chevauchement (overplotting) des points, utiliser des sports aux antipods pour rendre le graph lisible.
- **Évolution corporelle :** La taille ou le poids moyen des médaillés a-t-il changé en un siècle pour un même sport ?
    - **Variables :** Year, Height (moyenne), Weight (moyenne), Sport.
    - **Graphique :** Line chart, lissé (avec geom_smooth()) incluant l'intervalle de confiance.
    - Remarque : Filtrer uniquement les médaillés ?
- **Âge de la performance :** Quel est l'âge moyen des médailles par sport ? Existe-t-il des disciplines de précocité versus des disciplines de maturité ?
    - **Variables :** Age, Sport, Medal.
    - **Graphique :** Violin plot ou Boxplot, classé par l'âge médian du sport le plus jeune au plus vieux.
- **Indice de Masse Corporelle (IMC) :** Peut-on comparer l'IMC des athlètes pour identifier des clusters de performance ?
    - **Variables :** Création d'une variable BMI = Weight / (Height/100)^2.
    - **Graphique :** Ridgeline plot, via le package ggridges

**3. Analyse de la performance et des médailles**
- **Domination par nation :** Quels pays (NOC) possèdent le plus grand nombre de médailles cumulées ? Evolution des médaille pour les grosse d'élégations.
    - **Variables :** NOC, Medal (filtré sans NA), Event, Year.
    - **Graphique :** Carte colorée selon volume de médailles ou Horizontal bar chart
- **Efficacité des délégations :** Quel est le ratio “Médailles obtenues / Nombre d'athlètes envoyés“ par pays ? Une petite délégation peut-elle être plus efficace qu'une grande ?
    - **Variables :** NOC, ID (unique), Medal (unique par épreuve).
    - **Graphique :** Scatter plot, Axe X = Taille de la délégation, Axe Y = Nombre de médailles + ligne de régression "moyenne"
    - Remarque : Créer un indicateur (Nombre d'épreuves avec médaille / Nombre d'épreuves participées).
- **Spécialisation sportive :** Certaines nations sont-elles ultra-spécialisées dans un sport précis (en nombre de participants ou en médailles obtenues) ?
    - **Variables :** NOC (filtré sur le top 20 nations), Sport, Medal.
    - **Graphique :** Heatmap, Nations en Y, Sports en X, intensité de la couleur = pourcentage de médailles du pays venant de ce sport.
- **Avantage du terrain :** Les pays hôtes (variable City) obtiennent-ils systématiquement plus de médailles l'année où ils reçoivent les Jeux ? Impact sur les prochains jeux ?
    - **Variables :** NOC, Year, City, Medal. (Il faut un référentiel externe ou croiser City avec la nationalité de la ville).
    - **Graphique :** Un Slope chart, pour comparer le nombre de médailles d'un pays à l'édition T-1 (avant d'accueillir), à l'édition T (pays hôte), et T+1 (après).

**4. Analyse des disciplines et des épreuves : Audit du Programme Olympique**
*Pour cette dernière partie, nous adopterons la posture stratégique d'un auditeur du Comité International Olympique (CIO). L'objectif est d'analyser la santé, l'attractivité et le coût logistique des différents sports afin de justifier leur maintien, leur suppression ou leur évolution.*
- **L'Universalité des disciplines (Compétitivité mondiale vs Monopoles) :** Quels sports sont véritablement mondiaux (médailles réparties sur un grand nombre de pays) et lesquels sont des niches dominées par une poignée de nations ?
    - **Variables :** `Sport`, `NOC` (unique parmi les médaillés), `Year` (filtré sur l'ère moderne).
    - **Graphique :** Lollipop chart ou Bar chart horizontal.
- **L'empreinte logistique (Le "coût" en athlètes) :** Quels sont les sports les plus "gourmands" en quotas d'athlètes par rapport au nombre de médailles qu'ils distribuent (ex : comparaison entre les sports collectifs et la natation) ?
    - **Variables :** `Sport`, `ID` (unique par sport et par édition), `Event` (unique par sport).
    - **Graphique :** Scatter plot (Axe X = Nombre d'athlètes moyen par édition, Axe Y = Nombre d'épreuves ou médailles distribuées).
    - **Remarque :** Mettre en évidence la pression logistique des sports sur le village olympique.
- **La modernisation du programme (Vers la parité des épreuves) :** Comment l'offre sportive du CIO s'est-elle adaptée pour atteindre la parité ? Comment ont évolué les épreuves masculines, féminines et mixtes ?
    - **Variables :** `Year`, `Event` (pour extraire le type d'épreuve), `Gender`.
    - **Graphique :** Diverging bar chart (pyramide inversée) : par année, barres à gauche pour les épreuves "Men's", à droite pour "Women's", et au centre pour les épreuves "Mixed".
- **Pérennité et "Cimetière olympique" (L'instabilité du programme) :** Quels sont les sports "piliers" historiques présents sans interruption, et quels sont les sports éphémères ou de démonstration qui ont disparu du programme ?
    - **Variables :** `Sport`, `Year` (min, max et comptage des apparitions).
    - **Graphique :** Timeline plot (diagramme de Gantt) ou Waterfall chart illustrant les entrées et sorties des sports au fil des décennies.

**Limitations et défis**
- **Biais historique :** Pour les données anciennes, on a moins de données sur la morphologie (taille, poids) avant la seconde guerre mondiale. 
- **Changements géopolitiques :** Le dataset prend en compte une grande période, alors vient la question des changement de nom pour les pays (on considère L’URSS comme la Russie ou comme un autre pays, …).
- **Surreprésentation des sports collectifs :** Dans le fichier, une médaille d'or en Football compte pour 11 à 20 lignes (une par joueur), tandis qu'une médaille en 100m compte pour une seule ligne. Il faudra décider si l'on compte les médailles par athlète ou les médailles par épreuve.
