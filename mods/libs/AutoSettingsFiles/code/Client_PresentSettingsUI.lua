-- copied from https://github.com/DanWaLes/Warzone/tree/main/mods/libs/AutoSettingsFiles

require('__settings');

local canUseUIElementIsDestroyed;

function Client_PresentSettingsUI(rootParent)
	canUseUIElementIsDestroyed = WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21');

	cps(rootParent, getSettings(), 0);
end

function cps(rootParent, settings)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for _, setting in ipairs(settings) do
		if setting.isTemplate then
			local n = 1;

			while n < ((Mod.Settings[setting.name] or setting.bkwrds) + 1) do
				cpsDoSetting(vert, setting.get(n));
				n = n + 1;
			end
		else
			cpsDoSetting(vert, setting);
		end
	end
end

function cpsDoSetting(vert, setting)
	if setting.isCustomCard then
		if setting.usesSettings then
			cps(vert, setting.settings);
		end

		return;
	end

	local vert2 = UI.CreateVerticalLayoutGroup(vert);
	local horz = UI.CreateHorizontalLayoutGroup(vert2);
	local settingLabel = UI.CreateLabel(horz).SetText(setting.label .. ': ');
	local settingValue = Mod.Settings[setting.name];

	if setting.labelColor then
		settingLabel.SetColor(setting.labelColor);
	end

	createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert2), setting);

	if settingValue == nil and setting.bkwrds ~= nil then
		settingValue = setting.bkwrds;
	end

	local settingValueLabel = UI.CreateLabel(horz);

	if setting.inputType == 'radio' then
		local control = setting.controls[settingValue];
		local controlIsTable = type(control) == 'table';

		settingValueLabel.SetText(tostring((controlIsTable and control.label) or label));

		if controlIsTable then
			if control.labelColor then
				settingValueLabel.SetColor(control.labelColor);
			end

			if control.help then
				-- make a fake setting to reuse createHelpBtn

				local fakeSetting = {
					name = setting.name .. tostring(settingValue),
					help = control.help
				};

				createHelpBtn(horz, vert2, fakeSetting);
			end
		end
	else
		settingValueLabel.SetText(tostring(settingValue));
	end

	if not (setting.subsettings and settingValue) then
		return;
	end

	local btn = UI.CreateButton(horz).SetText(getExpandBtnLabelTxt()).SetColor('#23A0FF');

	btn.SetOnClick(function()
		expandCollapseSubSettingBtnClicked(btn, vert2, setting);
	end);
end

local settingHelpAreas = {};

function createHelpBtn(btnParent, helpParent, setting)
	if not setting.help then
		return;
	end

	UI.CreateButton(btnParent).SetText('?').SetColor('#23A0FF').SetOnClick(function()
		if not canUseUIElementIsDestroyed then
			if not settingHelpAreas[setting.name] then
				settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
				setting.help(settingHelpAreas[setting.name]);
			end
		elseif UI.IsDestroyed(settingHelpAreas[setting.name]) then
			settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
			setting.help(settingHelpAreas[setting.name]);
		else
			UI.Destroy(settingHelpAreas[setting.name]);
		end
	end);
end

local subsettingsAreas = {};

function expandCollapseSubSettingBtnClicked(btn, detailsParent, setting)
	if not canUseUIElementIsDestroyed then
		if not subsettingsAreas[setting.name] then
			subsettingsAreas[setting.name] = UI.CreateVerticalLayoutGroup(detailsParent);
			cps(subsettingsAreas[setting.name], setting.subsettings);
		end
	elseif UI.IsDestroyed(subsettingsAreas[setting.name]) then
		btn.SetText(getCollapseBtnLabelTxt());
		subsettingsAreas[setting.name] = UI.CreateVerticalLayoutGroup(detailsParent);
		cps(subsettingsAreas[setting.name], setting.subsettings);
	else
		UI.Destroy(subsettingsAreas[setting.name]);
		subsettingsAreas[setting.name] = nil;
		btn.SetText(getExpandBtnLabelTxt());
	end
end
