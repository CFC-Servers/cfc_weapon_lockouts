CFCWeaponLockouts = CFCWeaponLockouts or {}
CFCWeaponLockouts._lockWarns = {}

function CFCWeaponLockouts.lockWeapon( ply, wep, lostWeapon )
    if not IsValid( ply ) then return end

    if not wep then -- The caller only knows the weapon, and not the player, such as during EntityRemoved
        wep = ply
        ply = wep.weaponLockoutOwner

        if not IsValid( ply ) then return end
    end

    local weaponIsValid = IsValid( wep ) and wep:IsWeapon()
    local playerIsValid = ply:Alive()
    local weaponIsLockable = CFCWeaponLockouts.NOT_LOCKABLE[wep:GetClass()] == nil
    local canLock = weaponIsValid and playerIsValid and weaponIsLockable

    if not canLock then return end

    ply.weaponLockouts = ply.weaponLockouts or {}
    local lockouts = ply.weaponLockouts
    local weaponClass = wep:GetClass()

    -- If the caller thinks the weapon was lost, or if they are unsure and it was lost
    if lostWeapon or ( lostWeapon == nil and not ply:HasWeapon( weaponClass ) ) then
        ply.weaponLockoutWeapons = ply.weaponLockoutWeapons or {}
        ply.weaponLockoutWeapons[weaponClass] = nil
    end

    lockouts[weaponClass] = true
    wep.weaponLockoutIsLocked = true

    net.Start( "CFC_WeaponLockouts_LockWeapon" )
    net.WriteTable( {
        ply = ply,
        wep = wep,
        class = weaponClass
    } )
    net.Broadcast()

    local timerName = "CFC_WeaponLockouts_Unlock_" .. ply:SteamID() .. "_" .. weaponClass
    local timerDuration = CFCWeaponLockouts.LOCKOUT_TIME:GetFloat()

    timer.Create( timerName, timerDuration, 1, function()
        if not IsValid( ply ) then return end

        lockouts[weaponClass] = nil
        wep.weaponLockoutIsLocked = nil

        net.Start( "CFC_WeaponLockouts_UnlockWeapon" )
        net.WriteTable( {
            ply = ply,
            wep = wep,
            class = weaponClass
        } )
        net.Broadcast()
    end )
end

local function updateLockStatus( ply, wep, weaponClass )
    local plyWeapons = ply.weaponLockoutWeapons
    local isLocked = CFCWeaponLockouts.weaponIsLocked( ply, weaponClass )

    -- In certain cases, EntityRemoved gets called after WeaponEquip, causing odd behavior where the weapon is unlocked, meant to be locked, and not held by the player.
    -- Manually keeping track of the weapon classes held by a player allows us to catch that error.
    if not isLocked and plyWeapons[weaponClass] and not CFCWeaponLockouts.NOT_LOCKABLE[weaponClass] then
        isLocked = true
        CFCWeaponLockouts.lockWeapon( ply, wep, false )
    end

    plyWeapons[weaponClass] = true

    if not isLocked then
        local unlockedCount = CFCWeaponLockouts._lockWarns[ply].unlockedCount or 0

        CFCWeaponLockouts._lockWarns[ply][weaponClass] = "unlocked"
        CFCWeaponLockouts._lockWarns[ply].unlockedCount = unlockedCount + 1

        return false
    end

    return true
end

local function removeAmmo( ply, wep )
    local primaryAmmoType = wep:GetPrimaryAmmoType()
    local secondaryAmmoType = wep:GetSecondaryAmmoType()
    local primaryAmmo = ply:GetAmmoCount( primaryAmmoType ) or 0
    local secondaryAmmo = ply:GetAmmoCount( secondaryAmmoType ) or 0
    local clip1 = math.min( wep:Clip1() or 0, wep:GetMaxClip1() or 0 )
    local clip2 = math.min( wep:Clip2() or 0, wep:GetMaxClip2() or 0 )

    -- Empties ammo and clips from the locked weapon
    timer.Simple( 0, function()
        if not IsValid( wep ) then return end
        if primaryAmmo > 0 then ply:SetAmmo( 0, primaryAmmoType ) end
        if secondaryAmmo > 0 then ply:SetAmmo( 0, secondaryAmmoType ) end
        if clip1 > 0 then wep:SetClip1( 0 ) end
        if clip2 > 0 then wep:SetClip2( 0 ) end
    end )

    -- Returns ammo and clips to the weapon
    timer.Simple( CFCWeaponLockouts.LOCKOUT_TIME:GetFloat(), function()
        if not IsValid( wep ) then return end
        if primaryAmmo > 0 then ply:SetAmmo( primaryAmmo, primaryAmmoType ) end
        if secondaryAmmo > 0 then ply:SetAmmo( secondaryAmmo, secondaryAmmoType ) end
        if clip1 > 0 then wep:SetClip1( clip1 ) end
        if clip2 > 0 then wep:SetClip2( clip2 ) end
    end )
end

local function warnPlayer( identifier, ply, warns )
    if not IsValid( ply ) or table.IsEmpty( warns ) then return end

    local lockedCount = warns.lockedCount or 0
    local unlockedCount = warns.unlockedCount or 0

    if lockedCount <= 0 then return end

    local msg = "temporarily locked! You will be able to fire"
    local lineLength = 0
    local maxLength = 50
    local maxAppend = "and more"

    if CFCNotifications then
        msg = "temporarily locked!\nYou will be able to fire"
        maxLength = 100
    end

    if unlockedCount > 0 then
        if lockedCount > 1 then
            local append = "They are "
            lineLength = lineLength + append:len()
            msg = "Some of those weapons are " .. msg .. " them after a brief moment.\n" .. append
        else
            local append = "It is "
            lineLength = lineLength + append:len()
            msg = "One of those weapons is " .. msg .. " it after a brief moment.\n" .. append
        end
    else
        if lockedCount > 1 then
            local append = "They are "
            lineLength = lineLength + append:len()
            msg = "Those weapons are " .. msg .. " them after a brief moment.\n" .. append
        else
            local append = "It is "
            lineLength = lineLength + append:len()
            msg = "That weapon is " .. msg .. " it after a brief moment.\n" .. append
        end
    end

    for class, status in pairs( warns ) do
        if status == "locked" then
            local newLength = lineLength + class:len()

            if newLength <= maxLength then
                if newLength + maxAppend:len() < maxLength then
                    msg = msg .. class .. " "
                    lineLength = newLength + 1
                else
                    msg = msg .. maxAppend
                    break
                end
            else
                msg = msg .. maxAppend
                break
            end
        end
    end

    if CFCNotifications then
        CFCNotifications.new( identifier, "Text", true )
        local notif = CFCNotifications.get( identifier )

        notif:SetTitle( "CFC WeaponLockouts" )
        notif:SetText( msg )
        notif:SetTextColor( color_white )
        notif:SetDisplayTime( CFCWeaponLockouts.LOCKOUT_TIME:GetFloat() - CFCWeaponLockouts.WARN_BUILDUP:GetFloat() )
        notif:SetPriority( CFCNotifications.PRIORITY_LOW )
        notif:SetCloseable( true )
        notif:SetIgnoreable( true )
        notif:SetTimed( true )

        notif:Send( ply )
    else
        ply:ChatPrint( msg )
    end

    CFCWeaponLockouts._lockWarns[ply] = {}
end

hook.Add( "PlayerSpawn", "CFC_WeaponLockouts_UnlockOnSpawn", function( ply )
    ply.weaponLockouts = {}
    ply.weaponLockoutWeapons = {}
    CFCWeaponLockouts._lockWarns[ply] = {}

    -- Clear out warn info from weapons spawned by default
    timer.Create( "CFC_WeaponLockouts_LockWarn_" .. ply:SteamID(), 0, 1, function()
        CFCWeaponLockouts._lockWarns[ply] = {}
    end )
end )

hook.Add( "PlayerDroppedWeapon", "CFC_WeaponLockouts_LockWeapon", function( ply, wep )
    CFCWeaponLockouts.lockWeapon( ply, wep, true )
end )

hook.Add( "EntityRemoved", "CFC_WeaponLockouts_LockWeapon", function( ent )
    if not IsValid( ent ) or not ent:IsWeapon() then return end

    CFCWeaponLockouts.lockWeapon( ent )
end )

hook.Add( "PlayerSwitchWeapon", "CFC_WeaponLockouts_TrackWeaponOwner", function( ply, old, new )
    if not IsValid( new ) then return end

    new.weaponLockoutOwner = ply
end )

hook.Add( "WeaponEquip", "CFC_WeaponLockouts_CanPickup", function( wep, ply )
    if not IsValid( wep ) or not IsValid( ply ) then return end

    local weaponClass = wep:GetClass()
    ply.weaponLockoutWeapons = ply.weaponLockoutWeapons or {}
    wep.weaponLockoutOwner = ply

    if not updateLockStatus( ply, wep, weaponClass ) then return end

    -- Warn player if their weapon is locked, and update warn info
    local identifier = "CFC_WeaponLockouts_LockWarn_" .. ply:SteamID()
    local warns = CFCWeaponLockouts._lockWarns[ply] or {}
    warns[weaponClass] = "locked"
    warns.lockedCount = ( warns.lockedCount or 0 ) + 1

    timer.Create( identifier, CFCWeaponLockouts.WARN_BUILDUP:GetFloat(), 1, function()
        warnPlayer( identifier, ply, warns )
    end )

    removeAmmo( ply, wep )
end )
