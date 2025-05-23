(async () => {
	const path = require('path');
	const base64 = require('base-64');
	const utf8 = require('utf8');
	const fileUtil = require('./fileUtil');

	function isPlainObj(obj) {
		return obj && typeof obj == 'object' && !Array.isArray(obj);
	}

	function isString(str) {
		return str && typeof str == 'string';
	}

	function isUnsignedInt(num) {
		const n = parseInt(num);

		return num == n && isFinite(n) && n > -1;
	}

	async function getSettings() {
		const settingsFileName = path.resolve('../settings.json');
		class SettingsSyntaxError extends Error {
			constructor() {
				super('Incorrect syntax for ' + settingsFileName + ' file, expected {"apiToken": string, "path": string, "modId": unsigned int}');
				this.name = 'SettingsSyntaxError';
			}
		};

		try {
			const settings = (await fileUtil.load([settingsFileName]))[settingsFileName];

			if (!isPlainObj(settings)) {
				throw new SettingsSyntaxError();
			}

			if (!(isString(settings.apiToken) && isString(settings.path) && isUnsignedInt(settings.modId))) {
				throw new SettingsSyntaxError();
			}

			return {apiToken: settings.apiToken, modDir: path.normalize(settings.path), modId: settings.modId};
		}
		catch(err) {
			throw err;
		}
	}

	const {apiToken, modDir, modId} = await getSettings();
	let postData = {
		files: []
	};

	try {
		const files = await fileUtil.readdir(modDir, {recursive: true});

		for (const file of files) {
			// https://stackoverflow.com/questions/53799385/how-can-i-convert-a-windows-path-to-posix-path-using-node-path#answer-63251716
			const linuxFileName = file.split(path.sep).join(path.posix.sep);
			const localFileName = path.join(modDir, file);

			postData.files.push({
				path: linuxFileName,
				content: base64.encode(utf8.encode((await fileUtil.load([localFileName]))[localFileName]))
			});
		}
	}
	catch(err) {
		// modDir not found
		throw err;
	}

	console.log(`Updating mod ${modId}...`);

	const responce = await (await fetch(`https://www.warzone.com/API/UpdateMod?ModID=${modId}&APIToken=${encodeURIComponent(apiToken)}`, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(postData)
	})).json();

	if (responce.error) {
		throw new Error(responce.error);
	}
	else {
		console.log('Updated!');
	}
})();