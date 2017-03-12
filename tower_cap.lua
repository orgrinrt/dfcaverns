-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--stem
minetest.register_node("dfcaverns:tower_cap_stem", {
	description = S("Tower Cap Stem"),
	tiles = {"dfcaverns_tower_cap.png"},
	is_ground_content = true,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
})

--cap
minetest.register_node("dfcaverns:tower_cap", {
	description = S("Tower Cap"),
	tiles = {"dfcaverns_tower_cap.png"},
	is_ground_content = true,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
})

--gills
minetest.register_node("dfcaverns:tower_cap_gills", {
	description = S("Tower Cap Gills"),
	tiles = {"dfcaverns_tower_cap_gills.png"},
	is_ground_content = true,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	sounds = default.node_sound_leaves_defaults(),
	drawtype = "plantlike",
	paramtype = "light",
	drop = {
		max_items = 1,
		items = {
			{
				items = {'dfcaverns:tower_cap_sapling'},
				rarity = 20,
			},
			{
				items = {'dfcaverns:tower_cap_gills'},
			}
		}
	},
})

-- sapling
minetest.register_node("dfcaverns:tower_cap_sapling", {
	description = S("Tower Cap Spawn"),
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"dfcaverns_tower_cap_sapling.png"},
	inventory_image = "dfcaverns_tower_cap_sapling.png",
	wield_image = "dfcaverns_tower_cap_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1},
	sounds = default.node_sound_leaves_defaults(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(dfcaverns.config.tower_cap_min_growth_delay,dfcaverns.config.tower_cap_max_growth_delay))
	end,
	
	on_timer = function(pos)
		minetest.set_node(pos, {name="air"})
		dfcaverns.spawn_tower_cap(pos)
	end,
})

dfcaverns.spawn_tower_cap = function(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local stem_height = math.random(4,10)
	local cap_radius = math.random(4,6)
	local maxy = y + stem_height + 3
	
	local c_stem = minetest.get_content_id("dfcaverns:tower_cap_stem")
	local c_cap  = minetest.get_content_id("dfcaverns:tower_cap")
	local c_gills  = minetest.get_content_id("dfcaverns:tower_cap_gills")

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
		{x = x - cap_radius, y = y, z = z - cap_radius},
		{x = x + cap_radius, y = maxy + 3, z = z + cap_radius}
	)
	local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	subterrane:giant_shroom(area:indexp(pos), area, data, c_stem, c_cap, c_gills, stem_height, cap_radius)
	
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end