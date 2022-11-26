-- shorthand function names

function Vert(parent)
	return UI.CreateVerticalLayoutGroup(parent);
end

function Horz(parent)
	return UI.CreateHorizontalLayoutGroup(parent);
end

Tabs = {
	create = function(parent, tabLabels, tabsClicked)
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
			local tabBtn = UI.CreateButton(tabData.tabsContainer).SetText(label);
			tabBtn.SetOnClick(function() 
				tabData.tabClicked(label, tabsClicked[i]);
			end);

			tabData.tabBtns[label] = tabBtn;
		end

		return tabData;
	end
}