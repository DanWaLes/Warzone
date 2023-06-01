/* jshint esnext: false */
/* jshint esversion: 9 */
/* jshint node: true */
/* jshint browser: false */
/* jshint devel: true */

(async () => {
	const sleep = require('./sleep').sleep;
	const postData = require('./postData').postData;
	const fileUtil = require('./fileUtil');
	const settingsFileName = 'settings.json';
	const settings = (await fileUtil.load([settingsFileName]))[settingsFileName];

	async function getGameIds() {
		let ladderIds = {
			'1v1': 0,
			'2v2': 1,
			'3v3': 3
		};
		const seasonalOffset = 4000;
		const end = seasonalOffset + 86;// 86 is latest season for 2023-06-01

		for (let i = seasonalOffset; i < (end + 1); i++) {
			ladderIds['season' + (i + 1 - seasonalOffset)] = i;
		}

		for (let ladderName in ladderIds) {
			const ladder = {
				id: ladderIds[ladderName]
			};

			ladder.dateRequestedFeed = new Date().toJSON();
			const result = await postData('https://www.warzone.com/API/GameIDFeed?LadderID=' + ladder.id, {
				'Email': settings.email,
				'APIToken': settings.apiToken
			});

			ladder.games = result.gameIDs || [];

			if (result.error) {
				ladder.error = result.error;
			}

			await fileUtil.save([{
				name: 'games/feed/' + ladderName + '.json',
				content: JSON.stringify(ladder)
			}]);

			await sleep(1000);// to not overwhelm the servers
		}

		console.log('done getGameIds');
	}

	async function getGameDetails() {
		const files = await fileUtil.readdir('games/feed');

		for (let file of files) {
			const contents = await fileUtil.load(['games/feed/' + file]);

			for (let game of contents.games) {
				const result = await postData('https://www.warzone.com/API/GameFeed?GameID=' + game + '&GetSettings=true', {
					'email': settings.email,
					'APIToken': settings.apiToken
				});

				if (result.map) {
					// dont need to store all the map's details for this
					result.map = {
						id: result.map.id,
						name: result.map.name
					};
				}

				await fileUtil.save([{
					name: 'games/details/' + game + '.json',
					content: JSON.stringify(result)
				}]);

				await sleep(1000);// to not overwhelm the servers
			}
		}

		console.log('done getGameDetails');
	}

	console.log('starting');
	await getGameIds();
	await getGameDetails();
	console.log('done')
})();
