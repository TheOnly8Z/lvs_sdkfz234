include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

function ENT:TankViewOverride( ply, pos, angles, fov, pod )
    if pod == self:GetWeaponSeat() and not pod:GetThirdPersonMode() then
        local ID = self:LookupAttachment( "viewport_gunner" )
        local Muzzle = self:GetAttachment( ID )
        if Muzzle then
            pos = Muzzle.Pos + Muzzle.Ang:Up() * 0.5
            -- pos = Muzzle.Pos - Muzzle.Ang:Forward() * 85 + Muzzle.Ang:Up() * 8 + Muzzle.Ang:Right() * 16
        end
    end

    return pos, angles, fov
end

function ENT:CalcViewDriver( ply, pos, angles, fov, pod )
    if pod ~= self:GetWeaponSeat() and not pod:GetThirdPersonMode() then
        local ID = self:LookupAttachment( "viewport_driver" )
        local Muzzle = self:GetAttachment( ID )
        if Muzzle then
            pos = Muzzle.Pos + Muzzle.Ang:Right() * -6
        end
    end

    if ply:lvsMouseAim() then
        angles = ply:EyeAngles()
        return self:CalcViewMouseAim( ply, pos, angles,  fov, pod )
    else
        return self:CalcViewDirectInput( ply, pos, angles,  fov, pod )
    end
end

function ENT:CalcViewPassenger(ply, pos, angles, fov, pod)
    if pod == self:GetCommanderSeat() then
        local ID = self:LookupAttachment("viewport_commander")
        local Muzzle = self:GetAttachment(ID)
        if Muzzle then
            pos = Muzzle.Pos + Muzzle.Ang:Up() * 4
        end
    elseif pod == self:GetGunnerSeat() and pod ~= self:GetWeaponSeat() then
        local ID = self:LookupAttachment("viewport_gunner")
        local Muzzle = self:GetAttachment(ID)

        if Muzzle then
            pos = Muzzle.Pos + Muzzle.Ang:Up() * 4
        end
    elseif not pod:GetThirdPersonMode() then
        angles = pod:LocalToWorldAngles( ply:EyeAngles() )
    end

    return self:CalcTankView( ply, pos, angles, fov, pod )
end