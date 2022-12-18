-- shorthand function names

function Vert(parent)
	return UI.CreateVerticalLayoutGroup(parent);
end

function Horz(parent)
	return UI.CreateHorizontalLayoutGroup(parent);
end

function Label(parent)
	return UI.CreateLabel(parent);
end

function Btn(parent)
	return UI.CreateButton(parent);
end

function Checkbox(parent)
	return UI.CreateCheckBox(parent);
end

function TxtInput(parent)
	return UI.CreateTextInputField(parent);
end

function NumInput(parent)
	return UI.CreateNumberInputField(parent);
end

-- useful structures

function Tabs(parent, tabLabels, tabsClicked)
	local tabData = {
		tabsContainer = Horz(parent),
		tabBtns = {},
		selectedTab = nil,
		tabContents = nil
	};

	tabData.tabClicked = function(label, main)
		if tabData.selectedTab then
			tabData.tabBtns[tabData.selectedTab].SetInteractable(true);
		end

		tabData.selectedTab = label;
		tabData.tabBtns[label].SetInteractable(false);

		if not UI.IsDestroyed(tabData.tabContents) then
			UI.Destroy(tabData.tabContents);
		end

		tabData.tabContents = Vert(parent);

		main(tabData);
	end

	for i, label in ipairs(tabLabels) do
		local tabBtn = Btn(tabData.tabsContainer).SetText(label);
		tabBtn.SetOnClick(function() 
			tabData.tabClicked(label, tabsClicked[i]);
		end);

		tabData.tabBtns[label] = tabBtn;
	end

	return tabData;
end

function Table(parent)
	local tbl = {
		containers = {
			tbl = Vert(parent),
			rows = {},
			cols = {}
		},
		data = {}
	};

	function Td(rowNo, colNo, data)
		if not tbl.containers.rows[rowNo] then
			tbl.containers.rows[rowNo] = Horz(tbl.containers.tbl);
		end

		if not tbl.containers.cols[colNo] then
			tbl.containers.cols[colNo] = Vert(tbl.containers.rows[rowNo]);
			tbl.data[colNo] = {};
		end

		if not UI.IsDestroyed(tbl.data[colNo][rowNo]) then
			UI.Destroy(tbl.data[colNo][rowNo]);
		end

		if type(data) == 'string' or type(data) == 'number' then
			data = {
				func = 'CreateLabel',
				txt = data
			};
		end

		local td = UI[data.func](tbl.containers.cols[colNo]).SetText(data.txt);
		tbl.data[colNo][rowNo] = td;

		return td;
	end

	tbl.Td = Td;
	return tbl;
end