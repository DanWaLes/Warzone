#!/usr/bin/python3

import json
from os import walk, path
import base64
import requests
import urllib.parse

def main():
	settings = getSettings()
	doPost(settings, readFiles(settings))
	input('Press any key to close...');

def getSettings():
	settingsFileName = '../settings.json';

	try:
		f = open(settingsFileName);
		settings = json.load(f);
		f.close();

		if not (settings['apiToken'] and type(settings['apiToken']) == str):
			raise Exception('settings.apiToken must be a non-empty string')

		if not (settings['path'] and type(settings['path']) == str):
			raise Exception('settings.path must be a non-empty string')

		if not (type(settings['modId']) == int and settings['modId'] > -1):
			raise Exception('settings.modId must be a unsigned int')

		return {'apiToken': settings['apiToken'], 'modDir': settings['path'], 'modId': settings['modId']}
	except Exception as err:
		print('error while loading/readings settings')
		raise err

def readFiles(settings):
	# https://stackoverflow.com/questions/3207219/how-do-i-list-all-files-of-a-directory#answer-3207973
	# https://stackoverflow.com/questions/23164058/how-to-encode-text-to-base64-in-python#answer-23164102

	try:
		dir = settings['modDir']
		files = []

		for (dirpath, dirnames, filenames) in walk(dir):
			for (file) in filenames:
				f = open(path.join(dir, file), 'r', encoding = 'utf-8')
				content = f.read()
				f.close()

				files.append({
					'path': file,
					'content': base64.b64encode(bytes(content, 'utf-8')).decode('utf-8')
				})

		return files
	except Exception as err:
		print('error while reading mod files')
		raise err

def doPost(settings, files):
	# https://www.w3schools.com/python/ref_requests_post.asp
	# https://www.urlencoder.io/python/

	apiToken = settings['apiToken']
	modId = settings['modId']

	print('Updating mod ' + str(modId) + '...');

	url = 'https://www.warzone.com/API/UpdateMod';
	queryString = '?' + urllib.parse.urlencode({'ModID': modId, 'APIToken': apiToken});
	jsonData = {'files': files};

	response = requests.post(url + queryString, json = jsonData, headers = {
		'Content-Type': 'application/json'
	});

	if not response.ok:
		raise Exception('Failed with status ' + str(response.status_code))

	responseJSON = response.json()

	if 'error' in responseJSON:
		raise Exception(responseJSON['error'])
	else:
		print('Updated!')

	response.close();

main();