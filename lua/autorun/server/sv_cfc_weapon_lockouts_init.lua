local function addFiles( dir )
    local files, dirs = file.Find( dir .. "/*", "LUA" )
    if not files then return end
    for k, v in pairs( files ) do
        if string.match( v, "^.+%.lua$" ) then
            AddCSLuaFile( dir .. "/" .. v )
        end
    end
    for k, v in pairs( dirs ) do
        addFiles( dir .. "/" .. v )
    end
end

addFiles( "cfc_weapon_lockouts/client" )
addFiles( "cfc_weapon_lockouts/shared" )

include( "cfc_weapon_lockouts/shared/sh_base.lua" )
