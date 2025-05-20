#!/usr/bin/python3

import logging
import os
import json
import re

def readFile(path):
	file = open(path, 'r')
	content = file.read()
	file.close()

	return content

def readJSONFile(path):
	return json.loads(readFile(path))

def main(dateToAnalise):
	dataFilesPath = os.path.join(os.getcwd(), 'data', dateToAnalise)
	dataFiles = os.listdir(dataFilesPath);
	data = {}

	for fileName in dataFiles:
		modId = re.match(r'^(\d+)', fileName).group(1)
		data[modId] = {}

		filePath = os.path.join(dataFilesPath, fileName)
		perfData = readJSONFile(filePath)['PerfData']
		data[modId]['uniqueGames'] = set()

		for call in perfData:
			data[modId]['uniqueGames'].add(call['GameID'])

	modIdsSortedByMostUniqueGames = sorted(data.keys(), key=lambda modId: len(data[modId]['uniqueGames']), reverse=True)

	modIdsAndNames = readJSONFile(os.path.join(os.getcwd(), 'ModIDs_to_ModNames.json'));

	for modId in modIdsSortedByMostUniqueGames:
		modData = data[modId]
		numGames = len(modData['uniqueGames'])

		print(modIdsAndNames[modId] + ' has been used by ' + str(numGames) + ' different game' + (numGames != 1 and 's' or ''))

try:
	main('2024-02-19')
except Exception as e:
	logging.exception(e)
finally:
	input('press any key to exit')