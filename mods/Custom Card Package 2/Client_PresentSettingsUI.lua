require '__settings'
require '_ui'

local expand = '˅';-- https://www.amp-what.com/unicode/search/down%20arrow &#709;

function Client_PresentSettingsUI(rootParent)
	cps(rootParent, getSettings());
end

function cps(rootParent, settings)
	local vert = Vert(rootParent);

	for _, setting in ipairs(settings) do
		if setting.isTemplate then			
			local n = 1;

			while n < ((Mod.Settings[setting.name] or setting.bkwrds) + 1) do
				local toAdd = setting.get(n);
				cpsDoSetting(vert, toAdd);
				n = n + 1;
			end
		else
			cpsDoSetting(vert, setting);
		end
	end
end

function cpsDoSetting(vert, setting)
	local settingValue = Mod.Settings[setting.name];
	local vert2 = Vert(vert);
	local horz = Horz(vert2);

	local label = Label(horz).SetText(setting.label .. ': ');
	if setting.labelColor then
		label.SetColor(setting.labelColor);
	end

	createHelpBtn(horz, vert2, setting);

	if settingValue == nil and setting.bkwrds ~= nil then
		settingValue = setting.bkwrds;
	end

	Label(horz).SetText(tostring(settingValue));

	if setting.subsettings and settingValue then
		local btn = Btn(horz).SetText(expand).SetColor('#23A0FF');

		btn.SetOnClick(function()
			expandCollapseSubSettingBtnClicked(btn, vert2, setting);
		end);
	end
end

local settingHelpAreas = {};

function createHelpBtn(btnParent, helpParent, setting)
	if not setting.help then
		return;
	end

	Btn(btnParent).SetText('?').SetColor('#23A0FF').SetOnClick(function()
		if UI.IsDestroyed(settingHelpAreas[setting.name]) then
			settingHelpAreas[setting.name] = Vert(helpParent);
			setting.help(settingHelpAreas[setting.name]);
		else
			UI.Destroy(settingHelpAreas[setting.name]);
		end
	end);
end

local subsettingsAreas = {};

function expandCollapseSubSettingBtnClicked(btn, detailsParent, setting)
	if UI.IsDestroyed(subsettingsAreas[setting.name]) then
		btn.SetText('^');
		subsettingsAreas[setting.name] = Vert(detailsParent);
		cps(subsettingsAreas[setting.name], setting.subsettings);
	else
		UI.Destroy(subsettingsAreas[setting.name]);
		subsettingsAreas[setting.name] = nil;
		btn.SetText(expand);
	end
end
