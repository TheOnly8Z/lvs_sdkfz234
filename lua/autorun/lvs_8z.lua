AddCSLuaFile()

-- This hook should be the same across addons so I don't step over my toes all the time
hook.Add("LVS.PopulateVehicles", "lvs_8z", function(lvsNode, pnlContent, tree)
    local node = lvsNode:AddNode("8Z's Vehicle Settings", "icon16/sport_8ball.png")
    node.DoPopulate = function(self)
        if (self.PropPanel) then return end
        self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
        self.PropPanel:SetVisible( false )
        self.PropPanel:SetTriggerSpawnlistChange( false )
        hook.Run("LVS.8Z.AddVehicleSettings", self.PropPanel, node)
    end
    node.DoClick = function(self)
        self:DoPopulate()
        pnlContent:SwitchPanel(self.PropPanel)
    end
end)