include("entities/lvs_tank_wheeldrive/modules/sh_turret.lua")

ENT.TurretAimRate = 25

ENT.TurretFakeBarrel = false
ENT.TurretFakeBarrelRotationCenter = Vector(0, -9.4, 60)

ENT.TurretRotationSound = "vehicles/tank_turret_loop1.wav"

ENT.TurretPitchPoseParameterName = "turret_pitch"
ENT.TurretPitchMin = -10
ENT.TurretPitchMax = 10
ENT.TurretPitchMul = -1
ENT.TurretPitchOffset = 0

ENT.TurretYawPoseParameterName = "turret_yaw"
ENT.TurretYawMul = 1
ENT.TurretYawOffset = -90

if CLIENT then
    function ENT:CalcTurret()
        local pod = self:GetWeaponSeat()
        if not IsValid( pod ) then return end

        local plyL = LocalPlayer()
        local ply = pod:GetDriver()

        if ply ~= plyL then return end

        self:AimTurret()
    end
end

function ENT:IsTurretEnabled()
    if self:GetHP() <= 0 then return false end

    if not self:GetTurretEnabled() then return false end

    return IsValid(self:GetPassenger(self.TurretSeatIndex)) or self:GetAI()
end

function ENT:GetEyeTrace(trace_forward)
    local startpos = self:LocalToWorld(self:OBBCenter())
    local pod = self:GetWeaponSeat()

    if IsValid(pod) then
        startpos = pod:LocalToWorld(pod:OBBCenter())
    end

    local AimVector = trace_forward and self:GetForward() or self:GetAimVector()

    local data = {
        start = startpos,
        endpos = startpos + AimVector * 50000,
        filter = self:GetCrosshairFilterEnts(),
    }

    local trace = util.TraceLine(data)

    return trace
end

function ENT:GetAimVector()
    if self:GetAI() then return self:GetAIAimVector() end
    local pod = self:GetWeaponSeat()
    if not IsValid(pod) then return self:GetForward() end
    local Driver = pod:GetDriver()
    if not IsValid(Driver) then return pod:GetForward() end

    if Driver:lvsMouseAim() then
        if SERVER then
            return pod:WorldToLocalAngles(Driver:EyeAngles()):Forward()
        else
            return Driver:EyeAngles():Forward()
        end
    else
        if SERVER then
            return Driver:EyeAngles():Forward()
        else
            return pod:LocalToWorldAngles(Driver:EyeAngles()):Forward()
        end
    end
end