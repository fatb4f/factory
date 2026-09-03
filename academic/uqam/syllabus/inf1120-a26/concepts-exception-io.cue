package inf1120a26

conceptsExceptionIO: [
    {id: "concept:exception-model", label: "Modèle d’exception", kind: "exception", description: "Une exception signale une situation anormale et interrompt le flot si elle n’est pas gérée.", evidence: ["src:exceptions"]},
    {id: "concept:checked-unchecked", label: "Exceptions implicites et explicites", kind: "exception", description: "Distinguer RuntimeException des exceptions vérifiées qui doivent être gérées ou déclarées.", evidence: ["src:exceptions"]},
    {id: "concept:try-catch", label: "try / catch", kind: "exception", description: "Protéger des instructions susceptibles de lever une exception et intercepter celle-ci.", evidence: ["src:exceptions"]},
    {id: "concept:multi-catch", label: "Plusieurs catch et multicatch", kind: "exception", description: "Gérer plusieurs types d’exceptions avec plusieurs gestionnaires ou un multicatch.", evidence: ["src:exceptions"]},
    {id: "concept:throws-propagation", label: "Propagation et throws", kind: "exception", description: "Propagation de l’exception vers la méthode appelante et déclaration throws.", evidence: ["src:exceptions"]},
    {id: "concept:custom-exceptions", label: "Classes d’exception personnalisées", kind: "exception", description: "Définir une classe d’exception par héritage dans le périmètre présenté.", evidence: ["src:exceptions"]},
    {id: "concept:throw-clause", label: "Clause throw", kind: "exception", description: "Construire et lancer explicitement un objet exception.", evidence: ["src:exceptions"]},
    {id: "concept:exception-message", label: "Message d’exception", kind: "exception", description: "Transmettre de l’information au gestionnaire via le message de l’exception.", evidence: ["src:exceptions"]},
    {id: "concept:finally", label: "Bloc finally", kind: "exception", description: "Exécuter un bloc après try/catch selon le mécanisme présenté.", evidence: ["src:exceptions", "src:text-files"]},
    {id: "concept:file-paths", label: "Chemins absolus et relatifs", kind: "io", description: "Localiser un fichier par chemin absolu ou relatif au projet/application.", evidence: ["src:text-files"]},
    {id: "concept:java-io-package", label: "Paquetage java.io", kind: "io", description: "Importer et utiliser les classes de flux de caractères présentées dans le cours.", evidence: ["src:text-files"]},
    {id: "concept:file-reading", label: "Lecture texte: FileReader / BufferedReader", kind: "io", description: "Créer les lecteurs et lire caractères ou lignes.", evidence: ["src:text-files"]},
    {id: "concept:file-writing", label: "Écriture texte: FileWriter / PrintWriter", kind: "io", description: "Créer les écrivains, écrire différents types et utiliser le mode append.", evidence: ["src:text-files"]},
    {id: "concept:io-exceptions-resources", label: "Exceptions et fermeture des flux", kind: "io", description: "Gérer FileNotFoundException/IOException et fermer les ressources.", evidence: ["src:text-files", "src:exceptions"]},
]
