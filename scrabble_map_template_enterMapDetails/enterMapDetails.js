(async () => {
	const fetch = require('node-fetch');
	const fs = require('fs');

	function isInt(n) {
		return n === parseInt(n) && isFinite(n) && n >= 0;
	}
	function isFloat(n) {
		return n === parseFloat(n) && isFinite(n) && n >= 0;
	}
	function isStr(str) {
		return typeof str == 'string' && str.length;
	}
	function isStrWith0Or1Spaces(str) {
		if (!isStr(str)) {
			return false;
		}
		if (isStrWith0Spaces(str)) {
			return true;
		}

		const spaces = str.match(/ /g);

		return spaces.length === 1 && spaces.length == str.match(/\s/g).length;
	}
	function isStrWith0Spaces(str) {
		if (!isStr(str)) {
			return false;
		}

		return !!!str.match(/\s/);
	}

	function validateMapDetails(details) {
		try {
			let tIds = {};
			const maxTid = (15 * 15) - 1;//starts at 0

			if (!details || typeof details != 'object') {
				throw new Error('no map details');
			}

			if (!details.territories || typeof details.territories != 'object') {
				throw new Error('bad map details');
			}
			for (let id in details.territories) {
				const t = details.territories[id];

				if (!t || typeof t != 'object') {
					throw new Error('bad map details');
				}
				if (parseInt(id) !== t.id || !isInt(t.id) || t.id > maxTid || !isFloat(t.x) || !isFloat(t.y) || !isStrWith0Or1Spaces(t.name)) {
					throw new Error('bad map details');
				}

				if (tIds[t.id]) {
					throw new Error('bad map details');
				}
				else {
					tIds[t.id] = 0;
				}
			}

			if (!Array.isArray(details.bonuses)) {
				throw new Error('bad map details');
			}
			for (let bonus of details.bonuses) {
				if (!isStrWith0Or1Spaces(bonus.name) || !isStr(bonus.color)) {
					throw new Error('bad map details');
				}
				if (!bonus.color.match(/^#[\da-f]{6}$/i)) {
					throw new Error('bad map details');
				}
				if (!(bonus.value === parseInt(bonus.value) && isFinite(bonus.value) && bonus.value >= -1000 && bonus.value <= 1000)) {
					throw new Error('bad map details');
				}
				if (!Array.isArray(bonus.territories)) {
					throw new Error('bad map details');
				}
				for (let id of bonus.territories) {
					if (!isInt(id)) {
						throw new Error('bad map details');
					}
					if (tIds[id] !== 0) {
						throw new Error('bad map details');
					}
				}
			}

			return details;
		}
		catch(err) {
			throw err;
		}
	}

	function decideConnections(settings) {
		// can get neighbors using +- 15 for left/right and +- 1 for up/down
		// connections are automatically 2 way
		let connections = {};
		function addConnection(t1, t2) {
			t1 = parseInt(t1);
			t2 = parseInt(t2);

			// prevents adding command to t2 with t1 when connection t1 with t2 already exists
			if (!connections[t1] && !connections[t2]) {
				connections[t1] = [t2];
			}
			else if (connections[t1] && !connections[t2]) {
				if (!connections[t1].includes(t2)) {
					connections[t1].push(t2);
				}
			}
			else if (connections[t2] && !connections[t1]) {
				if (!connections[t2].includes(t1)) {
					connections[t2].push(t1);
				}
			}
			else if (!connections[t1].includes(t2) && !connections[t2].includes(t1)){
				connections[t1].push(t2);
			}
		}

		for (let t in settings.mapDetails.territories) {
			t = parseInt(t);

			const hasUp = !!settings.mapDetails.territories[t - 1];
			const hasDown = !!settings.mapDetails.territories[t + 1];
			const hasLeft = !!settings.mapDetails.territories[t - 15];
			const hasRight = !!settings.mapDetails.territories[t + 15];

			if (hasUp) {
				addConnection(t, t - 1);
			}
			if (hasDown) {
				addConnection(t, t + 1);
			}
			if (hasLeft) {
				addConnection(t, t - 15);
			}
			if (hasRight) {
				addConnection(t, t + 15);
			}
		}

		return connections;
	}

	function generatePostData(settings) {
		// https://www.warzone.com/wiki/Set_map_details_API

		const postData = {
			email: settings.email,
			APIToken: settings.apiToken,
			mapID: settings.mapId,
			commands: []
		};

		for (let t in settings.mapDetails.territories) {
			t = settings.mapDetails.territories[t];

			postData.commands.push({command: 'setTerritoryName', id: t.id, name: t.name});
			postData.commands.push({command: 'setTerritoryCenterPoint', id: t.id, x: t.x, y: t.y});
		}

		const connections = decideConnections(settings);
		for (let t1 in connections) {
			t1 = parseInt(t1);

			for (let t2 of connections[t1]) {
				postData.commands.push({command: 'addTerritoryConnection', id1: t1, id2: t2, wrap: 'Normal'});
			}
		}

		for (let b of settings.mapDetails.bonuses) {
			postData.commands.push({command: 'addBonus', name: b.name, armies: b.value, color: b.color.toUpperCase()});

			for (let t of b.territories) {
				postData.commands.push({command: 'addTerritoryToBonus', id: t, bonusName: b.name});
			}
		}

		return postData;
	}

	async function sendPost(data) {		
		// https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
		async function postData(url = '', data = {}) {
			const postSettings = {
				method: 'POST',
				cache: 'no-cache',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(data)
			};
			console.log(postSettings);

			const response = await fetch(url, postSettings);

			return response.json();
		}

		const result = await postData('https://www.warzone.com/API/SetMapDetails', data);

		console.log(result);
	}

	function parseJsonFile(name) {
		try {
			return JSON.parse(fs.readFileSync(name + '.json'));
		}
		catch(err) {
			throw err;
		}
	}

	try {
		const settings = parseJsonFile('settings');
		settings.mapDetails = validateMapDetails(parseJsonFile('mapDetailsForAPI'));

		await sendPost(generatePostData(settings));
	}
	catch(err) {
		console.log(err);
	}
	finally {
		// https://stackoverflow.com/questions/19687407/press-any-key-to-continue-in-nodejs#answer-49959557
		const keypress = async () => {
			process.stdin.setRawMode(true);

			return new Promise(resolve => process.stdin.once('data', () => {
				process.stdin.setRawMode(false);
				resolve();
			}));
		};

		console.log('press any key to exit');
		await keypress();
		process.exit();
	}
})();