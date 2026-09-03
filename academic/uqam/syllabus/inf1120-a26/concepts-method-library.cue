package inf1120a26

conceptsMethodLibrary: [
    {id: "concept:method-definition-call", label: "Définition et appel de méthodes", kind: "method", description: "Entête/corps, méthodes static, appels entre méthodes et utilisation de méthodes existantes.", evidence: ["src:methods"]},
    {id: "concept:method-parameters", label: "Paramètres formels et effectifs", kind: "method", description: "Correspondance, ordre, types et compatibilité d’affectation lors des appels.", evidence: ["src:methods"]},
    {id: "concept:method-return", label: "Valeur de retour", kind: "method", description: "Méthodes void ou avec type de retour et emploi du résultat dans des expressions.", evidence: ["src:methods", "src:correction-criteria"]},
    {id: "concept:pass-by-value", label: "Passage des paramètres par valeur", kind: "method", description: "Les paramètres reçoivent une copie de la valeur de l’argument.", evidence: ["src:methods"]},
    {id: "concept:scope", label: "Portée des variables et constantes", kind: "method", description: "Visibilité selon les blocs et distinction avec les variables globales.", evidence: ["src:methods"]},
    {id: "concept:functional-decomposition", label: "Décomposition fonctionnelle, cohésion et faible couplage", kind: "method", description: "Découper le problème en méthodes spécialisées, paramétrées et réutilisables.", evidence: ["src:methods", "src:correction-criteria"]},
    {id: "concept:method-overloading", label: "Signature et surdéfinition de méthodes", kind: "method", description: "Signature, coexistence de méthodes et sélection de la surcharge par le compilateur.", evidence: ["src:methods"]},
    {id: "concept:string-instance-methods", label: "Méthodes d’instance de String", kind: "library", description: "Appeler des méthodes sur une instance String non null.", evidence: ["src:string"]},
    {id: "concept:string-index-length", label: "String: charAt, length, isEmpty", kind: "library", description: "Accès par indice, longueur et test de chaîne vide.", evidence: ["src:string"]},
    {id: "concept:string-transform-substring", label: "String: transformations et sous-chaînes", kind: "library", description: "Méthodes de casse et extraction de sous-chaînes.", evidence: ["src:string"]},
    {id: "concept:string-search-compare", label: "String: recherche et comparaison", kind: "library", description: "contains, indexOf/lastIndexOf, comparaisons et égalité de chaînes.", evidence: ["src:string"]},
    {id: "concept:string-static-valueof", label: "String.valueOf", kind: "library", description: "Méthodes static de conversion en représentation String.", evidence: ["src:string"]},
    {id: "concept:math-static-methods", label: "Méthodes statiques de Math", kind: "library", description: "Appel des méthodes Math en les préfixant du nom de classe.", evidence: ["src:math"]},
    {id: "concept:math-numeric-functions", label: "Math: fonctions numériques", kind: "library", description: "Familles de méthodes telles que min/max et autres fonctions numériques présentées dans les notes.", evidence: ["src:math"]},
]
