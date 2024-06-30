AddCSLuaFile()

CreateConVar("lvs_sdkfz234_turret_driver", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE, "[Sd.Kfz. 234] Enable to give turret and weapon controls to the driver instead of the gunner.", 0, 1)

hook.Add("LVS.8Z.AddVehicleSettings", "lvs_eland", function(panel, node)
    local label = vgui.Create("ContentHeader", panel)
    label:SetText("Sd.Kfz. 234")
    panel:Add(label)

    local turret_driver = vgui.Create("DCheckBoxLabel", panel)
    turret_driver:SetText("Driver Controls Turret")
    turret_driver:SetConVar("lvs_sdkfz234_turret_driver")
    turret_driver:SizeToContents()
    turret_driver:SetTextColor(color_white)
    panel:Add(turret_driver)
end)