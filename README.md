# cfc_weapon_lockouts
Temporarily denies the use of specific weapons

## Overview
WeaponLockouts adds the ability to deny a player from firing weapons on a per-class basis for a certain amount of time.  
It uses this to prevent players from ignoring reload animations by dropping and respawning weapons, but it can also be used to lock any weapon at any time.  
Players get alerted about their locked weapons once they pick up a weapon that is locked, or right away if they already have the weapon when it gets locked.  
If the server also has [CFC Notifications](https://github.com/CFC-Servers/cfc_notifications/ "CFC Notifications") then this will automatically utilize it, replacing lockout chat warnings with timed, interactive popups.  

## Usage
If you simply want to prevent players from skipping reload animations, applying this addon to the server and tweaking the list of lockable weapons in `sh_base.lua` is all that's required.  
Otherwise, these functions are available for use:

- `CFCWeaponLockouts.lockByClass( player, weaponClass, duration )`
Temporarily locks a weapon class for a player.
  - `player` - The player to lock a weapon class for.
  - `weaponClass` - The weapon class to deny usage of.
  - `duration` - Time in seconds to lock the weapon for. Defaults to `cfc_weaponlockouts_lockout_time`.

- `CFCWeaponLockouts.lockByWeapon( player, weapon, duration )`
Temporarily locks a weapon class for a player.
  - `player` - The player to lock a weapon class for.
  - `weapon` - The class of this weapon will be locked.
  - `duration` - Time in seconds to lock the weapon for. Defaults to `cfc_weaponlockouts_lockout_time`.

- `CFCWeaponLockouts.lockByWeapon( nil, weapon, duration )`
Temporarily locks a weapon class for the owner of a weapon. Useful for if you know the weapon, but not the player, as weapon ownership has to be tracked manually.
  - `weapon` - The player with this weapon equipped will have this weapon's class become locked.
  - `duration` - Time in seconds to lock the weapon for. Defaults to `cfc_weaponlockouts_lockout_time`.

## SVars
- `cfc_weaponlockouts_lockout_time`
How long lockouts last by default, in seconds. Default is `5`.

- `cfc_weaponlockouts_warn_buildup_window`
When a player is about to be alerted of a locked weapon, it will wait this many seconds to allow for additional alerts to stack up, combining together instead of sending a bunch individually. Default is `0.2`.

## Config
- `CFCWeaponLockouts.LOCKABLE`
A list of weapon classes which are lockable. Defined in [sv_base.lua](https://github.com/CFC-Servers/cfc_weapon_lockouts/blob/master/lua/cfc_weapon_lockouts/shared/sv_base.lua "sv_base").
