local _, addon = ...
local VotingFrame = addon:GetModule("RCVotingFrame")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

function VotingFrame:UpdateLootStatus ()
   -- Do nothing
end

-- We don't handle spec icons in classic
function VotingFrame.SetCellClass(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   -- The orignal function fetches the class from the lootTable with session, both of which we can't access.
   -- Luckily we only need the class, so we can fetch it from a random session:
   local class = VotingFrame:GetCandidateData(1, name, "class")
	addon.SetCellClassIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, class)
	data[realrow].cols[column].value = class or ""
end

function VotingFrame.SetCellVotes(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	frame:SetScript("OnEnter", function()
         local voters = VotingFrame:GetCandidateData(VotingFrame:GetCurrentSession(), name, "voters")

         -- for i = 1, GetNumGuildMembers() do
         --    local name, _, rankIndex = GetGuildRosterInfo(i) -- get info from all guild members
         --    if rankIndex + 1 <= val then -- if the member is the required rank, or above
         --       tinsert(self.db.profile.council, name) -- then insert them to the council
         --    end
         -- end
		if not addon.mldb.anonymousVoting or (db.showForML and addon.isMasterLooter) then
				addon:CreateTooltip(L["Voters"], unpack((function ()
					local ret = {}
					for i,name in ipairs(voters) do
						ret[i] = addon:GetUnitClassColoredName(name)
					end
					return ret
				end)()
			))
		end
	end)
   local votes = VotingFrame:GetCandidateData(VotingFrame:GetCurrentSession(), name, "votes")
	frame:SetScript("OnLeave", function() addon:HideTooltip() end)
   local rank_name = addon.guildRank
   local guild_ranks = addon:GetGuildRanks()
   if guild_ranks and guild_ranks[rank_name] > 4 then
      data[realrow].cols[column].value = votes -- Set the value for sorting reasons
      frame.text:SetText(votes)
   else
      frame.text:SetText("?")
      data[realrow].cols[column].value = 0 -- Don't background sort when we can't see the votes
   end
end