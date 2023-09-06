@echo off

rem Liste des services
set services=client posts comments event-bus moderation query
set userdockerhub=drbwap

rem Parcours de la liste des services et construction de chaque image Docker
for %%s in (%services%) do (
    docker build -t %%s .\%%s
    docker tag %%s %userdockerhub%/%%s:latest
    docker push %userdockerhub%/%%s:latest
)
