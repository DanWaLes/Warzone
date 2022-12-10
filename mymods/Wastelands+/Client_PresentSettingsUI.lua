require 'settings'

local expand = '˅';-- https://www.amp-what.com/unicode/search/down%20arrow &#709;

function Client_PresentSettingsUI(rootParent)
	cps(rootParent, getSettings(), 0);
end

function cps(rootParent, settings)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for _, setting in ipairs(settings) do
		local settingName = setting.name;
		local settingValue = Mod.Settings[settingName];
		local vert2 = UI.CreateVerticalLayoutGroup(vert);
		local horz = UI.CreateHorizontalLayoutGroup(vert2);

		UI.CreateLabel(horz).SetText(setting.label .. ': ' .. tostring(settingValue));

		createHelpBtn(horz, vert2, setting);

		if setting.subsettings and settingValue then
			local btn = UI.CreateButton(horz).SetText(expand).SetColor('#23A0FF');

			btn.SetOnClick(function()
				expandCollapseSubSettingBtnClicked(btn, vert2, setting);
			end);
		end
	end
end

local settingHelpAreas = {};

function createHelpBtn(btnParent, helpParent, setting)
	if not setting.help then
		return;
	end

	UI.CreateButton(btnParent).SetText('?').SetColor('#23A0FF').SetOnClick(function()
		if UI.IsDestroyed(settingHelpAreas[setting.name]) then
			settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
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
		subsettingsAreas[setting.name] = UI.CreateVerticalLayoutGroup(detailsParent);
		cps(subsettingsAreas[setting.name], setting.subsettings);
	else
		UI.Destroy(subsettingsAreas[setting.name]);
		subsettingsAreas[setting.name] = nil;
		btn.SetText(expand);
	end
end