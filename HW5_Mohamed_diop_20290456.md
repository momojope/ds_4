# HW5 Réponses courtes / HW5 Short Answers


**Name:** DIOP Mohamed

**Matricule \#:** 20290456

**Veuillez écrire vos réponses courtes ci-dessous et les inclure dans votre soumission de gradescope. / Please write your short answers below and include this as part of your gradescope submission.**

**Le titre du rapport doit être HW5_{Votre_Nom}\_{Matricule_\#} / The title of the report should be HW5_{Your_Name}\_{Matricule_\#}**


## Question 2

### Nombre d'images créées à chaque build
À chaque fois que je lance un build, deux images Docker sont construites
L'image de base, qui contient toutes les dépendances nécessaires (Python, Flask, Torch, etc.). C'est l'environnement de base dans lequel le code de mon application s'exécutera.
L'image cible, qui est construite à partir de cette image de base et contient le code spécifique du backend ou du frontend.

### Est-ce que je devrais toujours reconstruire ces deux images ?
Non, pas du tout. En fait, je n'ai pas besoin de reconstruire l'image de base à chaque fois. L'image de base ne change que si je modifie ses dépendances (comme ajouter une bibliothèque ou changer la version de Python). Donc, si cette image est déjà construite et stockée avec un tag latest, je peux la réutiliser. Cela me permet d'éviter un travail redondant et de gagner du temps.

### Comment je peux accélérer ce process ?
Pour éviter de perdre du temps, je pourrais utiliser un mécanisme de cache avec Docker. Concrètement, quand je lance un build, je peux dire à Docker de vérifier si une version déjà construite de mon image de base (taggée latest, par exemple) est disponible et l'utiliser au lieu de la reconstruire à partir de zéro. Je ferais ça en ajoutant l'option --cache-from dans mon fichier cloudbuild.yaml. Cela demande à Docker de regarder d'abord dans le cache pour voir s'il peut réutiliser une image existante.

## Question 4

Pour éviter que backend_v1 télécharge le modèle ResNet à chaque déploiement, on peut inclure le modèle directement dans l’image Docker lors de la phase de build en ajoutant une commande pour le télécharger et le préparer à l’avance. Par exemple, en ajoutant cette ligne dans le Dockerfile : RUN python -c "from torchvision.models import resnet152, ResNet152_Weights; resnet152(weights=ResNet152_Weights.DEFAULT)". Cela rallonge légèrement le temps de build initial, mais rend les démarrages de l’application plus rapides en évitant un téléchargement à chaque déploiement. Une autre alternative consiste à stocker le modèle dans un espace de stockage persistant, comme Google Cloud Storage (GCS), et le charger depuis GCS au démarrage de l’application.

## Question 5

Déployer les services backend et frontend séparément apporte plusieurs avantages. Cela permet d'actualiser chaque service indépendamment, facilitant la mise en place de nouvelles fonctionnalités ou de correctifs sans perturber l'autre service. Cette séparation améliore également la scalabilité, puisque le backend et le frontend peuvent être ajustés en fonction de leurs besoins spécifiques. Par exemple, le backend peut être mis à l’échelle en réponse à une augmentation des demandes de traitement, tandis que le frontend s'ajuste selon le volume des requêtes utilisateur. En outre, cela offre une flexibilité technologique, permettant d'optimiser chaque service avec les technologies qui conviennent le mieux à leurs tâches respectives.

Cependant, cette approche présente aussi des inconvénients. Gérer deux déploiements distincts ajoute une complexité opérationnelle, nécessitant une configuration et une surveillance approfondies pour garantir une communication fluide entre les services. La séparation peut également introduire une latence supplémentaire, surtout si le frontend et le backend sont hébergés dans des environnements ou des régions différentes. Enfin, il est crucial de bien gérer les versions pour assurer la compatibilité entre les deux services, car des incohérences pourraient nuire à l’intégration et causer des erreurs dans l’expérience utilisateur.

## Question 7

Pourquoi ce n'est pas un problème dans v1 ?
Dans backend_v1, un seul modèle (resnet152) est utilisé pour toutes les requêtes. Il est chargé une fois au démarrage de l'application et reste constant pendant toute la durée de vie du service. Même si plusieurs utilisateurs effectuent des requêtes simultanées, elles utiliseront toutes le même modèle global, ce qui garantit un comportement cohérent. Cela simplifie la gestion des ressources et réduit la complexité, car le service n'a pas besoin de recharger ou de modifier le modèle pour chaque requête.

Pourquoi est-ce un problème dans v2 ?
Dans backend_v2, l'utilisateur peut choisir parmi plusieurs modèles disponibles. Si deux utilisateurs effectuent des requêtes simultanées et choisissent des modèles différents, le modèle global (model) risque d'être modifié pendant l'exécution. Cela entraîne des conflits et des résultats imprévisibles, car le modèle utilisé pour une requête peut être remplacé avant qu'elle ne soit traitée. Ce comportement non déterministe est problématique pour un service concurrent.

Dans le frontend, il est essentiel d'implémenter des sessions pour gérer les préférences spécifiques de chaque utilisateur, comme le modèle sélectionné. Les sessions permettent de maintenir un état unique pour chaque utilisateur, ce qui garantit que leurs interactions avec le système sont indépendantes. Lorsqu'un utilisateur choisit un modèle, cette préférence peut être stockée dans une session et incluse dans les requêtes envoyées au backend. Cela nécessite l'ajout d'un identifiant unique par session dans chaque requête pour permettre au backend de récupérer le modèle correspondant sans ambiguïté.

Dans le backend, deux approches techniques peuvent être envisagées pour résoudre les conflits liés au modèle global. La première consiste à charger dynamiquement le modèle à chaque requête en fonction des données reçues, telles que l'identifiant de session ou le modèle spécifié. Cette méthode garantit que chaque requête est isolée et utilise le modèle correct. Cependant, elle peut entraîner une surcharge en termes de temps de traitement si les modèles doivent être rechargés fréquemment. La seconde approche consiste à précharger tous les modèles disponibles dans la mémoire lors du démarrage du service. Cela permet de réduire les délais d'exécution, car les modèles sont immédiatement accessibles. Bien que cette méthode soit plus rapide, elle nécessite une quantité importante de mémoire pour héberger plusieurs modèles simultanément, ce qui peut poser des contraintes sur les ressources du système.

## Question 8

La version 3 (v3) cherche à introduire un modèle plus flexible et évolutif pour la gestion des requêtes et des modèles. Contrairement aux versions précédentes, v3 utilise une passerelle API pour centraliser l'accès au backend. La passerelle API agit comme un point d'entrée unique pour toutes les requêtes, ce qui simplifie la gestion des modèles et facilite l'ajout de nouvelles fonctionnalités ou services sans avoir à modifier les composants existants. Cela permet également de déléguer certaines tâches, comme l'authentification, le routage ou le suivi des requêtes, à la passerelle, réduisant ainsi la charge sur les services backend.

Une autre différence majeure réside dans la gestion des modèles. Au lieu de changer globalement de modèle ou de recharger les modèles à chaque requête, v3 adopte une approche où chaque requête spécifie explicitement le modèle à utiliser via une URL structurée, comme /model/<id>/predict. Cela permet un meilleur contrôle et un comportement indépendant des utilisateurs, évitant les conflits liés à un état global. Cependant, une limitation du code actuel est l'absence d'une implémentation complète pour récupérer dynamiquement les modèles disponibles via une passerelle API.

## Question 9

La quantification est une technique utilisée en machine learning pour réduire la précision des poids et des activations des modèles, en convertissant souvent des valeurs en virgule flottante à 32 bits en des entiers à 8 bits ou moins. Cette méthode apporte plusieurs avantages pour l’inférence des modèles. En réduisant la taille des représentations, les modèles nécessitent moins de mémoire, ce qui les rend adaptés aux environnements à ressources limitées comme les appareils mobiles ou embarqués. De plus, les calculs sur des valeurs de moindre précision sont généralement plus rapides, ce qui améliore le temps d'inférence et rend cette approche idéale pour des applications en temps réel. L’efficacité énergétique est également accrue, car les opérations sur des entiers consomment moins d’énergie, un facteur critique pour les appareils fonctionnant sur batterie.

Cependant, la quantification a aussi des limites. La réduction de la précision peut entraîner une perte de performance du modèle, particulièrement pour des tâches où une grande précision est nécessaire. Certains modèles et ensembles de données sont plus sensibles à ces pertes, ce qui peut nécessiter des ajustements supplémentaires, comme le réentraînement du modèle pour compenser. La mise en œuvre de la quantification peut aussi augmenter la complexité du développement, car elle exige souvent des optimisations spécifiques. Enfin, tous les matériels ne prennent pas en charge les calculs quantifiés de manière optimale, ce qui peut limiter les bénéfices attendus en termes de performances ou nécessiter des investissements dans des matériels compatibles.

IBM - Quantization 
https://www.ibm.com/think/topics/quantization

TensorFlow Lite - Model Optimization
https://www.tensorflow.org/lite/performance/model_optimization

NVIDIA Developer Blog - Quantization for Deep Learning 
https://developer.nvidia.com/blog/quantization-in-deep-learning/

Microsoft Research - Integer Quantization
https://www.microsoft.com/en-us/research/blog/efficient-inference-on-edge-devices-with-quantized-deep-learning/