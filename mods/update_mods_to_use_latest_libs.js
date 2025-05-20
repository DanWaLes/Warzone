(async () => {
	const fs = require('fs/promises');
	const path = require('path');

	async function readFileContents(fileName) {
		return await fs.readFile(fileName, {encoding: 'utf8'});
	}

	async function setFileContents(fileName, contents) {
		return await fs.writeFile(fileName, contents);
	}

	async function pathExists(fileName, mode) {
		const modes = {
			all: 0,
			dirsOnly: 1,
			filesOnly: 2
		};

		if (!modes[mode]) {
			modes[mode] = modes.all;
		}

		return await (
			fs.stat(fileName)
				.then(
					(stats) => {
						switch (modes[mode]) {
							case modes.dirsOnly: return stats.isDirectory();
							case modes.filesOnly: return stats.isFile();
							default: return true;
						}
					},
					() => false
				)
		);
	}

	async function getLibFiles(libName) {
		const libFilesLocation = path.join(process.cwd(), 'libs', libName, 'code');
		const libFiles = {};
		const files = (await fs.readdir(libFilesLocation)).filter((file) => !file.match(/^__[^_]/));
		let filesRead = 0;
		let _resolve;

		async function readFile(file) {
			const filePath = path.join(libFilesLocation, file);
			const contents = await readFileContents(filePath);

			libFiles[file] = contents;
			filesRead++;

			if (filesRead === files.length) {
				_resolve();
			}
		}

		await new Promise((resolve) => {
			_resolve = resolve;
			files.forEach((file) => readFile(file));
		});

		return libFiles;
	}

	async function updateModToUseLatestLib(modName, libFiles) {
		// only copy over files that already exist in the mod

		const modFilesLocation = path.join(process.cwd(), modName);
		const filesToCopy = [];

		for (const file of Object.keys(libFiles)) {
			const filePath = path.join(modFilesLocation, file);
			const fileExists = await pathExists(filePath, 'filesOnly');

			if (!fileExists) {
				continue;
			}

			filesToCopy.push(file);
		}

		await Promise.all(filesToCopy.map((file) => {
			return new Promise((resolve) => {
				setFileContents(path.join(process.cwd(), modName, file), libFiles[file]).then(() => resolve());
			});
		}));
	}

	async function main(libsWithUpdates, mods) {
		const modsUpdated = {};
		const bull = '* ';

		console.log('\nMods using the following libs will be updated:\n' + bull + libsWithUpdates.join('\n' + bull));

		await Promise.all(libsWithUpdates.map((lib) => {
			return new Promise(async (resolve) => {
				const libFiles = await getLibFiles(lib);

				for (const [mod, libs] of Object.entries(mods)) {
					if (!libs.includes(lib)) {
						continue;
					}

					modsUpdated[mod] = true;
					await updateModToUseLatestLib(mod, libFiles);
				}

				resolve();
			})
		}));

		console.log('\nThe following mods were updated:\n' + bull + Object.keys(modsUpdated).join('\n' + bull));
	}

	const libsWithUpdates = ['AutoSettingsFiles'];
	const mods = {
		'AIs dont attack': ['AutoSettingsFiles', 'tblprint'],
		'Advanced Card Distribution per player': ['AutoSettingsFiles', 'lua_util', 'tblprint', 'ui'],
		'Custom Card Package 2': ['AutoSettingsFiles', 'eliminate', 'lua_util', 'placeOrderInCorrectPosition', 'tblprint', 'ui', 'version'],
		'Custom Card Package 2 upgrade': ['AutoSettingsFiles', 'TerritoryOrBonusSelectionMenu', 'eliminate', 'lua_util', 'tblprint', 'ui', 'version'],
		'Draw Resolver': ['eliminate', 'tblprint', 'ui', 'version'],
		'Host spies on and can eliminate players': ['eliminate', 'tblprint', 'ui', 'version'],
		'Locked Down Regions': ['TerritoryOrBonusSelectionMenu', 'tblprint', 'ui', 'version'],
		'Map testing - territory connections': ['tblprint', 'ui', 'version'],
		'Mystery Card': ['AutoSettingsFiles', 'tblprint', 'ui', 'version'],
		'Order Notes': ['placeOrderInCorrectPosition', 'tblprint', 'ui', 'version'],
		'Random settings generator': ['AutoSettingsFiles', 'lua_util', 'tblprint', 'ui'],
		'Stationary commanders': ['tblprint'],
		'Surveillance Card+': ['AutoSettingsFiles', 'tblprint'],
		'Swap Territories 2': ['AutoSettingsFiles', 'tblprint', 'ui', 'version'],
		'Territories without armies become neutral': ['tblprint', 'version'],
		'Wastelands+': ['AutoSettingsFiles', 'tblprint', 'ui']
	};

	await main(libsWithUpdates, mods);
})();
