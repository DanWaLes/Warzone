(async () => {
	const fetch = require('node-fetch');
	const sleep = require('./sleep').sleep;

	function fetchWithTimeout(url, postSettings, timeout) {
		if (timeout < 1 || typeof timeout != "number") {
			return;
		}

		return Promise.race([
			fetch(url, postSettings),
			new Promise((_, reject) => {
				setTimeout(() => reject(new Error('timeout')), timeout);
			})
		]);
	}

	async function sendPost(url, postSettings, delay) {
		if (typeof delay != "number") {
			delay = 100;
		}

		await sleep(delay);

		return await fetchWithTimeout(url, postSettings, 10000)
			.then(response => response.json())
			.catch(err => {
				console.log('error on ' + url + ' with')
				console.log(postSettings);
				console.log('delay = ' + delay);
				console.log('trying again with delay * 2');

				return sendPost(url, postSettings, delay * 2);
			});
	}

	// based on https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
	async function postData(url = '', data = {}, toPostParams) {
		let newData = JSON.stringify(data);

		if (toPostParams) {
			newData = '';

			for (let key in data) {
				newData += '&' + key + '=' + data[key];
			}

			newData = newData.replace(/^&/, '');
		}

		const postSettings = {
			method: 'POST',
			cache: 'no-cache',
			headers: {
				'Content-Type': 'application/json'
			},
			body: newData
		};

		return await sendPost(url, postSettings);
	}

	module.exports = {postData: postData};
})();