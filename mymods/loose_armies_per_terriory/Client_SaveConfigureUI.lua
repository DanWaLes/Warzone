require "Util"
require "LoseArmiesPerTerritory"

function Client_SaveConfigureUI(alert)
	local goldVal = goldInputField.GetValue();
	local territoriesVal = territoriesInputField.GetValue();
	local errMsg;
	local goldErrMsg = "Gold must be between " .. tostring(GetDefaults("GoldMinVal")) .. " and " .. tostring(GetDefaults("GoldMaxVal")) .. ".";
	local territoriesErrMsg = "Territories must be between " .. tostring(GetDefaults("TerritoriesMinVal")) .. " and " .. tostring(GetDefaults("TerritoriesMaxVal")) .. ".";

	-- validate - may as well list all errors
	if goldVal < GetDefaults("GoldMinVal") or goldVal > GetDefaults("GoldMaxVal") then
		errMsg = goldErrMsg;
	end
	if territoriesVal < GetDefaults("TerritoriesMinVal") or territoriesVal > GetDefaults("TerritoriesMaxVal") then
		errMsg = ternary(errMsg, errMsg .. "\n" .. goldErrMsg, goldErrMsg);
	end

	if errMsg then
		return alert(errMsg);
	end

	-- write to Mod.Settings
	Mod.Settings.Gold = goldVal;
	Mod.Settings.Territories = territoriesVal;
end