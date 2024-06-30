include("shared.lua")
include("sh_turret.lua")
include("cl_tankview.lua")
include("cl_optics.lua")

local switch = Material("lvs/weapons/change_ammo.png")
local AP = Material("lvs/weapons/bullet_ap.png")
local HE = Material("lvs/weapons/tank_cannon.png")
function ENT:DrawWeaponIcon( PodID, ID, x, y, width, height, IsSelected, IconColor )
    local Icon = self:GetUseHighExplosive() and HE or AP

    surface.SetMaterial( Icon )
    surface.DrawTexturedRect( x, y, width, height )

    local ply = LocalPlayer()

    if not IsValid( ply ) or ID ~= 2 or not IsSelected then return end

    surface.SetMaterial( switch )
    surface.DrawTexturedRect( x + width + 5, y + 7, 24, 24 )

    local buttonCode = ply:lvsGetControls()[ "CAR_SWAP_AMMO" ]

    if not buttonCode then return end

    local KeyName = input.GetKeyName( buttonCode )

    if not KeyName then return end

    draw.DrawText( KeyName, "DermaDefault", x + width + 17, y + height * 0.5 + 7, Color(0,0,0,IconColor.a), TEXT_ALIGN_CENTER )
end


function ENT:OnSpawn( PObj )
    self:SetTurretYaw(self.TurretYawOffset + 180) -- ??

    if GetConVar("lvs_sdkfz234_turret_driver"):GetBool() then
        self.TurretSeatIndex = 1
    else
        self.TurretSeatIndex = 2
    end

    self.OpticsPodIndex[self.TurretSeatIndex] = true
end