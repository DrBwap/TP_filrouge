# Projet fil rouge

## Introduction

Ce projet est une application microservices construite avec Node.js et React. Il est conçu pour être déployé sur Kubernetes.

## Table des matières

- [Introduction](#introduction)
- [Table des matières](#table-des-matières)
- [Architecture](#architecture)
- [Chemins d'Ingress](#chemins-dingress)
- [Noms de Services Kubernetes](#noms-de-services-kubernetes)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Déploiement](#déploiement)









## Architecture

L'application est composée des services suivants :

- **Client** : Interface utilisateur construite avec React.
- **Posts** : Service pour la gestion des posts.
- **Comments** : Service pour la gestion des commentaires.
- **Query** : Service pour la gestion des requêtes.
- **Moderation** : Service pour la modération des commentaires.
- **Event Bus** : Service pour la gestion des événements entre les services.

### Chemins d'Ingress

- `/posts/create` : Dirigé vers le service `posts-clusterip-srv` sur le port 4000.
  - Utilisé pour créer de nouveaux posts.
  
- `/posts` : Dirigé vers le service `query-srv` sur le port 4002.
  - Utilisé pour récupérer la liste des posts existants.
  
- `/posts/?(.*)/comments` : Dirigé vers le service `comments-srv` sur le port 4001.
  - Utilisé pour créer ou récupérer les commentaires associés à un post spécifique.
  
- `/?(.*)` : Dirigé vers le service `client-srv` sur le port 3000.
  - Utilisé pour accéder à l'interface utilisateur.
 


### Noms de Services Kubernetes

Assurez-vous que les noms de services dans vos fichiers de déploiement Kubernetes correspondent aux noms de services utilisés dans le code de l'application. Voici les noms de services attendus :

- **client-srv**: Service pour l'interface utilisateur.
- **posts-clusterip-srv**: Service pour la gestion des posts.
- **query-srv**: Service pour la gestion des requêtes.
- **comments-srv**: Service pour la gestion des commentaires.
- **moderation-srv**: Service pour la modération des commentaires.
- **event-bus-srv**: Service pour la gestion des événements entre les services.

Si vous modifiez ces noms, assurez-vous également de mettre à jour les références correspondantes dans le code de l'application.


## Prérequis

- Node.js
- Docker
- Kubernetes

## Installation

1. Clonez ce dépôt :
    ```bash
    git clone https://github.com/Mossbaddi/Pojet_fil_rouge.git
    ```

2. Installez les dépendances pour chaque service :
    ```bash
    cd client && npm install
    cd ../posts && npm install
    # Répétez pour tous les services
    ```
  Note: on peut ajouter "RUN npm install" dans les images Docker pour installer les dépendances au moment de la création de l'image

## Déploiement

1. Construisez les images Docker pour chaque service :

  Concernant la construction des images Docker, ce sont les mêmes pour chaque service, excepté pour l'image du client qui a en plus la commande "Run npm run build", qui sert a monter le site internet.
  Il faut donc créer un dockerfile dans chaque fichier (client, posts, comments...), et y mettre les lignes suivantes:


        FROM node:alpine

        COPY . .

        RUN npm install   #optionnel si vous avez entrer les commandes cd client && npm install pour chaque fichier

        RUN npm run build   #uniquement pour l'image client, l'enlever sinon

        CMD ["npm", "start"]  #lancement de l'image


    ```bash
    docker build -t client ./client
    docker build -t posts ./posts
    # Répétez pour tous les services
    ```

2. Création des déploiements des pods

    On se place dans le dossier k8s.
    Pour chaque service il va falloir déployer des pods.
    On va créer des fichier .yml, respectivement client-dplt.yml, posts.yml ...
    Les fichiers vont être similaire: seul le mot clé lié au nom (client, posts,...) et le numéro du containerPort vont varier.

      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: myapp   #lui donner un nom, client-dplt
      spec:
        replicas: 3  #permet de lancer plusieurs instance dans le cas où l'une a des problèmes, l'autre prend le relais
        selector:
          matchLabels:
            app: myapp  #remplacer app dans myapp par le mot clé: myclient 
        template:
          metadata:
            labels:
              app: myapp  #doit avoir le même nom que le matchLabels, ici myclient
          spec:
            containers:
            - name: myapp #on peut le nommer comme on souhaite, client-container par exemple
              image: <Image>  #le nom de l'image associé, créée à l'étape précédente, ici client
              resources:
                limits:
                  memory: "128Mi" #à augmenter ou diminuer selon les besoins
                  cpu: "500m"
              ports:
              - containerPort: <Port> #Plus haut on a la mention du port où le service écoute l'information. Pour client c'est 3000
              imagePullPolicy: IfNotPresent #A ajouter, pour éviter les boucles infinies

          
3. Création des services:

    On va créer les différents services client-srv.yml, ...
    Les noms, ports vont changer selon les services:






4. Déployez les services sur Kubernetes :
    ```bash
    kubectl apply -f k8s/
    ```
