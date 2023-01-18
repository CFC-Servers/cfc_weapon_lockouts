local IsValid = IsValid
local CurTime = CurTime
local ACT_VM_RELOAD = ACT_VM_RELOAD

local function setLockoutDuration( wep )
    local reload = wep:SelectWeightedSequence( ACT_VM_RELOAD )
    wep.CFC_LockoutTime = wep:SequenceDuration( reload )
end

hook.Add( "WeaponEquip", "CFC_WeaponLockouts", function( wep, ply )
    local wepClass = wep:GetClass()

    -- Sequence information and SetNextPrimaryFire are not available until the next frame
    timer.Simple( 0, function()
        if not IsValid( wep ) then return end
        if not IsValid( ply ) then return end

        setLockoutDuration( wep )

        local nextFire = ply.WeaponLockouts[wepClass]
        if not nextFire then return end

        wep:SetNextPrimaryFire( nextFire )
    end )
end )


hook.Add( "PlayerDroppedWeapon", "CFC_WeaponLockouts", function( ply, wep )
    if not IsValid( wep ) then return end
    if not IsValid( ply ) then return end

    local wepClass = wep:GetClass()
    local lockout = wep.CFC_LockoutTime
    ply.WeaponLockouts[wepClass] = CurTime() + lockout
end )


hook.Add( "PlayerSpawn", "CFC_WeaponLockouts", function( ply )
    ply.WeaponLockouts = {}
end )
