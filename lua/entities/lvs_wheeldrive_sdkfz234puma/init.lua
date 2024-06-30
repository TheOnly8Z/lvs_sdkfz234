AddCSLuaFile("shared.lua")
include("shared.lua")

AddCSLuaFile("sh_turret.lua")
include("sh_turret.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_tankview.lua")
AddCSLuaFile("cl_optics.lua")

function ENT:OnTick()
    self:AimTurret()
end

function ENT:OnSpawn( PObj )

    if GetConVar("lvs_sdkfz234_turret_driver"):GetBool() then
        self.TurretSeatIndex = 1
    else
        self.TurretSeatIndex = 2
    end

    self:SetTurretYaw(self.TurretYawOffset + 180) -- ??

    local DriverSeat = self:AddDriverSeat( Vector(0,20,23), Angle(0,0,0) )
    DriverSeat.HidePlayer = true
    local GunnerSeat = self:AddPassengerSeat( Vector(18,-9,40), Angle(0,0,0) )
    GunnerSeat.HidePlayer = true
    self:SetGunnerSeat( GunnerSeat )

    local CommanderSeat = self:AddPassengerSeat( Vector(-18,-12,40), Angle(0,0,0) )
    CommanderSeat.HidePlayer = true
    self:SetCommanderSeat( CommanderSeat )

    if self.TurretSeatIndex == 1 then
        self:SetWeaponSeat( DriverSeat )
    elseif self.TurretSeatIndex == 2 then
        self:SetWeaponSeat( GunnerSeat )
    elseif self.TurretSeatIndex == 3 then
        self:SetWeaponSeat( CommanderSeat )
    end

    local ID = self:LookupAttachment( "muzzle_mg" )
    local Muzzle = self:GetAttachment( ID )
    self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
    self.SNDTurretMG:SetSoundLevel( 95 )
    self.SNDTurretMG:SetParent( self, ID )

    ID = self:LookupAttachment( "muzzle_turret" )
    Muzzle = self:GetAttachment( ID )
    self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), self.TurretFireSound, self.TurretFireSoundInterior )
    self.SNDTurret:SetSoundLevel( 95 )
    self.SNDTurret:SetParent( self, ID )

    self:AddEngine( Vector(0,-70,30) )

    local WheelModel = "models/8z/lvs/sdkfz234puma_wheel.mdl"

    local suspension = {
        Height = 5,
        MaxTravel = 9,
        ControlArmLength = 250,
        SpringConstant = 25000,
        SpringDamping = 3000,
        SpringRelativeDamping = 3000,
    }

    -- Front
    self.FrontAxle = self:DefineAxle( {
        Axle = {
            ForwardAngle = Angle(0,90,0),
            SteerType = LVS.WHEEL_STEER_FRONT,
            SteerAngle = 30,
            TorqueFactor = 0.4,
            BrakeFactor = 1,
            UseHandbrake = false,
        },
        Wheels = {
            self:AddWheel( {
                pos = Vector(-35,75,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,180,0),
            } ),

            self:AddWheel( {
                pos = Vector(35,75,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,0,0),
            } ),
        },
        Suspension = suspension,
    } )

    self.MidAxle1 = self:DefineAxle( {
        Axle = {
            ForwardAngle = Angle(0,90,0),
            SteerType = LVS.WHEEL_STEER_NONE,
            BrakeFactor = 1,
            UseHandbrake = true,
        },
        Wheels = {
            self:AddWheel( {
                pos = Vector(-35,23,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,180,0),
            } ),

            self:AddWheel( {
                pos = Vector(35,23,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,0,0),
            } ),
        },
        Suspension = suspension,
    } )

    self.MidAxle2 = self:DefineAxle( {
        Axle = {
            ForwardAngle = Angle(0,90,0),
            SteerType = LVS.WHEEL_STEER_NONE,
            BrakeFactor = 1,
            UseHandbrake = true,
        },
        Wheels = {
            self:AddWheel( {
                pos = Vector(-35,-32,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,180,0),
            } ),

            self:AddWheel( {
                pos = Vector(35,-32,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,0,0),
            } ),
        },
        Suspension = suspension,
    } )

    -- Rear
    self.RearAxle = self:DefineAxle( {
        Axle = {
            ForwardAngle = Angle(0,90,0),
            SteerType = LVS.WHEEL_STEER_REAR,
            SteerAngle = 5,
            TorqueFactor = 0.6,
            BrakeFactor = 1,
            UseHandbrake = true,
        },
        Wheels = {
            self:AddWheel( {
                pos = Vector(-32,-84,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,180,0),
            } ),

            self:AddWheel( {
                pos = Vector(32,-84,7.5),
                mdl = WheelModel,
                mdl_ang = Angle(0,0,0),
            } ),
        },
        Suspension = suspension,
    } )

    self:AddFuelTank( Vector(0,-70,30), Angle(0,0,0), 700, LVS.FUELTYPE_PETROL, Vector(-12,-24,-12),Vector(12,24,12) )

    self:AddAmmoRack( Vector(0,-18,32), Vector(0,-12,64), Angle(0,0,0), Vector(-15,-16,-10),Vector(15,16,10) )

    -- front
    self:AddArmor( Vector(0,80,45), Angle(0,0,-25), Vector(-30,-8,-10), Vector(30,35,5), 700, self.FrontArmor )
    self:AddArmor( Vector(0,90,20), Angle(0,0,-60), Vector(-25,-10,-20), Vector(25,10,20), 400, self.FrontArmor )

    self:AddArmor( Vector(0,25,45), Angle(0,0,0), Vector(-35,-50,-15), Vector(35,50,15), 300, self.SideArmor )

    -- side
    self:AddArmor( Vector(-37,0,35), Angle(0,0,0), Vector(-10,-100,-15), Vector(10,90,15), 300, self.SideArmor )
    self:AddArmor( Vector(37,0,35), Angle(0,0,0), Vector(-10,-100,-15), Vector(10,90,15), 300, self.SideArmor )

    -- -- left
    -- self:AddArmor( Vector(-32,0,20), Angle(0,-15,0), Vector(-5,-20,-5), Vector(15,30,40), 300, self.SideArmor )
    -- self:AddArmor( Vector(-37,-38,20), Angle(0,0,0), Vector(-5,-45,-5), Vector(15,20,40), 300, self.SideArmor )

    -- -- right
    -- self:AddArmor( Vector(32,0,20), Angle(0,15,0), Vector(-15,-20,-5), Vector(5,30,40), 300, self.SideArmor )
    -- self:AddArmor( Vector(37,-38,20), Angle(0,0,0), Vector(-15,-45,-5), Vector(5,20,40), 300, self.SideArmor )

    -- -- rear
    -- self:AddArmor( Vector(0, -73, 20), Angle(0,0,0), Vector(-21.5,-10,-5), Vector(21.5,5,30), 200, self.RearArmor )
    -- self:AddArmor( Vector(0, -70, 48), Angle(0,0,17.5), Vector(-21.5,-5,-5), Vector(21.5,25,5), 200, self.RearArmor )

    -- turret
    local TurretArmor = self:AddArmor( Vector(0,25,70), Angle(0,0,0), Vector(-30,-30,-10), Vector(30,30,10), 700, self.TurretArmor )
    TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
    TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
    TurretArmor:SetLabel( "Turret" )
    self:SetTurretArmor( TurretArmor )

    self:AddTrailerHitch( Vector(0,-120,16), LVS.HITCHTYPE_MALE )
end

function ENT:OnDestroyed()
    self:CreateWheelWreck()
end

function ENT:CreateWheelWreck()
    for _, wheel in pairs(self:GetWheels()) do
        local ent = ents.Create( "prop_physics" )
        if not IsValid( ent ) then return end

        ent:SetPos( wheel:GetPos() )
        ent:SetAngles( wheel:GetAngles() )
        ent:SetModel( wheel:GetModel() )
        ent:Spawn()
        ent:Activate()
        -- ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD) -- self:GetCollisionGroup()
        ent:SetSkin(wheel:GetSkin() == 0 and 2 or wheel:GetSkin())
        ent:SetColor(wheel:GetColor())

        local PhysObj = ent:GetPhysicsObject()
        if IsValid( PhysObj ) then
            PhysObj:SetVelocityInstantaneous( wheel:GetAlignmentAngle():Forward() * math.Rand(100, 300) + Vector(0, 0, math.Rand(0, 200)) + self:GetVelocity() )
            PhysObj:AddAngleVelocity(VectorRand() * 500)
            -- PhysObj:EnableDrag(false)

            local effectdata = EffectData()
                effectdata:SetOrigin( self:GetPos() )
                effectdata:SetStart( PhysObj:GetMassCenter() )
                effectdata:SetEntity( ent )
                effectdata:SetScale( math.Rand(0.1,0.3) )
                effectdata:SetMagnitude( math.Rand(1,3) )
            util.Effect( "lvs_firetrail", effectdata )
        end

        timer.Simple( 15 + math.Rand(0, 1), function()
            if not IsValid( ent ) then return end
            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
            ent:SetRenderFX( kRenderFxFadeFast )
            SafeRemoveEntityDelayed(ent, 3)
        end)
    end
end

function ENT:AddAmmoRack( pos, fxpos, ang, mins, maxs )
    local AmmoRack = ents.Create( "lvs_wheeldrive_ammorack" )

    if not IsValid( AmmoRack ) then
        self:Remove()

        print("LVS: Failed to create fueltank entity. Vehicle terminated.")

        return
    end

    AmmoRack:SetPos( self:LocalToWorld( pos ) )
    AmmoRack:SetAngles( self:GetAngles() )
    AmmoRack:Spawn()
    AmmoRack:Activate()
    AmmoRack:SetParent( self )
    AmmoRack:SetBase( self )
    AmmoRack:SetEffectPosition( fxpos )

    self:DeleteOnRemove( AmmoRack )

    self:TransferCPPI( AmmoRack )

    mins = mins or Vector(-30,-30,-30)
    maxs = maxs or Vector(30,30,30)

    debugoverlay.BoxAngles( self:LocalToWorld( pos ), mins, maxs, self:LocalToWorldAngles( ang ), 15, Color( 255, 0, 0, 255 ) )

    self:AddDS( {
        pos = pos,
        ang = ang,
        mins = mins,
        maxs =  maxs,
        Callback = function( tbl, ent, dmginfo )
            if not IsValid( AmmoRack ) then return end

            AmmoRack:TakeTransmittedDamage( dmginfo )

            if AmmoRack:GetDestroyed() then return end

            local OriginalDamage = dmginfo:GetDamage()

            dmginfo:SetDamage( math.min( 2, OriginalDamage ) )
        end
    } )

    return AmmoRack
end