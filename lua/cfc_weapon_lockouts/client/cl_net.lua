net.Receive( "CFC_WeaponLockouts_LockWeapon", function()
    local data = net.ReadTable()

    data.ply.weaponLockouts = data.ply.weaponLockouts or {}
    data.ply.weaponLockouts[data.class] = true
    data.wep.weaponLockoutIsLocked = true
end )

net.Receive( "CFC_WeaponLockouts_UnlockWeapon", function()
    local data = net.ReadTable()

    data.ply.weaponLockouts = data.ply.weaponLockouts or {}
    data.ply.weaponLockouts[data.class] = nil
    data.wep.weaponLockoutIsLocked = nil
end )
