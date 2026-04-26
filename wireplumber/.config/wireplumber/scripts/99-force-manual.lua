rule = {
	matches = {
		{
			{ "node.name", "matches", "rcp_*" },
		},
	},
	apply_properties = {
		["node.passive"] = false,
		["node.want-driver"] = true,
		["node.always-process"] = true,
		["priority.session"] = 3000,
	},
}

table.insert(common_utils.global_rules, rule)
