(async () => {
	const fetch = require('node-fetch');

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
		console.log('postSettings = ')
		console.log(postSettings);

		const response = await (fetch(url, postSettings).then((response) => response.json()));

		console.log('response = ');
		console.log(response);
		return response;
	}

	module.exports = {postData: postData};
})();