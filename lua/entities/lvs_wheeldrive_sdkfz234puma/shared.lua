
ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "Sonderkraftfahrzeug" -- "Sd.kfz 234/2"
ENT.Author = "8Z"
ENT.Information = ""
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Armored"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.TurretSeatIndex = 1

ENT.SpawnNormalOffset = 20 -- spawn normal offset, raise to prevent spawning into the ground
--ENT.SpawnNormalOffsetSpawner = 0 -- offset for ai vehicle spawner

ENT.MDL = "models/8z/lvs/sdkfz234puma.mdl"
ENT.MDL_DESTROYED = "models/8z/lvs/sdkfz234puma.mdl"

ENT.TurretFireSound = "lvs/vehicles/sherman/cannon_fire.wav"
ENT.TurretFireSoundInterior = "lvs/vehicles/sherman/cannon_fire.wav"

ENT.AITEAM = 1

ENT.MaxHealth = 1200
ENT.FrontArmor = 2000
ENT.SideArmor = 800
ENT.TurretArmor = 1000
ENT.RearArmor = 0

ENT.DSArmorIgnoreForce = 1000

ENT.MaxVelocity = 950
ENT.EngineCurve = 0.15
ENT.EngineTorque = 150

ENT.TransGears = 6
ENT.TransGearsReverse = 1
ENT.WheelBrakeAutoLockup = false

ENT.FastSteerAngleClamp = 6
ENT.FastSteerDeactivationDriftAngle = 7

ENT.PhysicsWeightScale = 1.25
ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = false

ENT.WheelSideForce = 800
ENT.WheelDownForce = 1000

ENT.TurretBodygroup = 0

ENT.CannonArmorPenetration = 7200

function ENT:OnSetupDataTables()
    self:AddDT( "Entity", "WeaponSeat" )
    self:AddDT( "Entity", "GunnerSeat" )
    self:AddDT( "Entity", "CommanderSeat" )

    self:AddDT( "Bool", "UseHighExplosive" )
end

function ENT:InitWeaponMG()
    local COLOR_WHITE = Color(255,255,255,255)

    local weapon = {}
    weapon.Icon = Material("lvs/weapons/mg.png")
    weapon.Ammo = 1200
    weapon.Delay = 0.1
    weapon.HeatRateUp = 0.25
    weapon.HeatRateDown = 0.3
    weapon.Attack = function( ent )
        local veh = ent:GetVehicle()
        local ID = veh:LookupAttachment( "muzzle_mg" )
        local Muzzle = veh:GetAttachment( ID )
        if not Muzzle then return end

        local spread = Lerp(ent:GetHeat() ^ 0.5, 0.01, 0.018)
        local bullet = {}
        bullet.Src = Muzzle.Pos
        bullet.Dir = Muzzle.Ang:Forward()
        bullet.Spread = Vector(spread,spread,spread)
        bullet.TracerName = "lvs_tracer_yellow"
        bullet.Force = 10
        bullet.HullSize = 0
        bullet.Damage = 25
        bullet.Velocity = 30000
        bullet.Attacker = veh:GetPassenger(gun_seat)
        veh:LVSFireBullet( bullet )

        local effectdata = EffectData()
        effectdata:SetOrigin( bullet.Src )
        effectdata:SetNormal( bullet.Dir )
        effectdata:SetEntity( ent )
        util.Effect( "lvs_muzzle", effectdata )

        ent:TakeAmmo( 1 )
    end
    weapon.StartAttack = function( ent )
        local veh = ent:GetVehicle()
        if not IsValid( veh.SNDTurretMG ) then return end
        veh.SNDTurretMG:Play()
    end
    weapon.FinishAttack = function( ent )
        local veh = ent:GetVehicle()
        if not IsValid( veh.SNDTurretMG ) then return end
        veh.SNDTurretMG:Stop()
    end
    weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
    weapon.HudPaint = function( ent, X, Y, ply )
        local veh = ent:GetVehicle()
        local ID = veh:LookupAttachment( "muzzle_mg" )
        local Muzzle = veh:GetAttachment( ID )

        if Muzzle then
            local traceTurret = util.TraceLine( {
                start = Muzzle.Pos,
                endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 50000,
                filter = veh:GetCrosshairFilterEnts()
            } )

            local MuzzlePos2D = traceTurret.HitPos:ToScreen()

            veh:PaintCrosshairCenter( MuzzlePos2D, COLOR_WHITE )
            veh:LVSPaintHitMarker( MuzzlePos2D )
        end
    end
    weapon.OnOverheat = function( ent )
        local veh = ent:GetVehicle()
        veh:EmitSound("lvs/overheat.wav")
    end
    self:AddWeapon(weapon, self.TurretSeatIndex)
end

-- Also adds the disable turret weapon
function ENT:InitWeaponSmoke()
    local weapon = {}
    weapon.Icon = Material("lvs/weapons/smoke_launcher.png")
    weapon.Ammo = 3
    weapon.Delay = 5
    weapon.HeatRateUp = 1
    weapon.HeatRateDown = 0.2
    weapon.Attack = function( ent )
        local veh = ent:GetVehicle()
        ent:TakeAmmo( 1 )

        local ID1 = veh:LookupAttachment( "smoke_right" )
        local ID2 = veh:LookupAttachment( "smoke_left" )

        local Muzzle1 = veh:GetAttachment( ID1 )
        local Muzzle2 = veh:GetAttachment( ID2 )

        if not Muzzle1 or not Muzzle2 then return end

        veh:EmitSound("lvs/smokegrenade.wav")

        local Up = Muzzle1.Ang:Up()

        local Ang1 = Muzzle1.Ang
        Ang1:RotateAroundAxis( Up, ent:GetAmmo() * -10 )
        local grenade = ents.Create( "lvs_item_smoke" )
        grenade:SetPos( Muzzle1.Pos )
        grenade:SetAngles( Ang1 )
        grenade:Spawn()
        grenade:Activate()
        grenade:GetPhysicsObject():SetVelocity( Ang1:Forward() * 750 + veh:GetVelocity() )

        local Ang2 = Muzzle2.Ang
        Ang2:RotateAroundAxis( Up, ent:GetAmmo() * 10 )
        grenade = ents.Create( "lvs_item_smoke" )
        grenade:SetPos( Muzzle2.Pos )
        grenade:SetAngles( Ang2 )
        grenade:Spawn()
        grenade:Activate()
        grenade:GetPhysicsObject():SetVelocity( Ang2:Forward() * 750 + veh:GetVelocity() )
    end
    self:AddWeapon(weapon, self.TurretSeatIndex)

    weapon = {}
    weapon.Icon = Material("lvs/weapons/tank_noturret.png")
    weapon.Ammo = -1
    weapon.Delay = 0
    weapon.HeatRateUp = 0
    weapon.HeatRateDown = 0
    weapon.OnSelect = function( ent )
        local veh = ent:GetVehicle()
        if veh.SetTurretEnabled then
            veh:SetTurretEnabled( false )
        end
    end
    weapon.OnDeselect = function( ent )
        local veh = ent:GetVehicle()
        if veh.SetTurretEnabled then
            veh:SetTurretEnabled( true )
        end
    end
    self:AddWeapon(weapon, self.TurretSeatIndex)
end


function ENT:InitWeapons()

    local COLOR_WHITE = Color(255,255,255,255)

    if GetConVar("lvs_sdkfz234_turret_driver"):GetBool() then
        self.TurretSeatIndex = 1
    else
        self.TurretSeatIndex = 2
    end

    self:InitWeaponMG()

    weapon = {}
    weapon.Icon = true
    weapon.Ammo = 45
    weapon.Delay = 2.2
    weapon.HeatRateUp = 1
    weapon.HeatRateDown = 0.454545
    weapon.OnThink = function( ent )
        local veh = ent:GetVehicle()
        if ent:GetSelectedWeapon() ~= 2 then return end
        local ply = veh:GetPassenger(self.TurretSeatIndex)

        if not IsValid( ply ) then return end

        local SwitchType = ply:lvsKeyDown( "CAR_SWAP_AMMO" )

        if veh._oldSwitchType ~= SwitchType then
            veh._oldSwitchType = SwitchType

            if SwitchType then
                veh:SetUseHighExplosive( not veh:GetUseHighExplosive() )
                veh:EmitSound("lvs/vehicles/sherman/cannon_unload.wav", 75, 100, 1, CHAN_WEAPON )
                ent:SetHeat( 1 )
                ent:SetOverheated( true )
            end
        end
    end
    weapon.Attack = function( ent )
        local veh = ent:GetVehicle()
        local ID = veh:LookupAttachment( "muzzle_turret" )
        local Muzzle = veh:GetAttachment( ID )

        if not Muzzle then return end

        local bullet = {}
        bullet.Src 	= Muzzle.Pos
        bullet.Dir 	= Muzzle.Ang:Forward()
        bullet.Spread = Vector(0,0,0)

        if veh:GetUseHighExplosive() then
            bullet.Force	= 500
            bullet.HullSize = 15
            bullet.Damage	= 200
            bullet.SplashDamage = 400
            bullet.SplashDamageRadius = 200
            bullet.SplashDamageEffect = "lvs_bullet_impact_explosive"
            bullet.SplashDamageType = DMG_BLAST
            bullet.Velocity = 12000
        else
            bullet.Force	= veh.CannonArmorPenetration
            bullet.HullSize 	= 0
            bullet.Damage	= 700
            bullet.Velocity = 18000
        end

        bullet.TracerName = "lvs_tracer_cannon"
        bullet.Attacker 	= veh:GetPassenger(self.TurretSeatIndex)
        veh:LVSFireBullet( bullet )

        local effectdata = EffectData()
        effectdata:SetOrigin( bullet.Src )
        effectdata:SetNormal( bullet.Dir )
        effectdata:SetEntity( veh )
        util.Effect( "lvs_muzzle", effectdata )

        local PhysObj = veh:GetPhysicsObject()
        if IsValid( PhysObj ) then
            PhysObj:ApplyForceOffset( -bullet.Dir * 90000, bullet.Src )
        end
        ent:TakeAmmo(1)
        -- veh:PlayAnimation( "turret_fire" )

        if not IsValid( veh.SNDTurret ) then return end
        veh.SNDTurret:PlayOnce( 105 + math.cos( CurTime() + veh:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
        veh:EmitSound("lvs/vehicles/sherman/cannon_reload.wav", 75, 120, 1, CHAN_WEAPON )
    end
    weapon.HudPaint = function( ent, X, Y, ply )
        local veh = ent:GetVehicle()
        local ID = veh:LookupAttachment("muzzle_turret")
        local Muzzle = veh:GetAttachment( ID )

        if Muzzle then
            local traceTurret = util.TraceLine( {
                start = Muzzle.Pos,
                endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 50000,
                filter = veh:GetCrosshairFilterEnts()
            } )

            local MuzzlePos2D = traceTurret.HitPos:ToScreen()

            if veh:GetUseHighExplosive() then
                veh:PaintCrosshairSquare( MuzzlePos2D, COLOR_WHITE )
            else
                veh:PaintCrosshairOuter( MuzzlePos2D, COLOR_WHITE )
            end

            veh:LVSPaintHitMarker( MuzzlePos2D )
        end
    end
    self:AddWeapon(weapon, self.TurretSeatIndex)

    self:InitWeaponSmoke()
end

--[[ engine sounds ]]
ENT.EngineSounds = {
    {
        sound = "lvs/vehicles/222/eng_idle_loop.wav",
        Volume = 0.5,
        Pitch = 85,
        PitchMul = 25,
        SoundLevel = 75,
        SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
    },
    {
        sound = "lvs/vehicles/222/eng_loop.wav",
        Volume = 1,
        Pitch = 70,
        PitchMul = 100,
        SoundLevel = 75,
        UseDoppler = true,
    },
}


--[[ exhaust ]]
ENT.ExhaustPositions = {
    {
        pos = Vector(44, -115, 32),
        ang = Angle(-45,0,0),
    },
    {
        pos = Vector(-44, -115, 32),
        ang = Angle(180 + 45,0,0),
    },
}

ENT.RandomColor = {
    {
        Skin = 0,
        Color = Color(255,255,255),
    },
    {
        Skin = 1,
        Color = Color(255,255,255),
        Wheels = {
            Skin = 1,
            Color = Color(255,255,255),
        },
    },
}

--[[ lights ]]
ENT.Lights = {
    {
        Trigger = "main+high",
        -- SubMaterialID = 1,
        Sprites = {
            [1] = {
                pos = Vector(-37, 108, 30),
                colorB = 200,
                colorA = 150,
            },
            [2] = {
                pos = Vector(37, 108, 30),
                colorB = 200,
                colorA = 150,
            },
        },
        ProjectedTextures = {
            [1] = {
                pos = Vector(-37, 108, 30),
                ang = Angle(0, 90, 0),
                colorB = 200,
                colorA = 150,
                shadows = true,
            },
            [2] = {
                pos = Vector(37, 108, 30),
                ang = Angle(0, 90, 0),
                colorB = 200,
                colorA = 150,
                shadows = true,
            },
        },
    },
}