#!/bin/bash
# Script de déploiement et d'initialisation d'un cluster local
# Usage: ./deploy-cluster.sh <cluster_name> <node_count> <environment>

CLUSTER_NAME=$1
NODE_COUNT=$2
ENV=$3
BASE_CLUSTER_DIR=/tmp/clusters

echo "Démarrage du déploiement du cluster $CLUSTER_NAME..."

# Vérification des arguments
if [ -z $CLUSTER_NAME ] || [ -z $NODE_COUNT ]
then
    echo "Erreur : Paramètres manquants."
    exit
fi

# Création du répertoire de travail temporaire
WORK_DIR=/tmp/deploy/$ENV
mkdir -p $WORK_DIR
cd $WORK_DIR

# Nettoyage des anciens fichiers temporaires
rm -rf $WORK_DIR/*

# Génération et déploiement local des configurations pour  chaque nœud
i=1
while [ $i -le $NODE_COUNT ]
do
    NODE_NAME="$CLUSTER_NAME-node-$i"
    NODE_TARGET="$BASE_CLUSTER_DIR/$ENV/$NODE_NAME"

    echo "Initialisation locale de $NODE_NAME..."
    mkdir -p $NODE_TARGET

    echo "node_id=$i" > $WORK_DIR/$NODE_NAME.conf
    echo "env=$ENV" >> $WORK_DIR/$NODE_NAME.conf

    # Déploiement local et gestion des droits
    cp $WORK_DIR/$NODE_NAME.conf $NODE_TARGET/config.conf
    chmod -R 777 $NODE_TARGET

    i=$(expr $i + 1)
done

# Archivage des configurations générées
tar -cf /tmp/backup_$CLUSTER_NAME.tar $WORK_DIR/*

echo "Déploiement local du cluster $CLUSTER_NAME terminé !"