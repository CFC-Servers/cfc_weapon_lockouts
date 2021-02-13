net.Receive( "CFC_WeaponLockouts_LockWeapon", function()
    local ply = net.ReadEntity()
    local wep = net.ReadEntity()
    local class = net.ReadString()

    ply.weaponLockouts = ply.weaponLockouts or {}
    ply.weaponLockouts[class] = true

    if IsValid( wep ) then
        wep.weaponLockout_IsLocked = true
    end
end )

net.Receive( "CFC_WeaponLockouts_UnlockWeapon", function()
    local ply = net.ReadEntity()
    local wep = net.ReadEntity()
    local class = net.ReadString()

    ply.weaponLockouts = ply.weaponLockouts or {}
    ply.weaponLockouts[class] = nil

    if IsValid( wep ) then
        wep.weaponLockout_IsLocked = nil
    end
end )
