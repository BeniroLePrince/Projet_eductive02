# Projet_eductive02

Deployer une infrastructure sur OVH avec terraform, ansible et docker.
Le terraform lance 3 intances à GRAV en master et SBG en backup une BDD mysql.
Un front qui redirige vers les backends par rapport au port qu'on rentre dans le l'url.

## Installation

Il faut installer terraform et ansible et sourcer votre credentials
```
apt-get install terraform
apt-get install ansible
source openrsc
```
### Lancer les instance et BDD. 

Ce placer dans le dossier terraform. 
Puis lancer c'est commande
```
Terraform init
terraform apply --auto-approve

```
C'est deux commande va initier le OpenStack et lancer les instances et BDD
Verifier avec un ``` terraform show ````

### Provisioner les intances via ansible 

Aller dans le dossier ansible puis taper la commande
```
ansible-playbook deploy-infra.yml -i inventory.yml --ssh-common-args='-o StrictHostKeyChecking=no

```
Cette commande va provisioner les instances via le deploy-infra.yml et le paramétre ``` --ssh ``` va automatique autoriser authenticity checking


### tester les backend depuis le front

Recuperer l'ip publique du front via le ficher inventory.yml ou ``` terraform show ```

Sur les backends 1 qui seront sur le port 80 Cette page internet affichera une image de chat qui change lorsque vous rechargez la page puis une phrase avec le meilleur utilisateur

    vous pouvez y accéder grâce à l'ip du front suivi de :80.

Sur les backends 2 qui seront sur le port 81 Cette page internet affichera un tableau aves des informations sur nos ip. 

    vous pouvez y accéder grâce à l'ip du front sur le port :81

sue les backends 3 qui seront sur le port 82 Cette page internet affichera un wordpress.

    vous pouvez y accéder grâce à l'ip du front sur le port :82

### Change la configuration

J'ai crée plusieur playbook dans le dossier ansible pour les different services par rapport au backend. 
Le final s'appelle deploy-infra.yml qui permet de deployer tout les services. 



