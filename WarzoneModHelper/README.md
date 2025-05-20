# Usage
1. enter details in the `settings.json` file

## NodeJS
2. `cd` into the `WarzoneModHelper/js` directory
3. install required packages with `npm install package-lock.json`
4. run the program with `node index.js`

## Python
2. `cd` into the `WarzoneModHelper/py` directory
3. install a required package with `pip3 install requests`
4. run the program with `python main.py`

# settings.json
"apiToken" - from [the GetAPIToken page](https://www.warzone.com/API/GetAPIToken)<br>
"path": - local path to the mod. for windows directories, use `\\`. mac/linux use `/`. should use an absolute path<br>
"modId": - the id of the mod to update