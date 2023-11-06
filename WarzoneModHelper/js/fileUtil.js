(function() {
	const fsPromises = require('fs').promises;

	function save(files) {
		// files [{name: string, content: string}]

		let numSavedFiles = 0;

		return new Promise(async (resolve, reject) => {
			for (let file of files) {
				const dir = file.name.match(/(?:[^\/\n]+\/)+/);

				if (dir) {
					// auto make dir if it doesnt exist
					await fsPromises.mkdir(dir[0], {recursive: true});
				}

				let fileHandle = null;
				fileHandle = await fsPromises.open(file.name, 'w');
				fileHandle.writeFile(file.content).then(() => {
					numSavedFiles++;
					fileHandle.close();

					if (numSavedFiles == files.length) {
						resolve();
					}
				}).catch((err) => {
					if (fileHandle) {
						fileHandle.close();
					}

					reject(err);
				});
			}
		});
	}

	function load(filenames) {
		// filenames [] of string

		let loadedFiles = {};
		let numLoadedFiles = 0;

		return new Promise(async (resolve, reject) => {
			for (let filename of filenames) {
				let fileHandle;

				try {
					fileHandle = null;
					fileHandle = await fsPromises.open(filename, 'r');
					fileHandle.readFile('utf8').then((content) => {
						if (filename.match(/\.json$/)) {
							content = JSON.parse(content);
						}

						loadedFiles[filename] = content;
						numLoadedFiles++;
						fileHandle.close();

						if (numLoadedFiles == filenames.length) {
							resolve(loadedFiles);
						}
					}).catch((err) => {
						// error while parsing json

						if (fileHandle) {
							fileHandle.close();
						}

						reject(err);
					});
				}
				catch(err) {
					// file not found

					if (fileHandle) {
						fileHandle.close();
					}

					reject(err);
				}
				
			}
		});
	}

	async function readByLines(fileName, onNewLine) {
		let fileHandle;

		try {
			fileHandle = await fsPromises.open(fileName, 'r');

			for await (const line of fileHandle.readLines()) {
				await onNewLine(line);
			}

			fileHandle.close();
		}
		catch(err) {
			if (fileHandle) {
				fileHandle.close();
			}

			throw err;
		}
	}

	async function readdir(dir, options) {
		return await fsPromises.readdir(dir, options);
	}

	module.exports = {save: save, load: load, readByLines: readByLines, readdir: readdir};
})();