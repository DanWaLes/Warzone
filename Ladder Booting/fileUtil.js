(function() {
	const fsPromises = require("fs").promises;

	function save(files) {
		// files [{name: string, content: string}]

		let fileHandles = [];
		let numSaved = 0;

		function closeFileHandles() {
			for (let i = fileHandles.length - 1; i > -1; i--) {
				const fileHandle = fileHandles.pop();
				fileHandle.close();
			}
		}

		return new Promise(async (resolve, reject) => {
			for (let file of files) {
				const dir = file.name.match(/(?:[^\/\n]+\/)+/);
				if (dir) {
					// auto make dir if it doesnt exist
					await fsPromises.mkdir(dir[0], {recursive: true});
				}

				const fileHandle = await fsPromises.open(file.name, 'w');

				fileHandles.push(fileHandle);
				fileHandle.writeFile(file.content).then(() => {
					numSaved++;

					if (numSaved == files.length) {
						closeFileHandles();
						resolve();
					}
				}).catch((err) => {
					closeFileHandles();
					reject(err);
				});
			}
		});
	}

	function load(filenames) {
		// filenames [] of string
		// needs testing

		let fileHandles = [];
		let loadedFiles = {
			files: {},
			length: 0
		};

		function closeFileHandles() {
			for (let i = fileHandles.length - 1; i > -1; i--) {
				const fileHandle = fileHandles.pop();
				fileHandle.close();
			}
		}

		return new Promise(async (resolve, reject) => {
			for (let filename of filenames) {
				const fileHandle = await fsPromises.open(filename, 'r');// load and save used in same file causes conflict

				fileHandle.readFile('utf8').then((content) => {
					if (filename.match(/\.json$/)) {
						content = JSON.parse(content);
					}

					loadedFiles.files[filename] = content;
					loadedFiles.length++;

					if (loadedFiles.length == filenames.length) {
						closeFileHandles();
						resolve(loadedFiles.files);
					}
				}).catch((err) => {
					closeFileHandles();
					reject(err);
				});
			}
		});
	}

	async function readdir(dir) {
		return await fsPromises.readdir(dir);
	}

	module.exports = {save: save, load: load, readdir: readdir};
})();