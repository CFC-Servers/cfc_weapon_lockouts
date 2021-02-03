net.Receive( "CFC_WeaponLockouts_LockWeapon", function()
    local data = net.ReadTable()

    data.ply.weaponLockouts = data.ply.weaponLockouts or {}
    data.ply.weaponLockouts[data.class] = true

    if IsValid( wep ) then
        data.wep.weaponLockout_IsLocked = true
    end
end )

net.Receive( "CFC_WeaponLockouts_UnlockWeapon", function()
    local data = net.ReadTable()

    data.ply.weaponLockouts = data.ply.weaponLockouts or {}
    data.ply.weaponLockouts[data.class] = nil
    
    if IsValid( wep ) then
        data.wep.weaponLockout_IsLocked = nil
    end
end )
