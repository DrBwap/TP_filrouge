# Projet fil rouge

Note: les changements apportés au README originel sont à partir de la partie Installation.

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
 
### Ports des Services

Chaque service écoute sur un port spécifique. Assurez-vous que ces ports sont correctement configurés dans vos fichiers de déploiement Kubernetes et dans tout autre outil de gestion des conteneurs que vous pourriez utiliser. Voici les ports attendus pour chaque service :

  client-srv: Écoute sur le port 3000.
  posts-clusterip-srv: Écoute sur le port 4000.
  query-srv: Écoute sur le port 4002.
  comments-srv: Écoute sur le port 4001.
  moderation-srv: Écoute sur le port 4003.
  event-bus-srv: Écoute sur le port 4005.

Si vous modifiez ces ports, assurez-vous également de mettre à jour les références correspondantes dans le code de l'application et les fichiers de configuration Kubernetes.

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
  Puis on se place dans le dossier exporté:
  ```bash
  cd Projet_fil_rouge
  ```

2. On construit les images Docker pour chaque service:

    ```bash
    docker build -t client ./client
    docker build -t comments ./comments
    docker build -t event-bus ./event-bus
    docker build -t moderation ./moderation
    docker build -t posts ./posts
    docker build -t query ./query
    ```

  #Note: ce point devient facultatif en utilisant directement les images stockées sur mon dockerhub (les appels sont en commentaires dans les fichiers xxx-dplt.yml)

## Déploiement

1. On instancie l'Ingress:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
    ```

2. On déploye les services sur Kubernete:
    ```bash
    kubectl apply -f ./k8s
    ```

3. On a plus qu'à aller sur le site, sur:

    http://localhost/




# Création du projet (sur une base extraite depuis github)

## Installation

1. Clonez ce dépôt :
    ```bash
    git clone https://github.com/Mossbaddi/Pojet_fil_rouge.git
    ```
  Puis on se place dans le dossier exporté:
  ```bash
  cd Pojet_fil_rouge
  ```
2. Installez les dépendances pour chaque service : (facultatif si instauré dans le dockerfile)
    ```bash
    cd client && npm install
    cd ../posts && npm install
    # Répétez pour tous les services
    ```
  Note: on peut ajouter "RUN npm install" dans les images Docker pour installer les dépendances au moment de la création de l'image

## Déploiement

1. Construisez les images Docker pour chaque service :

  On se place dans le dossier Pojet_fil_rouge.
  Concernant la construction des images Docker, ce sont les mêmes pour chaque service, excepté pour l'image du client qui a en plus la commande "Run npm run build", qui sert a monter le site internet.
  Il faut donc créer un dockerfile dans chaque fichier (client, posts, comments...), et y mettre les lignes suivantes:


        FROM node:alpine

        COPY . .

        RUN npm install   #facultatif si vous avez entrer les commandes cd client && npm install pour chaque fichier

        RUN npm run build   #uniquement pour l'image client, l'enlever sinon

        CMD ["npm", "start"]  #lancement de l'image


  Puis depuis le 
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
            app: myapp  #remplacer dans "myapp" par : myclient (et respectivement myposts, mycomments...)
        template:
          metadata:
            labels:
              app: myapp  #doit impérativement avoir le même nom que le matchLabels, ici myclient
          spec:
            containers:
            - name: myapp #on peut le nommer comme on souhaite, client-container par exemple
              image: <Image>  #on remplace <Image> par le nom de l'image associé, créée à l'étape précédente, ici client
              resources:
                limits:
                  memory: "128Mi" #à remplacer par 256Mi, plus si nécessaire
                  cpu: "500m"
              ports:
              - containerPort: <Port> #La partie "Port des services" mentionne les valeurs des ports des différents services (logique n'est-ce-pas?). Pour client c'est 3000, on remplace donc <Port> par 3000.
              imagePullPolicy: IfNotPresent #A ajouter

          
3. Création des services :

    On est toujours dans le dossier k8s.
    On va créer les différents services client-srv.yml, ...
    Les noms, ports vont changer selon les services:

      apiVersion: v1
      kind: Service
      metadata:
        name: myapp #remplacer par le nom du service, il sera réutilisé dans l'ingress (étape suivante). Ici on ajoute à "client" "-srv", donc client-srv. Ce sera la même chose pour les autres services, sauf posts qui devient posts-clusterip-srv.
      spec:
        selector:
          type: NodePort #on ajoute cette ligne pour client-srv.yml, pour les autres on remplace NodePort par ClusterIP
          app: myapp  #même nom que le label du .dplt correspondant. Pour client on a myclient.
        ports:
        - name: #nom du label, on pourrait donner un autre nom
          protocol: TCP
          port: <Port>  #On remplace <Port> par la valeur de la partie "Ports des services", ici 3000
          targetPort: <Target Port> #On remplace par la valeur de containerPort du deployment, ici 3000.


4. Création de l'Ingress :
    On est toujours dans le dossier k8s.



5. Déployez les services sur Kubernetes :
    ```bash
    kubectl apply -f k8s/
    ```
