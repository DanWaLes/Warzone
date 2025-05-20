(function() {
	function sleep(duration) {
		const resumeTime = new Date().getTime() + duration;

		while (true) {
			if (new Date().getTime() >= resumeTime) {
				break;
			}
		}
	}

	module.exports = {sleep: sleep};
})();