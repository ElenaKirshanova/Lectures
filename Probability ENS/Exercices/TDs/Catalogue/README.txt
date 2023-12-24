Mode d’emploi du catalogue:


- le fichier TDcatalogue.tex est généré automatiquement à partir du dossier Exercices grâce à un appel de « bash catalog.sh » (pratique pour mettre à jour si on rajoute des exercices). La ligne \correction permet d’inclure le corrigé de chaque question.
- Dans Squelette.tex, on voit que la seule chose à faire pour construire sa fiche de TD est de choisir les exercices dans le catalogue, puis de les appeler un par un avec la commande \Exercice[titre]{00-Dossier}{NomExo}. Meme règle que précédemment pour la ligne \correction
- C’est le bazar dans les .sty, il faudrait un jour réussir à faire en sorte que Latex appelle ceux qui sont dans texinput plutot que de devoir les copier juste à côté de là où l’on compile.