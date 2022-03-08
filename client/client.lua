local attackVehicle = nil
local HelicopterVeh = nil
local pilotPed,blip = nil
local x,y,z = nil
local Px, Py, Pz = 0
local statusVehicle = false

local current_zone
local blipVehicle = nil


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.CheckTimer) --check 10 seconds
		local playerPed = ESX.PlayerData.ped
		local coords = GetEntityCoords(playerPed, false)
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		Px, Py, Pz = table.unpack(coords)
		current_zone = GetNameOfZone(coords.x, coords.y, coords.z) or nil
		GetZoneFromNameId(zoneName)
		while nametable == nil do
			Citizen.Wait(0)
		end

		if IsEntityInZone(playerPed, "ISHEIST") then

		end

		if Config.WhiteListZone ~= nil or Config.WhiteListZone ~= '' then
			print('Config.WhiteListZone',Config.WhiteListZone)
			for k,v in pairs(Config.WhiteListZone) do
				if IsEntityInZone(playerPed, v) == v then
					print('Zone Fly White List',IsEntityInZone(playerPed, v))
					return false
				else
					return true
				end
			end
		end



		if not statusVehicle then
			if not IsEntityDead(playerPed) and IsPedInAnyVehicle(playerPed, false) and (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed,true)) and IsEntityInAir(vehicle) then
				if GetPedInVehicleSeat(GetVehiclePedIsIn(ESX.PlayerData.ped), -1) == ESX.PlayerData.ped then
					if DoesEntityExist(vehicle) and not IsEntityDead(playerPed) and (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed,true)) and IsEntityInAir(vehicle) then

						if Config.CheckLicense then
							ESX.TriggerServerCallback('esx_interceptor:requestPlayerCars', function(isOwnedVehicle)

								ESX.TriggerServerCallback('esx_license:checkLicense', function(License)

									if not License or not isOwnedVehicle then

										statusVehicle = true

										if Config.Wanted then
											SetPlayerWantedLevel(PlayerId(), 4, false)
											SetPlayerWantedLevelNow(PlayerId(), true)
											SetDispatchCopsForPlayer(PlayerId(), true)
										end

										if IsPedInAnyPlane(playerPed, true) then
											attackVehicle = CreatePlane(Px+250, Py+250, Pz+50)
											while not DoesEntityExist(attackVehicle) do
												Wait(1)
											end
										end

										if IsPedInAnyHeli(playerPed,true) then
											attackVehicle = CreateHelicopterPed(Config.SpawnHelicopter)
											while not DoesEntityExist(attackVehicle) do
												Wait(1)
											end
										end

										pilotPed = CreatePlanePed(attackVehicle)

										while not DoesEntityExist(pilotPed) do
											Wait(1)
										end

										SetPedKeepTask(pilotPed, true)
										SetPedShootRate(pilotPed,  750)

										SetPedAsEnemy(pilotPed,true)
										SetPedMaxHealth(pilotPed, 900)
										SetPedAlertness(pilotPed, 3)
										SetPedCombatRange(pilotPed, 0)
										SetPedCombatMovement(pilotPed, 3)
										SetPedAccuracy(pilotPed, 70)
										TaskPlaneMission(pilotPed, attackVehicle, vehicle, 0, 0.0,0.0,0.0, 6, 0.0, 100.0, 0.0, 2500.0, -1500.0)

										PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
										Wait(2000)
										PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
										Wait(2000)
										PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
										Wait(5000)

									end

								end, GetPlayerServerId(PlayerId()), Config.LicenseName)
							end, GetVehicleNumberPlateText(vehicle))
						else
							ESX.TriggerServerCallback('esx_interceptor:requestPlayerCars', function(isOwnedVehicle)
									if not isOwnedVehicle then
										statusVehicle = true
										if Config.Wanted then
											SetPlayerWantedLevel(PlayerId(), 4, false)
											SetPlayerWantedLevelNow(PlayerId(), true)
											SetDispatchCopsForPlayer(PlayerId(), true)
										end

										if IsPedInAnyPlane(playerPed, true) then
											attackVehicle = CreatePlane(Px+250, Py+250, Pz+50)
										end
										if IsPedInAnyHeli(playerPed,true) then
											attackVehicle = CreateHelicopterPed(Config.SpawnHelicopter)
										end

										while not DoesEntityExist(attackVehicle) do
											Wait(1)
										end
										pilotPed = CreatePlanePed(attackVehicle)

										while not DoesEntityExist(pilotPed) do
											Wait(1)
										end

										SetPedKeepTask(pilotPed, true)
										SetPedShootRate(pilotPed,  750)

										SetPedAsEnemy(pilotPed,true)
										SetPedMaxHealth(pilotPed, 900)
										SetPedAlertness(pilotPed, 3)
										SetPedCombatRange(pilotPed, 0)
										SetPedCombatMovement(pilotPed, 3)
										SetPedAccuracy(pilotPed, 70)
										TaskPlaneMission(pilotPed, attackVehicle, vehicle, 0, 0.0,0.0,0.0, 6, 0.0, 100.0, 0.0, 2500.0, -1500.0)

										PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
										Wait(2000)
										PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
										Wait(2000)
										PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
										Wait(5000)

									end
							end, GetVehicleNumberPlateText(vehicle))
						end
					end

				end
			end
		end


		if statusVehicle then
			if not DoesEntityExist(attackVehicle) or IsEntityDead(pilotPed) or IsEntityDead(playerPed) or not IsEntityInAir(vehicle) then
				statusVehicle = false
				Wait(10000)
				deleteVehicle(attackVehicle, pilotPed)
			end

			if not (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed, true)) or not IsEntityInAir(vehicle) then
				statusVehicle = false
				Wait(10000)
				deleteVehicle(attackVehicle, pilotPed)
			end

		end
	end
end)

--Создаем пилота самолета
function CreatePlanePed(vehicle)
	local model = GetHashKey("s_m_y_pilot_01")
	if DoesEntityExist(vehicle) then
		if IsModelValid(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(1)
			end
			local ped = CreatePedInsideVehicle(vehicle, 26, model, -1, true, false)
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetEntityAsMissionEntity(ped, true, true)
			SetModelAsNoLongerNeeded(model)
			return ped
		end
	end
end

function CreateHelicopterPed(vehicle)
	local model = GetHashKey("s_m_m_marine_01")
	if DoesEntityExist(vehicle) then
		if IsModelValid(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(1)
			end
			pilotPed = CreatePedInsideVehicle(vehicle, 26, model, -1, true, false)

			NetworkRegisterEntityAsNetworked(pilotPed)
			SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(pilotPed), true)
			SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(pilotPed), true)
			--SetPedCanSwitchWeapon(ped, true)

			SetPedKeepTask(pilotPed, true)
			SetPedShootRate(pilotPed,  550)
			SetPedAsEnemy(pilotPed,true)
			SetPedMaxHealth(pilotPed, 900)
			SetPedAlertness(pilotPed, 3) --Сразу готов к бою, не требуется стрелять в него
			--SetPedCombatRange(ped, 0)
			SetPedCombatMovement(pilotPed, 2)
			SetPedAccuracy(pilotPed, 30) --Меткость, слишком метких не нужно пусть ведут огонь косо
			--SetVehicleForwardSpeed(ped,60.0)
			SetHeliBladesFullSpeed(pilotPed) -- works for planes I guess
			SetVehicleEngineOn(pilotPed, true, true, false)
			SetEntityAsMissionEntity(pilotPed, true, true)

			SetBlockingOfNonTemporaryEvents(pilotPed, true)
			SetEntityAsMissionEntity(pilotPed, true, true)
			SetModelAsNoLongerNeeded(model)
			return pilotPed
		end
	end
end


--Spawn plane
function CreatePlane(x, y, z)
	local PlaneModel = GetHashKey(Config.PlaneModel)
	if IsModelValid(PlaneModel) then
		if IsThisModelAPlane(PlaneModel) then
			RequestModel(PlaneModel)
			while not HasModelLoaded(PlaneModel) do
				Wait(1)
			end

			if not DoesEntityExist(attackVehicle) then
				ESX.ShowAdvancedNotification(_U('Dispatcher'),_U('Illegal_aircraft_title'),_U('Illegal_aircraft'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
				Wait(2000)
				attackVehicle = CreateVehicle(PlaneModel, x, y, z, 0, true, false)

				SetEntityAsMissionEntity(attackVehicle, true, true)
				SetVehicleEngineOn(attackVehicle, true, true, false)
				blipVehicle = AddBlipForEntity(attackVehicle)
				SetBlipSprite(blipVehicle, 16)
				SetBlipFlashes(blipVehicle, true)
				SetBlipColour(blipVehicle,  75)
				SetBlipFlashTimer(blipVehicle, 5000)
				SetBlipDisplay(blipVehicle, 4)

				SetBlipScale(blipVehicle, 1.0)
				SetBlipAsShortRange(blipVehicle, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('Interceptor'))
				EndTextCommandSetBlipName(blipVehicle)
				SetModelAsNoLongerNeeded(PlaneModel)
				return attackVehicle
			else
				ESX.ShowAdvancedNotification(_U('Dispatcher'), _U('Illegal_takeoff'),_U('Interceptor_recalled'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
			end
		end
	end
end

--Создаем вертолет
function CreateHelicopter(x, y, z)
	local HelicopterModel = GetHashKey(Config.HelicopterModel) --buzzard Savage
	if IsModelValid(HelicopterModel) then
		if IsThisModelAHeli(HelicopterModel) then
			RequestModel(HelicopterModel)
			while not HasModelLoaded(HelicopterModel) do
				Wait(1)
			end
			if not DoesEntityExist(attackVehicle) then
				local _, vector = GetNthClosestVehicleNode(x, y, z, math.random(5, 10), 0, 0, 0)
				local sX, sY, sZ = table.unpack(vector)
				ESX.ShowAdvancedNotification(_U('Dispatcher'),_U('Illegal_Helicopter_title'),_U('Illegal_Helicopter'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
				Wait(2000)
				attackVehicle = CreateVehicle(HelicopterModel, sX, sY, sZ+100, 0, true, false)

				SetEntityAsMissionEntity(attackVehicle, true, true)
				SetVehicleEngineOn(attackVehicle, true, true, false)

				blipVehicle = AddBlipForEntity(attackVehicle)
				SetBlipSprite(blipVehicle, 602)
				SetBlipFlashes(blipVehicle, true)
				SetBlipColour(blipVehicle,  75)
				SetBlipFlashTimer(blipVehicle, 5000)
				SetBlipDisplay(blipVehicle, 4)

				SetBlipScale(blipVehicle, 1.0)
				SetBlipAsShortRange(blipVehicle, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('InterceptorHelicopter'))
				EndTextCommandSetBlipName(blipVehicle)
				SetModelAsNoLongerNeeded(HelicopterModel)
				return attackVehicle
			end
		end
	end
end

function deleteVehicle(vehicle, driver)
	if DoesEntityExist(vehicle) then
		local blip = GetBlipFromEntity(vehicle)
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
		end
	end
	DeleteEntity(driver)
	DeleteEntity(vehicle)
end





