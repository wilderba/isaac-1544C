local mod1544C = RegisterMod("15-44C",1)

local game = Game()
local sfx = SFXManager()
local r = RNG()
r:SetSeed(Random(),1)

local HudPickups = Sprite()
HudPickups:Load("gfx/ui/heart_icon2.anm2",true)

local HudNumbers = Sprite()
HudNumbers:Load("gfx/ui/hud_numbers.anm2",true)

local HudPrice = Sprite()
HudPrice:Load("gfx/ui/hud_price.anm2",true)

local HudBatteries = Sprite()
HudBatteries:Load("gfx/ui/hud_battery_6_straight.anm2",true)

mod1544C.COLLECTIBLE_GYRO = Isaac.GetItemIdByName("Gyromatic Stabilizer")

mod1544C.COLLECTIBLE_ENERGIZER = Isaac.GetItemIdByName("Energizer")

mod1544C.COLLECTIBLE_DONT_HICKEY = Isaac.GetItemIdByName("Don't Hickey")
mod1544C.COLLECTIBLE_TECHNOLOGY_PROTO = Isaac.GetItemIdByName("Technology Proto")
mod1544C.COLLECTIBLE_FABRICATOR = Isaac.GetItemIdByName("Fabricator")
mod1544C.COLLECTIBLE_UPGRADE = Isaac.GetItemIdByName("Upgrade!")
mod1544C.COLLECTIBLE_OVERCLOCKER = Isaac.GetItemIdByName("Overclocker")

mod1544C.COLLECTIBLE_SPARE_BATTERY = Isaac.GetItemIdByName("Spare Battery")
mod1544C.COLLECTIBLE_BACKUP_BATTERY = Isaac.GetItemIdByName("Backup Battery")
mod1544C.COLLECTIBLE_OVERDRIVE_CELL = Isaac.GetItemIdByName("Overdrive Cell")
mod1544C.COLLECTIBLE_POWERPACK = Isaac.GetItemIdByName("Powerpack")
mod1544C.COLLECTIBLE_EXTRA_BATTERY = Isaac.GetItemIdByName("Extra Battery")

mod1544C.DiabloPool = {}

mod1544C.DiabloPool[mod1544C.COLLECTIBLE_DONT_HICKEY] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_TECHNOLOGY_PROTO] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_FABRICATOR] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_UPGRADE] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_OVERCLOCKER] = true

mod1544C.DiabloPool[mod1544C.COLLECTIBLE_SPARE_BATTERY] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_BACKUP_BATTERY] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_OVERDRIVE_CELL] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_POWERPACK] = true
mod1544C.DiabloPool[mod1544C.COLLECTIBLE_EXTRA_BATTERY] = true

mod1544C.HasDiabloPool = {}

local char1544C = {
	ENERGY_PER_CONTAINER = 6,
	ENERGY_PER_DAMAGE = 3,
	START_EC = 6,
	EnergyContainers = 2,
	Energy = 8,
	countdown = 0,
	hearts = 0,
	InTheMix = false, 
	ItemProtects = false,
	MAX_OFFSET = 18,
	gyro = nil
}

local Energizer = {
	Direction = Direction.NO_DIRECTION,
	DirectionStart = 1,
	EntityVariant = Isaac.GetEntityVariantByName("Energizer"),
	GaveTechZero = false,
	GaveJacob = false,
	GaveWiz = false,
	room = nil
}

local TechnologyProto = {
	GaveTechZero = false,
	GaveTech = false,
	GaveTechTwo = false,
	GaveTechPointFive = false,
	GaveTechX = false,
	thisFloor = 0
}

local Overclocker = {
	Multiplier = 1,
	Room = nil
}

local Upgrade = {
	damageMultSmall = 0,
	rangeMultSmall = 0,
	speedMultSmall = 0,
	tearsMultSmall = 0,
	luckMultSmall = 0,
	damageMultLarge = 0,
	rangeMultLarge = 0,
	speedMultLarge = 0,
	tearsMultLarge = 0,
	luckMultLarge = 0,
	DAMAGE_BONUS_SMALL = 0.5,
	RANGE_HEIGHT_BONUS_SMALL = .1,
	RANGE_FALL_BONUS_SMALL = 1,
	SPEED_BONUS_SMALL = 0.1,
	TEARS_BONUS_SMALL = -1,
	LUCK_BONUS_SMALL = 1,
	DAMAGE_BONUS_LARGE = 4,
	RANGE_HEIGHT_BONUS_LARGE = 0,
	RANGE_FALL_BONUS_LARGE = 10,
	SPEED_BONUS_LARGE = 1,
	TEARS_BONUS_LARGE = -2,
	LUCK_BONUS_LARGE = 14,
	room = nil
}

local UILayout = {
	HEART_ICON = Vector(40,42),
	HEART_NUM = Vector(52, 42),
	BAT_ICON = Vector(72, 14),
	BAT_OFFSET = Vector(24,0),
	BAT_OFFSET_2 = Vector(0,24)
}

function math.randomchoice(t) --Selects a random item from a table
    local keys = {}
    for key, value in pairs(t) do
        keys[#keys+1] = key --Store keys in another table
    end
    index = keys[r:RandomInt(#keys)+1]
    return t[index]
end

function math.randomchoiceindex(t) --Selects a random index from a table
    local keys = {}
    for key, value in pairs(t) do
        keys[#keys+1] = key --Store keys in another table
    end
    index = keys[r:RandomInt(#keys)+1]
    return index
end

function mod1544C:Init()
	player = Isaac.GetPlayer(0)	
	if player:GetName() == "15-44C" and game:GetFrameCount() == 1 then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

-- Also handles pre-exit removal of temp items
function mod1544C.SaveState()
	player = Isaac.GetPlayer(0)
	local data = ""
	
	-- Save hearts and energy status used by 15-44C
	if(char1544C.hearts < 10) then data = data .. "0" end
	data = data .. tostring(char1544C.hearts)
	if(char1544C.EnergyContainers < 10) then data = data .. "0" end
	data = data .. tostring(char1544C.EnergyContainers)
	if(char1544C.Energy < 10) then data = data .. "0" end
	data = data .. tostring(char1544C.Energy)
	
	-- Save what Tech Proto items are current, and the floor number
	data = data ..  tostring(TechnologyProto.GaveTechZero and 1 or 0)
	data = data ..  tostring(TechnologyProto.GaveTech and 1 or 0)
	data = data ..  tostring(TechnologyProto.GaveTechTwo and 1 or 0)
	data = data ..  tostring(TechnologyProto.GaveTechPointFive and 1 or 0)
	data = data ..  tostring(TechnologyProto.GaveTechX and 1 or 0)
	
	if TechnologyProto.thisFloor < 10 then data = data .. "0" end
	data = data .. tostring(TechnologyProto.thisFloor)
	
	-- save the small value mults of Upgrade
	data = data .. tostring(Upgrade.damageMultSmall)
	data = data .. tostring(Upgrade.rangeMultSmall)
	data = data .. tostring(Upgrade.speedMultSmall)
	data = data .. tostring(Upgrade.tearsMultSmall)
	data = data .. tostring(Upgrade.luckMultSmall)
	
	Isaac.DebugString("Save Data : " .. data)
	
	
	-- Save the Data
	mod1544C:SaveData(data)	
	
	-- Ungive collectibles from Energizer use
	if Energizer.GaveTechZero then
		player:RemoveCollectible(Isaac.GetItemIdByName("Technology Zero"))
	end
	if  Energizer.GaveJacob then
		player:RemoveCollectible(Isaac.GetItemIdByName("Jacob's Ladder"))
	end
	if  Energizer.GaveWiz then
		player:RemoveCollectible(Isaac.GetItemIdByName("The Wiz"))
	end
	
	-- Ungive collectibles from Technology Proto use
	if TechnologyProto.GaveTech  then
		player:RemoveCollectible(Isaac.GetItemIdByName("Technology"))
	end
	if TechnologyProto.GaveTechZero then
		player:RemoveCollectible(Isaac.GetItemIdByName("Technology Zero"))
	end
	if TechnologyProto.GaveTechTwo then
		player:RemoveCollectible(Isaac.GetItemIdByName("Technology 2"))
	end
	if TechnologyProto.GaveTechPointFive then
		player:RemoveCollectible(Isaac.GetItemIdByName("Tech.5"))
	end
	if TechnologyProto.GaveTechX then
		player:RemoveCollectible(Isaac.GetItemIdByName("Tech X"))
	end
end

function mod1544C:TakeDamage(entity, damageNum)
	-- When 15-44C takes damage, he first loses charge off his active item, then from his energy, at a rate of 2 bars per half-heart damage
	damageNum = damageNum*Overclocker.Multiplier
	energyDamageNum = damageNum*char1544C.ENERGY_PER_DAMAGE 
	player = Isaac.GetPlayer(0)
	
	if player:GetName() == "15-44C" then
		-- TODO: If they have The Battery, borrow from that pool of energy
		
		-- Then borrow from active energy pool
		if(player:GetActiveCharge() >= energyDamageNum) then
			player:SetActiveCharge(player:GetActiveCharge() - energyDamageNum)
			energyDamageNum = 0
		elseif (player:GetActiveCharge() > 0) then
			energyDamageNum = energyDamageNum - player:GetActiveCharge()
			player:SetActiveCharge(0)
		end
		char1544C.Energy = math.max(char1544C.Energy - energyDamageNum, 0)
	elseif damageNum > 2 then
		for i = 1, damageNum - 2 do
			if player:GetSoulHearts() > 0 then
				player:AddSoulHearts(-1)
			else
				player:AddHearts(-1)
			end
		end
	end
end

function mod1544C:onUpdate(player)
	player = Isaac.GetPlayer(0)
	
	-- Massive block only for 15-44C
	if player:GetName() == "15-44C" then
		local data = nil
		-- Initialize energy nd heart data, give Energizer
		if game:GetFrameCount() == 0 then
			char1544C.EnergyContainers = char1544C.START_EC	
			char1544C.Energy = char1544C.EnergyContainers*char1544C.ENERGY_PER_CONTAINER
			char1544C.hearts = 0
			char1544C.InTheMix = false
			player:AddCollectible(Isaac.GetItemIdByName("Energizer"),0,false)
			player:FullCharge() 
			-- Spawn Gyromatic Stabilizer for player choice
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, mod1544C.COLLECTIBLE_GYRO, Vector(160,240), Vector(0,0), nil):ToPickup()

		-- if char1544C.gyro then
			-- char1544C.gyro:ToPickup().Price = PickupPrice.PRICE_ONE_HEART
		end
		
		-- Handle whether active item can absorb a hit or not for heart evaluation
		if (not char1544C.ItemProtects) and ((player:GetActiveCharge() >= 2*char1544C.ENERGY_PER_DAMAGE) or (player:GetActiveCharge() >= char1544C.ENERGY_PER_DAMAGE and (game:GetLevel():GetStage() < 7 or player:HasCollectible(Isaac.GetItemIdByName("The Wafer"))))) then
			char1544C.ItemProtects = true
			player:AddSoulHearts(2)
		end
		if char1544C.ItemProtects and not ((player:GetActiveCharge() >= 2*char1544C.ENERGY_PER_DAMAGE or (player:GetActiveCharge() >= char1544C.ENERGY_PER_DAMAGE and (game:GetLevel():GetStage() < 7 or player:HasCollectible(Isaac.GetItemIdByName("The Wafer")))))) then
			char1544C.ItemProtects = false
			player:AddSoulHearts(-2)
		end
		
		-- Handle regenerating Energy - flag when in combat, then regen and clear the flag after combat!
		if not game:GetLevel():GetCurrentRoom():IsClear() then
			char1544C.InTheMix = true
		end
		if char1544C.InTheMix and game:GetLevel():GetCurrentRoom():IsClear() then
			if char1544C.Energy < char1544C.ENERGY_PER_CONTAINER*char1544C.EnergyContainers then
				char1544C.Energy = char1544C.Energy + 1
				sfx:Play(SoundEffect.SOUND_ITEMRECHARGE, 1.0,  0, false, 1.0)
			end
			char1544C.InTheMix = false
		end
	
	
		-- Ungive collectibles from Energizer use
		if Energizer.GaveTechZero and Energizer.room ~= game:GetLevel():GetCurrentRoomIndex()then
			player:RemoveCollectible(Isaac.GetItemIdByName("Technology Zero"))
			Energizer.GaveTechZero = false
			Energizer.room = nil
		end
		if  Energizer.GaveJacob and Energizer.room ~= game:GetLevel():GetCurrentRoomIndex()then
			player:RemoveCollectible(Isaac.GetItemIdByName("Jacob's Ladder"))
			Energizer.GaveJacob = false
			Energizer.room = nil
		end
		if  Energizer.GaveWiz and Energizer.room ~= game:GetLevel():GetCurrentRoomIndex()then
			player:RemoveCollectible(Isaac.GetItemIdByName("The Wiz"))
			Energizer.GaveWiz = false
			Energizer.room = nil
		end
		
		-- Ungive collectibles from Technology Proto use
		if TechnologyProto.GaveTech and TechnologyProto.thisFloor ~= game:GetLevel():GetStage() then
			player:RemoveCollectible(Isaac.GetItemIdByName("Technology"))
			TechnologyProto.GaveTech = false
			TechnologyProto.thisFloor = 0
		end
		if TechnologyProto.GaveTechZero and TechnologyProto.thisFloor ~= game:GetLevel():GetStage() then
			player:RemoveCollectible(Isaac.GetItemIdByName("Technology Zero"))
			TechnologyProto.GaveTechZero = false
			TechnologyProto.thisFloor = 0
		end
		if TechnologyProto.GaveTechTwo and TechnologyProto.thisFloor ~= game:GetLevel():GetStage() then
			player:RemoveCollectible(Isaac.GetItemIdByName("Technology 2"))
			TechnologyProto.GaveTechTwo = false
			TechnologyProto.thisFloor = 0
		end
		if TechnologyProto.GaveTechPointFive and TechnologyProto.thisFloor ~= game:GetLevel():GetStage() then
			player:RemoveCollectible(Isaac.GetItemIdByName("Tech.5"))
			TechnologyProto.GaveTechPointFive = false
			TechnologyProto.thisFloor = 0
		end
		if TechnologyProto.GaveTechX and TechnologyProto.thisFloor ~= game:GetLevel():GetStage() then
			player:RemoveCollectible(Isaac.GetItemIdByName("Tech X"))
			TechnologyProto.GaveTechX = false
			TechnologyProto.thisFloor = 0
		end
		
		-- Kill player if Energy = 0
		if char1544C.Energy <= 0 then
			-- Backup Battery with the save!
			if player:HasCollectible(mod1544C.COLLECTIBLE_BACKUP_BATTERY) then
				char1544C.Energy = 1
				char1544C.EnergyContainers = char1544C.EnergyContainers - 1
				char1544C.Energy = math.min(char1544C.Energy, char1544C.EnergyContainers*char1544C.ENERGY_PER_CONTAINER)
				player:RemoveCollectible(mod1544C.COLLECTIBLE_BACKUP_BATTERY)
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1.0,  0, false, 1.0)
			else
				player:Kill()
			end
		end
		
	
		-- Set player max health to 6, current health to 3, and remove all soul/black/eternal hearts. If player has more than 6 max health, award 10 hearts per 2 removed
		if player:GetMaxHearts() ~= 6 then
			char1544C.hearts = char1544C.hearts + 5*math.max(0, player:GetMaxHearts() - 6)
			player:AddMaxHearts(6 - player:GetMaxHearts(), true)
			player:AddHearts(3 - player:GetHearts())
		end
		if player:GetHearts() ~= 3 then
			if player:GetHearts() > 3 then char1544C.hearts = char1544C.hearts + (player:GetHearts()-3) end
			player:AddHearts(3 - player:GetHearts())
		end
		-- Isaac.DebugString("We have yea many black hearts: " .. player:GetBlackHearts())
		-- char1544C.hearts = char1544C.hearts + (player:GetBlackHearts()*2)
		-- -- Don't know why I have to take away twice as many black hearts as the player has, but I do!
		-- player:AddBlackHearts(2*(-player:GetBlackHearts()))
		
		-- Ok, loop through and remove black hearts half-by-half. Nice.
		-- while player:GetBlackHearts() > 0 do
			-- Isaac.DebugString("Black hearts: " .. player:GetBlackHearts())
			-- char1544C.hearts = char1544C.hearts + 2
			-- player:AddBlackHearts(-1)
		-- end
		
		-- Turn all black hearts spirit and give an extra 1 heart counter each before removing (and giving 3 heart counter each)
		for i = 1, 12 do
			if player:IsBlackHeart(i) then
				player:RemoveBlackHeart(i)
				char1544C.hearts = char1544C.hearts + 1
			end
		end
		
		
		-- If the active item could absorb a whole floor-normal hit, provide one soul heart to protect devil chance
		if char1544C.ItemProtects then
			char1544C.hearts = char1544C.hearts + math.ceil(math.max(0, (player:GetSoulHearts()-2)*(3/2)))
			player:AddSoulHearts(2-player:GetSoulHearts())
		else
			char1544C.hearts = char1544C.hearts + math.ceil(player:GetSoulHearts()*(3/2))
			player:AddSoulHearts(-player:GetSoulHearts())
		end
		char1544C.hearts = char1544C.hearts + 5*player:GetEternalHearts()
		player:AddEternalHearts(-player:GetEternalHearts())
		
		-- Reduce the global cooldown for 15-44C's passive
		if char1544C.countdown >= 0 then char1544C.countdown = char1544C.countdown - 1 end
	end	
	
	-- Reset upgrade values on restart
	if game:GetFrameCount() == 0 then
		Upgrade.damageMultSmall = 0
		Upgrade.rangeMultSmall = 0
		Upgrade.speedMultSmall = 0
		Upgrade.tearsMultSmall = 0
		Upgrade.luckMultSmall = 0
		
		Upgrade.damageMultLarge = 0
		Upgrade.rangeMultLarge = 0
		Upgrade.speedMultLarge = 0
		Upgrade.tearsMultLarge = 0
		Upgrade.luckMultLarge = 0
		
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		
		player:EvaluateItems()
	end
	
	-- TODO: Reset DiabloPool and HasDiabloPool on restart
	
	-- Load data on resume 
		if game:GetFrameCount() ~= 1 and player.FrameCount == 1 and mod1544C:HasData() then
			local ModData = mod1544C:LoadData()
			
			Isaac.DebugString("Load data: " .. tostring(ModData))
			
			char1544C.hearts = tonumber(ModData:sub(1,2))
			char1544C.EnergyContainers = tonumber(ModData:sub(3,4))
			char1544C.Energy = tonumber(ModData:sub(5,6))
			
			-- Load Tech Proto data from ModData
			TechnologyProto.GaveTechZero = (tonumber(ModData:sub(7,7)) == 1)
			TechnologyProto.GaveTech = (tonumber(ModData:sub(8,8)) == 1)
			TechnologyProto.GaveTechTwo = (tonumber(ModData:sub(9,9)) == 1)
			TechnologyProto.GaveTechPointFive = (tonumber(ModData:sub(10,10)) == 1)
			TechnologyProto.GaveTechX = (tonumber(ModData:sub(11,11)) == 1)
			
			-- Give collectibles from Technology Proto use
			if TechnologyProto.GaveTech  then
				player:AddCollectible(Isaac.GetItemIdByName("Technology"),0,false)
			end
			if TechnologyProto.GaveTechZero then
				player:AddCollectible(Isaac.GetItemIdByName("Technology Zero"),0,false)
			end
			if TechnologyProto.GaveTechTwo then
				player:AddCollectible(Isaac.GetItemIdByName("Technology 2"),0,false)
			end
			if TechnologyProto.GaveTechPointFive then
				player:AddCollectible(Isaac.GetItemIdByName("Tech.5"),0,false)
			end
			if TechnologyProto.GaveTechX then
				player:AddCollectible(Isaac.GetItemIdByName("Tech X"),0,false)
			end
			
			TechnologyProto.thisFloor = tonumber(ModData:sub(12,13))
			
			-- Load Upgrade data from ModData
			Upgrade.damageMultSmall = tonumber(ModData:sub(14,14))
			Upgrade.rangeMultSmall = tonumber(ModData:sub(15,15))
			Upgrade.speedMultSmall = tonumber(ModData:sub(16,16))
			Upgrade.tearsMultSmall = tonumber(ModData:sub(17,17))
			Upgrade.luckMultSmall = tonumber(ModData:sub(18,18))
			
			-- Load HasDiabloPool based on whether player has items from DiabloPool (also remove held items from DiabloPool)
			mod1544C.DiabloPool = {}

			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_DONT_HICKEY] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_TECHNOLOGY_PROTO] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_FABRICATOR] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_UPGRADE] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_OVERCLOCKER] = true

			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_SPARE_BATTERY] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_BACKUP_BATTERY] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_OVERDRIVE_CELL] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_POWERPACK] = true
			mod1544C.DiabloPool[mod1544C.COLLECTIBLE_EXTRA_BATTERY] = true

			mod1544C.HasDiabloPool = {}
		end
	


	
	-- If player has any Diablo items and they aren't in HasDiabloPool yet, move them there and perform pickup effects 
	for id, exists in pairs(mod1544C.DiabloPool) do
		-- If the player has the item, and it's not in HasDiabloPool, then we need to say it is and do pickup effects
		if player:HasCollectible(id) and not mod1544C.HasDiabloPool[id] then
			-- Set DiabloPool[id] to false and HasDiabloPool[id] to true, then do on-pickup effects
			mod1544C.DiabloPool[id] = false
			mod1544C.HasDiabloPool[id] = true
			-- Pickup Effects below:
			-- Backup Battery/Spare Battery/Overdrive Cell (all give 1 EC+4 Energy to 15-44C and 4 batteries to anyone else)
			if id == mod1544C.COLLECTIBLE_BACKUP_BATTERY or id == mod1544C.COLLECTIBLE_SPARE_BATTERY or id == mod1544C.COLLECTIBLE_OVERDRIVE_CELL then
				if player:GetName() == "15-44C" then
					char1544C.EnergyContainers = char1544C.EnergyContainers + 1
					char1544C.Energy = char1544C.Energy + char1544C.ENERGY_PER_CONTAINER
				else
					--Spawn 4 batteries for other characters if they somehow wind up with this
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
				end
			end
			
			-- Extra Battery
			if id == mod1544C.COLLECTIBLE_EXTRA_BATTERY then
				if player:GetName() == "15-44C" then
					char1544C.EnergyContainers = char1544C.EnergyContainers + 1
					char1544C.Energy = char1544C.Energy + char1544C.ENERGY_PER_CONTAINER
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
				else
					--Spawn 4 batteries for other characters if they somehow wind up with this
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
				end
			end
			
			-- Powerpack
			if id == mod1544C.COLLECTIBLE_POWERPACK then
				if player:GetName() == "15-44C" then
					char1544C.EnergyContainers = char1544C.EnergyContainers + 1
					char1544C.Energy = char1544C.EnergyContainers*char1544C.ENERGY_PER_CONTAINER
				else
					--Spawn 4 batteries for other characters if they somehow wind up with this
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
					game:Spawn(5,90,player.Position, Vector(0,0), nil, 0, 0)
				end
			end
			
		end
	end

	-- Reset Overclocker multiplier if outside of the room it was used in
	if Overclocker.Multiplier ~= 1 and Overclocker.Room ~= game:GetLevel():GetCurrentRoomIndex() then
		Overclocker.Multiplier = 1
		Overclocker.Room = nil
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	
	-- Reset Upgrade.<stat>MultLarge values if outside the room it was used in
	if Upgrade.room ~= game:GetLevel():GetCurrentRoomIndex() then
		Upgrade.damageMultLarge = 0
		Upgrade.rangeMultLarge = 0
		Upgrade.speedMultLarge = 0
		Upgrade.tearsMultLarge = 0
		Upgrade.luckMultLarge = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
	
	-- Set any values above max value to max value 
	if char1544C.hearts > 99 then char1544C.hearts = 99 end
	
	Upgrade.damageMultSmall = math.min(Upgrade.damageMultSmall, 9)
	Upgrade.rangeMultSmall = math.min(Upgrade.rangeMultSmall, 9)
	Upgrade.speedMultSmall = math.min(Upgrade.speedMultSmall, 9)
	Upgrade.tearsMultSmall = math.min(Upgrade.tearsMultSmall, 9)
	Upgrade.luckMultSmall = math.min(Upgrade.luckMultSmall, 9)
	
end

function mod1544C:onCache(player, cacheFlag)
	player = Isaac.GetPlayer(0)
	
	-- If the player is 15-44C and doesn't have the Gyromatic Stabilizer, they get Tear Delay - 2
	if cacheFlag == CacheFlag.CACHE_FIREDELAY and player:GetName() == "15-44C" and not player:HasCollectible(Isaac.GetItemIdByName("Gyromatic Stabilizer")) then
		player.MaxFireDelay = player.MaxFireDelay - 2
	end
	
	-- 5 cache checks to increase stats by Upgrade.<stat>MultSmall* Upgrade.<stat>_BONUS_SMALL + Upgrade.<stat>MultLarge * Upgrade.<stat>_BONUS_LARGE		
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if (Upgrade.damageMultSmall > 0) or (Upgrade.damageMultLarge > 0) then
			player.Damage = player.Damage + Upgrade.damageMultSmall*Upgrade.DAMAGE_BONUS_SMALL + Upgrade.damageMultLarge*Upgrade.DAMAGE_BONUS_LARGE
		end
	end
	if cacheFlag == CacheFlag.CACHE_RANGE then
		if (Upgrade.rangeMultSmall > 0) or (Upgrade.rangeMultLarge > 0) then
			player.TearHeight = player.TearHeight + Upgrade.rangeMultSmall*Upgrade.RANGE_HEIGHT_BONUS_SMALL + Upgrade.rangeMultLarge*Upgrade.RANGE_HEIGHT_BONUS_LARGE
			player.TearFallingSpeed = player.TearFallingSpeed + Upgrade.rangeMultSmall*Upgrade.RANGE_FALL_BONUS_SMALL + Upgrade.rangeMultLarge*Upgrade.RANGE_FALL_BONUS_LARGE
		end
	end
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if (Upgrade.speedMultSmall > 0) or (Upgrade.speedMultLarge > 0) then
			player.MoveSpeed = player.MoveSpeed + Upgrade.speedMultSmall*Upgrade.SPEED_BONUS_SMALL + Upgrade.speedMultLarge*Upgrade.SPEED_BONUS_LARGE
		end
	end
	if cacheFlag == CacheFlag.CACHE_FIREDELAY then
		if (Upgrade.tearsMultSmall > 0) or (Upgrade.tearsMultLarge > 0) then
			-- Only apply small upgrade to tear cap
			if player.MaxFireDelay > 5 then
				-- Small upgrade doesn't break tear cap
				player.MaxFireDelay = math.max(5, player.MaxFireDelay + Upgrade.tearsMultSmall*Upgrade.TEARS_BONUS_SMALL)
			end
			-- But big upgrade does!
			player.MaxFireDelay = player.MaxFireDelay + Upgrade.tearsMultLarge*Upgrade.TEARS_BONUS_LARGE
		end
	end
	if cacheFlag == CacheFlag.CACHE_LUCK then
		if (Upgrade.luckMultSmall > 0) or (Upgrade.luckMultLarge > 0) then
			player.Luck = player.Luck + Upgrade.luckMultSmall*Upgrade.LUCK_BONUS_SMALL + Upgrade.luckMultLarge*Upgrade.LUCK_BONUS_LARGE
		end
	end
	
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if Overclocker.Multiplier > 1 then 
			player.Damage = player.Damage * Overclocker.Multiplier
		end
	end
end

function mod1544C:ActivateEnergizer(_TYPE, RNG)
	
	if not player:HasCollectible(Isaac.GetItemIdByName("Technology Zero")) then 
		player:AddCollectible(Isaac.GetItemIdByName("Technology Zero"), 0, false)
		Energizer.GaveTechZero = true
		Energizer.room = game:GetLevel():GetCurrentRoomIndex()
	elseif not player:HasCollectible(Isaac.GetItemIdByName("Jacob's Ladder"))then 
		player:AddCollectible(Isaac.GetItemIdByName("Jacob's Ladder"), 0, false)
		Energizer.GaveJacob = true
		Energizer.room = game:GetLevel():GetCurrentRoomIndex()
	elseif not player:HasCollectible(Isaac.GetItemIdByName("The Wiz"))then 
		player:AddCollectible(Isaac.GetItemIdByName("The Wiz"), 0, false)
		Energizer.GaveWiz = true
		Energizer.room = game:GetLevel():GetCurrentRoomIndex()
	else 
		-- Activate a Tammy's-head style burst
		player:UseActiveItem(Isaac.GetItemIdByName("Tammy's Head"), false, true, true, false)
	end
end

function mod1544C:ActivateTechProto()
	-- If they have all the tech, don't do anything, otherwise try adding one at random until you hit one that they don't have
	if player:HasCollectible(Isaac.GetItemIdByName("Technology Zero")) and player:HasCollectible(Isaac.GetItemIdByName("Tech.5")) and player:HasCollectible(Isaac.GetItemIdByName("Technology"))
	and player:HasCollectible(Isaac.GetItemIdByName("Technology Two")) and player:HasCollectible(Isaac.GetItemIdByName("Tech X"))then
		player:FullCharge()
	else
		TechnologyProto.thisFloor = game:GetLevel():GetStage()
		loop = true
		while loop do
			local rand = r:RandomInt(5)+1
			if rand == 1 and not player:HasCollectible(Isaac.GetItemIdByName("Technology Zero"))then
				player:AddCollectible(Isaac.GetItemIdByName("Technology Zero"), 0, false)
				TechnologyProto.GaveTechZero = true
				loop = false
			end
			if rand == 2 and not player:HasCollectible(Isaac.GetItemIdByName("Technology"))then
				player:AddCollectible(Isaac.GetItemIdByName("Technology"), 0, false)
				TechnologyProto.GaveTech = true
				loop = false
			end
			if rand == 3 and not player:HasCollectible(Isaac.GetItemIdByName("Technology 2"))then
				player:AddCollectible(Isaac.GetItemIdByName("Technology 2"), 0, false)
				TechnologyProto.GaveTechTwo = true
				loop = false
			end
			if rand == 4 and not player:HasCollectible(Isaac.GetItemIdByName("Tech.5"))then
				player:AddCollectible(Isaac.GetItemIdByName("Tech.5"), 0, false)
				TechnologyProto.GaveTechPointFive = true
				loop = false
			end
			if rand == 5 and not player:HasCollectible(Isaac.GetItemIdByName("Tech X"))then
				player:AddCollectible(Isaac.GetItemIdByName("Tech X"), 0, false)
				TechnologyProto.GaveTechX = true
				loop = false
			end
		end
	end
end

function mod1544C:ActivateOverclocker(_TYPE,RNG)
	-- Double damage (up to x8)
	if Overclocker.Multiplier < 8 then
		Overclocker.Room = game:GetLevel():GetCurrentRoomIndex()
		Overclocker.Multiplier = Overclocker.Multiplier*2
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	
end

function mod1544C:ActivateUpgrade(_TYPE,RNG)
	-- Upgrade random stat permanently and same stat greatly for current room
	Isaac.DebugString("Activated Upgrade!")
	local i = r:RandomInt(5)+1
	--local i = 3
	local player = game:GetPlayer(0)
	
	Upgrade.room = game:GetLevel():GetCurrentRoomIndex()
	
	if i == 1 then
		Upgrade.damageMultSmall = Upgrade.damageMultSmall + 1
		Upgrade.damageMultLarge = Upgrade.damageMultLarge + 1
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	elseif i == 2 then
		Upgrade.rangeMultSmall = Upgrade.rangeMultSmall + 1
		Upgrade.rangeMultLarge = Upgrade.rangeMultLarge + 1
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	elseif i == 3 then
		Upgrade.speedMultSmall = Upgrade.speedMultSmall + 1
		Upgrade.speedMultLarge = Upgrade.speedMultLarge + 1
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	elseif i == 4 then
		Upgrade.tearsMultSmall = Upgrade.tearsMultSmall + 1
		Upgrade.tearsMultLarge = Upgrade.tearsMultLarge + 1
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	else
		Upgrade.luckMultSmall = Upgrade.luckMultSmall + 1
		Upgrade.luckMultLarge = Upgrade.luckMultLarge + 1
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	end
	
	player:EvaluateItems()
end

function mod1544C:ActivateDontHickey(_TYPE,RNG)
	sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1.0,  0, false, 1.0)
end

function mod1544C:ActivateFabricator(_TYPE,RNG)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, game:GetItemPool():GetCollectible(game:GetItemPool():GetPoolForRoom(game:GetLevel():GetCurrentRoom():GetType(),game:GetSeeds():GetStartSeed()),false,game:GetSeeds():GetStartSeed()), Isaac.GetFreeNearPosition(player.Position,10), Vector(0,0), nil):ToPickup()
end

function mod1544C:onInput(entity, hook, action)
	 if entity ~= nil then
		 player = entity:ToPlayer()
		 -- If player is 15-44C and pressed the Item button and their item has less than full charge and they have adequete energy to charge it, charge then press
		 if player:GetName() == "15-44C" and char1544C.countdown < 0 and hook == InputHook.IS_ACTION_TRIGGERED and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) and action == ButtonAction.ACTION_ITEM and player:NeedsCharge() then
			char1544C.countdown = 10
			diff = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem()).MaxCharges - player:GetActiveCharge()
			if char1544C.Energy > math.max(1, diff) and player:NeedsCharge() then
				player:SetActiveCharge(player:GetActiveCharge()+diff)
				char1544C.Energy = char1544C.Energy - diff
				char1544C.countdown = 10
			-- Overdrive Cell allows the player to use their energy containers to power active items when they lack energy, regardless of needed charge
			elseif player:NeedsCharge() and player:HasCollectible(mod1544C.COLLECTIBLE_OVERDRIVE_CELL) and char1544C.EnergyContainers > 1 then
				player:SetActiveCharge(player:GetActiveCharge()+diff)
				char1544C.EnergyContainers = char1544C.EnergyContainers - 1
				char1544C.Energy = math.min(char1544C.Energy, char1544C.EnergyContainers*char1544C.ENERGY_PER_CONTAINER)
				char1544C.countdown = 10
			end
			
		 end
	 end
end

function mod1544C:onUseItem(item, rng)
	if player:GetName() == "15-44C" then
		char1544C.countdown = 10
	end
end

function RenderNumber(n, position)
	if n == nil then n = 0 end
	HudNumbers:SetFrame("Idle", math.floor(n/10))
	HudNumbers:RenderLayer(0,position)
	HudNumbers:SetFrame("Idle", n%10)
	HudNumbers:RenderLayer(0,position+Vector(8,0))

end

function length(array)
	local h = 0
	for i,j in pairs(array) do
		h = h + 1
	end
	return h
end

function mod1544C:onRender()
	-- -- Debug - show actions as pressed
	player = Isaac.GetPlayer(0)
	-- local battLev = 0
	
	if player:GetName() == "15-44C" then
		Isaac.RenderText("Energy Level is at " ..  tostring(char1544C.Energy) .. " ItemProtects: " .. tostring(char1544C.ItemProtects) .. " HasDiabloPool members : " .. tostring(length(mod1544C.HasDiabloPool)), 50, 0, 1, 1, 1, 1)
		
		-- Display Energy Bar
		local i = 0
		while i < char1544C.EnergyContainers do
		
			-- lul i dont know how to multiply vectors
			local j = 0 
			local offset = Vector(0,0)
			while j < i%6 do
				offset = offset + UILayout.BAT_OFFSET
				j = j +1
			end
			if math.floor(i/6) > 0 then offset = offset + UILayout.BAT_OFFSET_2 end
			
			-- Render frame ENERGY_PER_CONTAINER + 2 for full batteries, 0 for empty, and Energy%ENERGY_PER_CONTAINER for partial
			if char1544C.Energy - i*char1544C.ENERGY_PER_CONTAINER >= char1544C.ENERGY_PER_CONTAINER then
				HudBatteries:SetFrame("Batt", char1544C.ENERGY_PER_CONTAINER)
				HudBatteries:RenderLayer(0, UILayout.BAT_ICON + offset)
			elseif char1544C.Energy - i*char1544C.ENERGY_PER_CONTAINER < 0 then
				HudBatteries:SetFrame("Batt", 0)
				HudBatteries:RenderLayer(0, UILayout.BAT_ICON + offset)
			else
				HudBatteries:SetFrame("Batt", char1544C.Energy%char1544C.ENERGY_PER_CONTAINER)
				HudBatteries:RenderLayer(0, UILayout.BAT_ICON + offset)
			end
			
			
			i = i +1
		end
		
		-- Display number of hearts with icon
		HudPickups:SetFrame("Heart",1)
		HudPickups:RenderLayer(0, UILayout.HEART_ICON)
		
		RenderNumber(char1544C.hearts, UILayout.HEART_NUM)
		
		-- Display a 15 under Devil Deals, make them all Price=PRICE_ONE_HEART
		for _,entity in pairs(Isaac.GetRoomEntities()) do
			if 	entity.Type == EntityType.ENTITY_PICKUP and
				entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and
				entity:ToPickup().Price < 0
			then
				entity:ToPickup().AutoUpdatePrice = false
				entity:ToPickup().Price = PickupPrice.PRICE_ONE_HEART
				HudPrice:SetFrame("Price",0)
				HudPrice:RenderLayer(0,Isaac.WorldToScreen(entity.Position) + Vector(0,14))
				--RenderNumber(15, Isaac.WorldToScreen(entity.Position) + Vector(-20,10))
			end
		end
	end
	
	
end

function mod1544C:onPickup(pickup, collide, low)
	Isaac.DebugString("Variant: " .. tostring(pickup.Variant))
	player = Isaac.GetPlayer(0)
	if player:GetName() == "15-44C" then
		-- TODO: Make picking up Lil Batteries work right with The Battery
		if pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
			local chargesTaken = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem()).MaxCharges - player:GetActiveCharge()
			if chargesTaken < char1544C.ENERGY_PER_CONTAINER and char1544C.Energy < char1544C.ENERGY_PER_CONTAINER*char1544C.EnergyContainers then 
				char1544C.Energy = math.min(char1544C.ENERGY_PER_CONTAINER*char1544C.EnergyContainers, char1544C.Energy+(char1544C.ENERGY_PER_CONTAINER - chargesTaken))
				player:FullCharge()
				pickup:Remove()
				sfx:Play(SoundEffect.SOUND_BATTERY_CHARGE, 1.0,  0, false, 1.0)
				return false
			end
			return nil
		end
		--  Make Charged Keys work like batteries to charge energy
		if pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType == KeySubType.KEY_CHARGED then
			local chargesTaken = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem()).MaxCharges - player:GetActiveCharge()
			if chargesTaken < char1544C.ENERGY_PER_CONTAINER and char1544C.Energy < char1544C.ENERGY_PER_CONTAINER*char1544C.EnergyContainers then 
				char1544C.Energy = math.min(char1544C.ENERGY_PER_CONTAINER*char1544C.EnergyContainers, char1544C.Energy+(char1544C.ENERGY_PER_CONTAINER-chargesTaken))
				player:FullCharge()
				player:AddKeys(1)
				pickup:Remove()
				sfx:Play(SoundEffect.SOUND_KEYPICKUP_GAUNTLET, 1.0,  0, false, 1.0)
				return false
			end
			return nil
		end
		-- Make Devil Deal pickups cost hearts and only collide if you have enough hearts
		if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Price < 0 then
			if char1544C.hearts < 15 then
				return false
			else
				char1544C.hearts = char1544C.hearts - 15
				return nil
			end
		end
	end
	
	return nil
	
end

function mod1544C:onFireTear(tear)
	local player = Isaac.GetPlayer(0)
	if player:GetName() == "15-44C" then
		local angle = tear.Velocity:GetAngleDegrees()
		local length = tear.Velocity:Length()
		local maxOffset = math.max(char1544C.MAX_OFFSET - player.MaxFireDelay,0)
		if not player:HasCollectible(Isaac.GetItemIdByName("Gyromatic Stabilizer")) then
			tear.Velocity = Vector.FromAngle(angle + r:RandomInt(2*maxOffset)+1-maxOffset):Resized(length)
		end
		
        --local tear = player:FireTear(player.Position, Vector.FromAngle(angle + math.random(-18,18)):Resized(length), true, false, false)
	end
end

function mod1544C:onNewLevel()
	local player = Isaac.GetPlayer(0)
	if player:GetName() == "15-44C" then
		-- I guess we're setting Curse of the Unknown every floor for 15-44C to hide the heart counter? Bleh.
		--game:GetLevel():AddCurse(LevelCurse.CURSE_OF_THE_UNKNOWN,false)
		
		
		-- If it's before Womb and after Basement I, spawn 2 Dr Diablo Deals
		if game:GetLevel():GetStage() > 1 and game:GetLevel():GetStage() < 7 then
			local spawn = false
			local i = 0
			
			while not spawn do
				local randomDiablo = math.randomchoiceindex(mod1544C.DiabloPool)
				if mod1544C.DiabloPool[randomDiablo] then
					local one = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, randomDiablo, Vector(200,200), Vector(0,0), nil):ToPickup()
					one.AutoUpdatePrice = false
					one.Price = PickupPrice.PRICE_ONE_HEART
					spawn = true
				elseif i > 100 then
					one = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetItemIdByName("Breakfast"), Vector(200,200), Vector(0,0), nil):ToPickup()
					one.AutoUpdatePrice = false
					one.Price = PickupPrice.PRICE_ONE_HEART
					spawn = true
				else
					i = i+1
				end
			end
			
			spawn = false
			i = 0
			
			while not spawn do
				local randomDiablo = math.randomchoiceindex(mod1544C.DiabloPool)
				if mod1544C.DiabloPool[randomDiablo] then
					two = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, randomDiablo, Vector(440,200), Vector(0,0), nil):ToPickup()
					two.AutoUpdatePrice = false
					two.Price = PickupPrice.PRICE_ONE_HEART
					spawn = true
				elseif i > 100 then
					two = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetItemIdByName("Breakfast"), Vector(440,200), Vector(0,0), nil):ToPickup()
					two.AutoUpdatePrice = false
					two.Price = PickupPrice.PRICE_ONE_HEART
					spawn = true
				else
					i = i+1
				end
			end
		end
	end
end


mod1544C:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod1544C.Init)
mod1544C:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod1544C.onNewLevel)
mod1544C:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod1544C.onUpdate)
mod1544C:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod1544C.onCache)
mod1544C:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod1544C.onFireTear)
mod1544C:AddCallback(ModCallbacks.MC_USE_ITEM, mod1544C.ActivateEnergizer, mod1544C.COLLECTIBLE_ENERGIZER)
mod1544C:AddCallback(ModCallbacks.MC_USE_ITEM, mod1544C.ActivateDontHickey, mod1544C.COLLECTIBLE_DONT_HICKEY)
mod1544C:AddCallback(ModCallbacks.MC_USE_ITEM, mod1544C.ActivateTechProto, mod1544C.COLLECTIBLE_TECHNOLOGY_PROTO)
mod1544C:AddCallback(ModCallbacks.MC_USE_ITEM, mod1544C.ActivateFabricator, mod1544C.COLLECTIBLE_FABRICATOR)
mod1544C:AddCallback(ModCallbacks.MC_USE_ITEM, mod1544C.ActivateOverclocker, mod1544C.COLLECTIBLE_OVERCLOCKER)
mod1544C:AddCallback(ModCallbacks.MC_USE_ITEM, mod1544C.ActivateUpgrade, mod1544C.COLLECTIBLE_UPGRADE)
mod1544C:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod1544C.onUseItem)
mod1544C:AddCallback(ModCallbacks.MC_POST_RENDER , mod1544C.onRender)
mod1544C:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod1544C.onInput)
mod1544C:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod1544C.onPickup)
mod1544C:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod1544C.TakeDamage, EntityType.ENTITY_PLAYER)
mod1544C:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod1544C.SaveState)