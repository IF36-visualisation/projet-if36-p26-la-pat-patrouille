# Introduction

## Données

Le dataset est accessible avec ce lien : https://www.kaggle.com/datasets/harshvgh/olympics?select=athlete_events.csv 

Dans notre analyse de ce dataset, nous allons nous concentrer sur le document ***athletes_event.csv***, le document *noc_regions.csv* permettant uniquement de lier le NOC et la région, deux colonnes présentes également dans le document *athletes_event.csv*


Ce document contient des données concernant tous **les athlètes ayant participé aux Jeux Olympiques modernes**, depuis la première édition en 1896 à Athènes.

Il y a environ **136k observations**, et chaque observation correspond à la **participation d'un athlète à une épreuve**. 

Ce dataset est décrit par 15 variables : 
- **ID : l'identifiant du participant.** Cette valeur est numérique, discrète et unique pour chaque participant. Etant donné que chaque ligne représente une participation, cette valeur n'est pas forcément unique dans le tableau.
- **Name : le nom (et prénom) du participant.** Cette valeur est nominale.
- **Gender : le genre du participant.** Ne contient que des valeurs nominales : soit "F" pour les femmes, soit "M" pour les hommes.
- **Age : l'âge du participant.** Cette valeur est numérique, continue et ordinale.
- **Height : la taille du participant.** Cette valeur est numérique, discrète et ordinale. *Cette valeur peut ne pas être définie ("NA").*
- **Weight : le poids du participant.** Cette valeur est numérique, discrète et ordinale. *Cette valeur peut ne pas être définie ("NA").*
- **Team : l'équipe représentée par le participant.** Cette valeur est nominale. Elle représente généralement le pays de l'athlète.
- **NOC : le code de 3 lettres désignant le comité national olympique lié au participant.** Cette valeur est nominale.
- **Games : les JO pendant lesquels la participation a eu lieu.** Cette valeur est nominale et concatène généralement l'année et la saison (ex : "1912 Summer").
- **Year : l'année de la participation.** Cette valeur est numérique, continue et ordinale.
- **Season : la saison de JO de la participation.** Cette valeur est nominale et contient soit la valeur "Summer" pour les JO d'été, soit la valeur "Winter" pour les JO d'hiver.
- **City : la ville hôte des JO.** Cette valeur est nominale.
- **Sport : la discipline correspondante à la participation.** Cette valeur est nominale.
- **Event : l'épreuve correspondante à la participation.** Cette valeur est nominale.
- **Medal : la médaille obtenue lors de l'épreuve.** Cette valeur est nominale et ordinale et peut contenir quatre valeurs : "Gold", "Silver", "Bronze" et "NA".




## Brouillon

https://www.kaggle.com/datasets/sajkazmi/paris-olympics-2024-games-dataset-updated-daily

https://www.kaggle.com/datasets/harshvgh/olympics?select=athlete_events.csv   (stat joueur, event 1996 2016)

Idées d'analyse : 

Sports qui apparaissent et disparaissent ? 
Apparition des femmes dans le sport au fil du temps
Trouver des marqueurs temporels en rapport avec l'actualité (ex: Nouvelles disciplines qui ont été créées par les nazis, scandales de dopage, ...)
Est ce que le nombre de pratiquants par pays a un rapport avec ses résultats? 
