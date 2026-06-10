// /create_lobby --> Code
// /change_settings
// /join_lobby/:code
// /list_public_sessions
//
//
// create_lobbby:
// INPUT 
// {
//     'type': 'create_lobby',
//     'id': multiplayer.get_unique_id()
// }
// Il s'enregiste en tant que joueur, et devient le host, et doit lancer le serv sur son port
// OUTPUT: {
//	'code': <Code UID>
// }
//
// join_lobbby:
// INPUT 
// {
//     'type': 'join_lobby',
//     'id': multiplayer.get_unique_id(),
//     'code': <Code UID>
// }
// Il s'enregiste en tant que joueur, attend de recevir les information du host qand la partie commencera
// OUTPUT: {
// 	'status': "Nice, now you have to wait"
// }
//
// start: 
//
// INPUT: {
//     'type': 'join_lobby',
//     'id': multiplayer.get_unique_id(),
//     'code': <Code UID>
// }
//
// Envoie a tout les gens du lobby
// Si c'est le host: 
	// OUTPUT: {
		// type: 'connect',
		// players: [{
			// target_ip: playerB.ip,
			// target_port: playerB.port
		// }],
		// is_host: true
	//
// Sinon:
	// OUTPUT: {
		// type: 'connect',
		// target_ip: playerB.ip,
		// target_port: playerB.port,
		// is_host: false
	//
	// }

const PORT = 9999

const dgram = require('dgram');
const server = dgram.createSocket('udp4');

let lobbys = {} // Liste<Player>
// Player {
//     ip:
//     port:
//     is_host:
// }

function generate_code(length = 6) {
	const allowed_letters = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789"

	let code = ""
	for(let i = 0; i<length; i++) {
		code += allowed_letters[Math.floor(Math.random() * allowed_letters.length)]
	}
	
	if(code in lobby){
		return generate_code(length)
	}
	return code;

	
}

server.on('listening', () => {
    const address = server.address();
    console.log(`[VPS] Serveur de Hole Punching actif sur ${address.address}:${address.port}`);
});

server.on('message', (msg, rinfo) => {
    try {
        // 1. On décode la requête JSON reçue de Godot
        const data = JSON.parse(msg.toString());

	// CREATE LOBBY:
	if (data.type === 'create_lobby') {
		let code = generate_code()
		const newPlayer = {
		    ip: rinfo.address,
		    port: rinfo.port,
	            is_host: true
		};
		lobbys[code] = [newPlayer]
	}

        // 2. Traitement de la requête "register"
        if (data.type === 'register') {
            console.log(`[INSCRIPTION] Joueur détecté : ${rinfo.address}:${rinfo.port}`);

            // On enregistre ses coordonnées publiques (fournies par rinfo)
            const newPlayer = {
                ip: rinfo.address,
                port: rinfo.port
            };

            waitingPlayers.push(newPlayer);

            // 3. Si on a 2 joueurs, on déclenche la mise en relation
            if (waitingPlayers.length === 2) {
                const playerA = waitingPlayers[0];
                const playerB = waitingPlayers[1];

                console.log(`[MATCH] Paire trouvée ! Envoi des coordonnées...`);

                // Envoi des infos de B au Joueur A (A sera le Host)
                const responseToA = JSON.stringify({
                    type: 'connect',
                    target_ip: playerB.ip,
                    target_port: playerB.port,
                    is_host: true
                });
                server.send(responseToA, playerA.port, playerA.ip);

                // Envoi des infos de A au Joueur B (B sera le Client)
                const responseToB = JSON.stringify({
                    type: 'connect',
                    target_ip: playerA.ip,
                    target_port: playerA.port,
                    is_host: false
                });
                server.send(responseToB, playerB.port, playerB.ip);

                // On vide la liste d'attente pour le prochain duo
                waitingPlayers = [];
            }
        }
    } catch (error) {
        console.error("[ERREUR] Paquet malformé reçu :", msg.toString());
    }
});

// Lancement du serveur sur le port choisi
server.bind(PORT);


