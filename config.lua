Config = {}
Config.Locale = 'ru' -- (ru or en) Change Lang, You must add the language file to the locales folder
Config.LicenseName = 'aircraft' --You must change the name of the pilot's license
Config.CheckLicense = true --Enable or disable license verification TRUE / FALSE
Config.CheckTimer = 10000 -- Timer check 10 sec, 10 seconds is a great time, it just doesn’t make sense to set it lower, the load is minimal
Config.PlaneModel = 'lazer' -- Name plane interceptor Hydra, Lazer, and etc
Config.HelicopterModel = 'buzzard' -- Exemple: Name helicopter interceptor buzzard
Config.Wanted = true -- If wanted is enabled on your server, add star wanted player
Config.WhiteListZone = { --https://docs.fivem.net/natives/?_0xCD90657D4C30E1CA NAME ZONE
    "AIRP",
    "ISHEIST"
}
Config.SpawnHelicopter = { x = -1903.25, y = 2933.94, z = 32.81 }--Spawn Military Heli
Config.job = {"police","ambulance"}--Whitlelist JOB