require 'ui'
require 'settings'

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	cpc(rootParent, getSettings());
end

function cpc(parent, settings)
	local vert = Vert(parent);

	for _, setting in ipairs(settings) do
		if setting.isTemplate then
			GLOBALS[setting.name] = 0;
			local vert2 = Vert(vert);

			while (setting.latestId or 1) < (setting.prefill or 0) do
				createFromTemplate(vert2, setting);
			end

			Btn(vert).SetColor('#00FF05').SetText(setting.btnText).SetOnClick(function()
				createFromTemplate(vert2, setting);
			end);
		else
			cpcDoSetting(vert, setting);
		end
	end
end

function createFromTemplate(vert, template)
	GLOBALS[template.name] = template.add();
	cpcDoSetting(vert, template.get(GLOBALS[template.name]));
end

function cpcDoSetting(vert, setting)
	local initialSettingValue = Mod.Settings[setting.name];

	if initialSettingValue == nil then
		initialSettingValue = setting.defaultValue;
	end

	local horz = Horz(vert);
	local vert2 = Vert(vert);

	if setting.inputType == 'bool' then
		GLOBALS[setting.name] = Checkbox(horz)
			.SetText(setting.label)
			.SetIsChecked(initialSettingValue);

		local vert3 = Vert(vert2);
		createHelpBtn(horz, Vert(vert3), setting);

		if setting.subsettings then
			local vert4 = nil;
			local subsettingEnabledOrDisabled = function()
				if GLOBALS[setting.name].GetIsChecked() then
					vert4 = Vert(vert3);
					cpc(vert4, setting.subsettings);
				elseif not UI.IsDestroyed(vert4) then
					UI.Destroy(vert4);
				end
			end

			GLOBALS[setting.name].SetOnValueChanged(subsettingEnabledOrDisabled);
			subsettingEnabledOrDisabled();
		end
	else
		Label(horz).SetText(setting.label);
		createHelpBtn(horz, vert2, setting);

		GLOBALS[setting.name] = NumInput(horz)
			.SetSliderMinValue(setting.minValue)
			.SetSliderMaxValue(setting.maxValue)
			.SetValue(initialSettingValue);

		if setting.inputType == 'float' then
			GLOBALS[setting.name].SetWholeNumbers(false);
		end
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