local planeVeh = nil
local viperVeh = nil
local planePed,viperPed,blip = nil
local x,y,z = nil
local Px, Py, Pz = 0
local statusPlane = false
local statusViper = false
local current_zone

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10000) --check 10 seconds
		local playerPed = ESX.PlayerData.ped
		local coords = GetEntityCoords(playerPed, false)
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		Px, Py, Pz = table.unpack(coords)
		current_zone = GetNameOfZone(coords.x, coords.y, coords.z) or ''
		--То что ниже не выполнится
		--Если сущность существует, и если игрок находиться в самолете или в вертолете, также статус миссии FALSE
		--print('Current zone',current_zone)
		--print('STATUS',statusPlane)


		if not statusPlane then --Если не статус то осуществляем проверки
			if not IsEntityDead(playerPed) and IsPedInAnyVehicle(playerPed, false) and (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed,true)) and IsEntityInAir(vehicle) then
				if GetPedInVehicleSeat(GetVehiclePedIsIn(ESX.PlayerData.ped), -1) == ESX.PlayerData.ped then
					if DoesEntityExist(vehicle) and not IsEntityDead(playerPed) and (IsPedInAnyPlane(playerPed, true) or IsPedInAnyHeli(playerPed,true)) and IsEntityInAir(vehicle) then
						ESX.TriggerServerCallback('esx_interceptor:requestPlayerCars', function(isOwnedVehicle)
							ESX.TriggerServerCallback('esx_license:checkLicense', function(License)
								if not License or not isOwnedVehicle then
									statusPlane = true
									SetPlayerWantedLevel(PlayerId(), 4, false)
									SetPlayerWantedLevelNow(PlayerId(), true)
									SetDispatchCopsForPlayer(PlayerId(), true)
									planeVeh = CreatePlane(Px+250, Py+250, Pz+50) --Кординаты респа самолета (военная база)


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
									SetPedAlertness(planePed, 3) --Сразу готов к бою, не требуется стрелять в него
									SetPedCombatRange(planePed, 0)
									SetPedCombatMovement(planePed, 3)
									SetPedAccuracy(planePed, 70)
									TaskPlaneMission(planePed, planeVeh, vehicle, 0, 0.0,0.0,0.0, 6, 0.0, 100.0, 0.0, 2500.0, -1500.0)

									--TaskPlaneMission, пилот, машина, 0, Game.Player.Character, 0, 0, 0, 6, 0f, 0f, 0f, 2500.0f, -1500f);

									--TaskVehicleFollow(planePed, planeVeh, vehicle, 100.0, 1, 25)

									PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
									Wait(2000)
									PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
									Wait(2000)
									PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
									Wait(5000)

									--TaskPlaneMission(planePed, planeVeh, vehicle, 0, -2499.8798828125,3274.580078125, 32.81999969482422, 6, 0, 0, 50.0, 0.0, 5000.0)

								end
							end, GetPlayerServerId(PlayerId()), 'aircraft')

						end, GetVehicleNumberPlateText(vehicle))

						--Если самолет уничтожен, если пед убит или умирает, если вертолет уничтожен, то отправляем бота на базу
					end

				end
			end
		end


		if statusPlane then --проверяем на технику и жив ли игрок
			--Если в техники, не мертвы, иди не умираем, и не в воздухе.
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
	status = true
end

function CreateViperPed(vehicle)
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
	status = true
end


--Создаем самолет
function CreatePlane(x, y, z)
	local planeModel = GetHashKey("lazer")
	if IsModelValid(planeModel) then
		if IsThisModelAPlane(planeModel) then
			RequestModel(planeModel)
			while not HasModelLoaded(planeModel) do
				Wait(1)
			end
			if not DoesEntityExist(planeVeh) then
				--local _, vector = GetNthClosestVehicleNode(x, y, z, math.random(5, 10), 0, 0, 0)
				--local sX, sY, sZ = table.unpack(vector)
				ESX.ShowAdvancedNotification(_U('Dispatcher'),_U('Illegal_aircraft_title'),_U('Illegal_aircraft'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
				Wait(2000)
				planeVeh = CreateVehicle(planeModel, x, y, z, 0, true, false)

				SetEntityAsMissionEntity(planeVeh, true, true)
				SetVehicleEngineOn(planeVeh, true, true, false)
				---БЛИП НАСТРОЙКА
				blip = AddBlipForEntity(planeVeh)
				SetBlipSprite(blip, 16)
				SetBlipFlashes(blip, true)
				SetBlipColour(blip,  75)
				SetBlipFlashTimer(blip, 5000)
				SetBlipDisplay(blip, 4)

				SetBlipScale(blip, 1.0)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('Interceptor'))
				EndTextCommandSetBlipName(blip)
				SetModelAsNoLongerNeeded(planeModel)
				return planeVeh
			else
				ESX.ShowAdvancedNotification(_U('Dispatcher'), _U('Illegal_takeoff'),_U('Interceptor_recalled'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
			end
		end
	end
end

--Создаем вертолет
function CreateViper(x, y, z)
	local ViperModel = GetHashKey("buzzard") --buzzard Savage

	if IsModelValid(ViperModel) then
		if IsThisModelAHeli(ViperModel) then
			RequestModel(ViperModel)
			while not HasModelLoaded(ViperModel) do
				Wait(1)
			end
			if not DoesEntityExist(viperVeh) then
				local _, vector = GetNthClosestVehicleNode(x, y, z, math.random(5, 10), 0, 0, 0)
				local sX, sY, sZ = table.unpack(vector)
				ESX.ShowAdvancedNotification(_U('Dispatcher'),_U('Illegal_Viper_title'),_U('Illegal_Viper'), "CHAR_MP_ARMY_CONTACT", 8, 1, 1, 130)
				Wait(2000)
				viperVeh = CreateVehicle(ViperModel, sX, sY, sZ+100, 0, true, false)

				SetEntityAsMissionEntity(viperVeh, true, true)
				SetVehicleEngineOn(viperVeh, true, true, false)
				---БЛИП НАСТРОЙКА
				blip = AddBlipForEntity(viperVeh)
				SetBlipSprite(blip, 602)
				SetBlipFlashes(blip, true)
				SetBlipColour(blip,  75)
				SetBlipFlashTimer(blip, 5000)
				SetBlipDisplay(blip, 4)

				SetBlipScale(blip, 1.0)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('InterceptorViper'))
				EndTextCommandSetBlipName(blip)
				SetModelAsNoLongerNeeded(ViperModel)
				return viperVeh
			end
		end
	end
end


function deleteViper(vehicle, driver)
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
	statusViper = false
end






