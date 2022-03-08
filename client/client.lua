local planeVeh = nil
local HelicopterVeh = nil
local planePed,viperPed,blip = nil
local x,y,z = nil
local Px, Py, Pz = 0
local statusPlane = false
local statusHelicopter = false
local current_zone
local blipHelicopter,blipPlane = nil


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.CheckTimer) --check 10 seconds
		local playerPed = ESX.PlayerData.ped
		local coords = GetEntityCoords(playerPed, false)
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		Px, Py, Pz = table.unpack(coords)
		current_zone = GetNameOfZone(coords.x, coords.y, coords.z) or ''

		if not statusPlane then
			if not IsEntityDead(playerPed) and IsPedInAnyVehicle(playerPed, false) and (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed,true)) and IsEntityInAir(vehicle) then
				if GetPedInVehicleSeat(GetVehiclePedIsIn(ESX.PlayerData.ped), -1) == ESX.PlayerData.ped then
					if DoesEntityExist(vehicle) and not IsEntityDead(playerPed) and (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed,true)) and IsEntityInAir(vehicle) then

						if Config.CheckLicense then
							ESX.TriggerServerCallback('esx_interceptor:requestPlayerCars', function(isOwnedVehicle)

								ESX.TriggerServerCallback('esx_license:checkLicense', function(License)

									if not License or not isOwnedVehicle then

										statusPlane = true
										SetPlayerWantedLevel(PlayerId(), 4, false)
										SetPlayerWantedLevelNow(PlayerId(), true)
										SetDispatchCopsForPlayer(PlayerId(), true)
										planeVeh = CreatePlane(Px+250, Py+250, Pz+50)


										while not DoesEntityExist(planeVeh) do
											Wait(1)
										end
										planePed = CreatePlanePed(planeVeh)
										while not DoesEntityExist(planePed) do
											Wait(1)
										end

										SetPedKeepTask(planePed, true)
										SetPedShootRate(planePed,  750)

										SetPedAsEnemy(planePed,true)
										SetPedMaxHealth(planePed, 900)
										SetPedAlertness(planePed, 3)
										SetPedCombatRange(planePed, 0)
										SetPedCombatMovement(planePed, 3)
										SetPedAccuracy(planePed, 70)
										TaskPlaneMission(planePed, planeVeh, vehicle, 0, 0.0,0.0,0.0, 6, 0.0, 100.0, 0.0, 2500.0, -1500.0)

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
										statusPlane = true
										if Config.Wanted then
											SetPlayerWantedLevel(PlayerId(), 4, false)
											SetPlayerWantedLevelNow(PlayerId(), true)
											SetDispatchCopsForPlayer(PlayerId(), true)
										end


										planeVeh = CreatePlane(Px+250, Py+250, Pz+50)


										while not DoesEntityExist(planeVeh) do
											Wait(1)
										end
										planePed = CreatePlanePed(planeVeh)
										while not DoesEntityExist(planePed) do
											Wait(1)
										end

										SetPedKeepTask(planePed, true)
										SetPedShootRate(planePed,  750)

										SetPedAsEnemy(planePed,true)
										SetPedMaxHealth(planePed, 900)
										SetPedAlertness(planePed, 3)
										SetPedCombatRange(planePed, 0)
										SetPedCombatMovement(planePed, 3)
										SetPedAccuracy(planePed, 70)
										TaskPlaneMission(planePed, planeVeh, vehicle, 0, 0.0,0.0,0.0, 6, 0.0, 100.0, 0.0, 2500.0, -1500.0)

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


		if statusPlane then
			if not DoesEntityExist(planeVeh) or IsEntityDead(planePed) or IsEntityDead(playerPed) or not IsEntityInAir(vehicle) then
				statusPlane = false
				Wait(10000)
				deletePlane(planeVeh, planePed)
			end

			if not (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed, true)) or not IsEntityInAir(vehicle) then
				statusPlane = false
				Wait(10000)
				deletePlane(planeVeh, planePed)
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
	statusPlane = true
end

function CreateHelicopterPed(vehicle)
	local model = GetHashKey("s_m_m_marine_01")
	if DoesEntityExist(vehicle) then
		if IsModelValid(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(1)
			end
			local ped = CreatePedInsideVehicle(vehicle, 26, model, -1, true, false)

			NetworkRegisterEntityAsNetworked(ped)
			SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(ped), true)
			SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(ped), true)
			--SetPedCanSwitchWeapon(ped, true)

			SetPedKeepTask(ped, true)
			SetPedShootRate(ped,  550)
			SetPedAsEnemy(ped,true)
			SetPedMaxHealth(ped, 900)
			SetPedAlertness(ped, 3) --Сразу готов к бою, не требуется стрелять в него
			--SetPedCombatRange(ped, 0)
			SetPedCombatMovement(ped, 2)
			SetPedAccuracy(ped, 30) --Меткость, слишком метких не нужно пусть ведут огонь косо
			--SetVehicleForwardSpeed(ped,60.0)
			SetHeliBladesFullSpeed(ped) -- works for planes I guess
			SetVehicleEngineOn(ped, true, true, false)
			SetEntityAsMissionEntity(ped, true, true)

			SetBlockingOfNonTemporaryEvents(ped, true)
			SetEntityAsMissionEntity(ped, true, true)
			SetModelAsNoLongerNeeded(model)
			return ped
		end
	end
	statusHelicopter = true
end


--Spawn plane
function CreatePlane(x, y, z)
	local PlaneModel = GetHashKey(Config.Interceptor)
	if IsModelValid(PlaneModel) then
		if IsThisModelAPlane(PlaneModel) then
			RequestModel(PlaneModel)
			while not HasModelLoaded(PlaneModel) do
				Wait(1)
			end
			if not DoesEntityExist(planeVeh) then
				ESX.ShowAdvancedNotification(_U('Dispatcher'),_U('Illegal_aircraft_title'),_U('Illegal_aircraft'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
				Wait(2000)
				planeVeh = CreateVehicle(PlaneModel, x, y, z, 0, true, false)

				SetEntityAsMissionEntity(planeVeh, true, true)
				SetVehicleEngineOn(planeVeh, true, true, false)
				blipPlane = AddBlipForEntity(planeVeh)
				SetBlipSprite(blipPlane, 16)
				SetBlipFlashes(blipPlane, true)
				SetBlipColour(blipPlane,  75)
				SetBlipFlashTimer(blipPlane, 5000)
				SetBlipDisplay(blipPlane, 4)

				SetBlipScale(blipPlane, 1.0)
				SetBlipAsShortRange(blipPlane, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('Interceptor'))
				EndTextCommandSetBlipName(blipPlane)
				SetModelAsNoLongerNeeded(PlaneModel)
				return planeVeh
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
			if not DoesEntityExist(HelicopterVeh) then
				local _, vector = GetNthClosestVehicleNode(x, y, z, math.random(5, 10), 0, 0, 0)
				local sX, sY, sZ = table.unpack(vector)
				ESX.ShowAdvancedNotification(_U('Dispatcher'),_U('Illegal_Helicopter_title'),_U('Illegal_Helicopter'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
				Wait(2000)
				HelicopterVeh = CreateVehicle(HelicopterModel, sX, sY, sZ+100, 0, true, false)

				SetEntityAsMissionEntity(HelicopterVeh, true, true)
				SetVehicleEngineOn(HelicopterVeh, true, true, false)

				blipHelicopter = AddBlipForEntity(HelicopterVeh)
				SetBlipSprite(blipHelicopter, 602)
				SetBlipFlashes(blipHelicopter, true)
				SetBlipColour(blipHelicopter,  75)
				SetBlipFlashTimer(blipHelicopter, 5000)
				SetBlipDisplay(blipHelicopter, 4)

				SetBlipScale(blipHelicopter, 1.0)
				SetBlipAsShortRange(blipHelicopter, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('InterceptorHelicopter'))
				EndTextCommandSetBlipName(blipHelicopter)
				SetModelAsNoLongerNeeded(HelicopterModel)
				return HelicopterVeh
			end
		end
	end
end


function deleteHelicopter(vehicle, driver)
	if DoesEntityExist(vehicle) then
		local blip = GetBlipFromEntity(vehicle)
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
		end
		DeleteEntity(driver)
		DeleteEntity(vehicle)
	end

	if not DoesEntityExist(vehicle) and DoesEntityExist(driver) then
		DeleteEntity(driver)
	end
	statusHelicopter = false
end

function deletePlane(vehicle, driver)
	if DoesEntityExist(vehicle) then
		local blip = GetBlipFromEntity(vehicle)
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
		end
		DeleteEntity(driver)
		DeleteEntity(vehicle)
	end

	if not DoesEntityExist(vehicle) and DoesEntityExist(driver) then
		DeleteEntity(driver)
	end
	statusPlane = false

end





