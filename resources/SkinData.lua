-- <pre>
local p = {}

local lib       = require('Модуль:Feature')
local color     = require('Модуль:Color')
local FN        = require('Модуль:Filename')
local IL        = require('Модуль:ImageLink')
local rusLib    = require('Модуль:RusLocalization')
local userError = require('Dev:User error')

function p.get(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local get       = require ("Модуль:SkinData/getter")
    local champion  = args["champion"]  or args[1]
    local skin      = args["skin"]      or args[2] or get.original(champion)
    local fieldname = args["fieldname"] or args[3]
    local output    = args["output"]    or args[4] or nil
    local preprocess= args["preprocess"] == true

    local result
    -- Внешние поля
    if(fieldname == "championID") then
    	return get.championID(champion)
    elseif(fieldname == "original") then
    	return get.original(champion)
    elseif(fieldname == "skins") then
    	result = get.skins(champion)
    	if(output == "csv") then
            return lib.tbl_concat{result}
        elseif(output == "custom") then
            return frame:preprocess(
            	lib.tbl_concat{
        			result,
        			prepend = args['prepend'],
        			append = args['append'],
        			separator = args['separator'],
        			index = args["index"]
            	}
            )
        elseif(output == "template") then
            return frame:preprocess(
            	lib.tbl_concat{
            		result,
            		prepend = "{{" .. args['t_name'] .. "|", append = "}}",
            		separator = args['separator']
            	}
            )
        else
        	return result
        end
    end

    if(get.skins(champion)[skin] == nil) then
    	return userError(
    		mw.ustring.format("Образ %s для чемпиона %s не найден в Модуль:SkinData/data/\"%s (eng)\"", skin, champion, champion),
    		"SkinData errors"
    	)
    end

    result = get[fieldname](champion, skin)

    if(output ~= nil and type(result) == "table") then
        if(output == "csv") then
            return lib.tbl_concat{result}
        elseif(output == "custom") then
        	result = lib.tbl_concat{
    			result,
    			prepend = args['prepend'],
    			append = args['append'],
    			separator = args['separator'],
    			index = args["index"]
    		}
        	if(preprocess) then
        		return frame:preprocess(result)
        	else
        		return result
        	end
        elseif output == "template" then
            return frame:preprocess(
            	lib.tbl_concat{
            		result,
            		prepend = "{{" .. args['t_name'] .. "|", append = "}}",
            		separator = args['separator']
            	}
            )
        end
    elseif result == nil then
        return ""
    else
        return result
    end
end

-- Генерирует блок с галереей цветовых схем
function p.chromagallery(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local skinData = p.collectAllSkins()

    local champion = args["champion"] or args[1]
    local skinName = args["skin"] or args[2] or p.get{champion, fieldname="original"}
    local formattedSkinName = p.get{champion, skinName, "name"}
    local currentSkinData = p.get{champion, skinName, "skins"}[skinName]
    if(currentSkinData == nil or currentSkinData.chromas == nil) then
        return userError(
        	mw.ustring.format(
        		"Цветовые схемы для образа %s чемпиона %s не найдены в Модуль:SkinData/data/\"%s (eng)\"",
        		skinName,
        		champion,
        		champion
        	),
        	"SkinData errors"
        )
    end

    local currentSkinChromas = currentSkinData.chromas

    local header = "Цветовые схемы"
    local frame = mw.getCurrentFrame()

    if(currentSkinData.forms ~= nil) then
        header = "Модели"
    end

    local chromaTable  = {}
    local chromaString = args["chromas"] or "true"
    if(chromaString == "true") then
        for chromaname in pairs(currentSkinChromas) do
            table.insert(chromaTable, chromaname)
        end
    else
        chromaTable = mw.text.split(chromaString, ",")
    end
    table.sort(chromaTable)
    local key        = args["key"] or "true"
    local IMAGE_WIDTH = "100px"

    local chromaExhibition = mw.html.create("div")
    chromaExhibition
    	:attr("id", "chromaexhibition")
    	:css("position", "relative")
    	:tag("span")
    		:css("font-weight", "bold")
    		:wikitext(mw.ustring.format("%s - %s", formattedSkinName, header))
    		:done()
    	:done()

    local glossaryNode = mw.html.create("div")
    if(key == "true" and header == "Цветовые схемы") then
    	glossaryNode
    		:attr("data-param", "Рамки цс")
    		:addClass("glossary")
    		:cssText("position:absolute; top:5px; right: 5px; z-index:20;")
    		:wikitext("[[File:Information.svg|30px|link=]]")
    		:newline()
    		:done()
    end

    local chromaGalleryNode = mw.html.create("div")
    chromaGalleryNode
    	:addClass(lib.ternary(#chromaTable > 8, "chroma-gallery-large", "chroma-gallery"))
    	:cssText("width:718px; text-align:center;")
    	:newline()
    	:tag("div")
    		:addClass("base")
			:wikitext(mw.ustring.format("[[File:%s|183px]]", FN.chroma{champion, skinName, "Обычная"}))
			:done()
    	:done()

	for i, chromaName in pairs(chromaTable) do
		if(currentSkinChromas[chromaName] == nil) then
            return userError(
            	mw.ustring.format(
            		"Цветовая схема %s не найдена в Модуль:SkinData/data/\"%s (eng)\" для образа %s чемпиона %s",
            		chromaName,
            		champion,
            		skinName,
            		champion),
            	"SkinData errors"
            )
        end

        local availability = currentSkinChromas[chromaName].availability or "Available"

        if(availability ~= "Canceled") then
        	local chromaNode = mw.html.create("div")
        	chromaNode
        		:tag("div")
        			:addClass("chroma")
        			:addClass(mw.ustring.lower(availability) .. "-border")
        			:wikitext(mw.ustring.format(
        				"[[File:%s|%s|border]]",
        				FN.chroma{champion, skinName, chromaName},
        				IMAGE_WIDTH)
        			)
        			:done()
        		:tag("div")
        			:addClass("chroma-caption")
        			:wikitext(chromaName)
        			:done()
        		:done()
        	chromaGalleryNode:node(chromaNode):newline()
        end
	end

	chromaExhibition
		:node(glossaryNode)
		:newline()
		:node(chromaGalleryNode)
		:newline()
		:allDone()
	return tostring(chromaExhibition)
end

-- Создает галерею загрузочных иллюстраций образов чемпиона
function p.getLoadings(frame)
    local function comp(a, b)
        local a = a[2].id or -1
        local b = b[2].id or -1
        if a < b then
            return true
        end
        return false
    end

    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local champion = args['champion'] or args[1]
    local size = args['size'] or args[2] or '150'

    local skins = skinData[champion].skins
    local wrapper = {}

    -- table.sort не умеет сортировать таблицы с нечисловыми индексами, так что костыль
    for k, v in pairs(skins) do
        table.insert(wrapper, {k, v})
    end

    table.sort(wrapper, comp)
    local loadings = {}
    for i, value in pairs(wrapper) do
        table.insert(loadings, mw.ustring.format("[[File:%s|%spx]]",
            tostring(FN.loading{
                ['champion'] = champion,
                ['skin'] = value[1]
            }),
            size
        ))
    end

    return table.concat(loadings, "")
end

-- Выдает линейку, к которой принадлежит образ (заменить на геттер)
function p.getSet(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local t = skinData[args[1]].skins[args[2] or rusLib.adjustOriginal(args[1])].set

    if t == nil then
        return nil
    elseif type(t) == 'string' then
        return t
    end
    local s
    for i, setname in ipairs(t) do
        if i ~= 1 then
            s = s .. ", " .. setname:gsub("% ", "&nbsp;")
        else
            s = setname
        end
    end

    return s
end

-- Выдает список линеек образа (заменить на геттер)
function p.getSetlist(frame)
    local championtable = {}
    local sets = {}
    local hash = {}
    local setList = mw.html.create('ul')

    setList:newline()

    for x in pairs(skinData) do
        table.insert(championtable, x)
    end
    table.sort(championtable)

    for _, championname in pairs(championtable) do
        local skintable  = {}
        for championname in pairs(skinData[championname]["skins"]) do
            table.insert(skintable, championname)
        end
        table.sort(skintable)

        for _, skinname in pairs(skintable) do
            local t = skinData[championname]["skins"][skinname]

            if t.set ~= nil then
                if type(t.set) == "table" then
                    for _, value in pairs(t.set) do
                        if (not hash[value]) then
                            table.insert(sets, value)
                            hash[value] = true
                        end
                    end
                else
                    if (not hash[t.set]) then
                        table.insert(sets, t.set)
                        hash[t.set] = true
                    end
                end
            end
        end
    end

    table.sort(sets)

    for _, setname in pairs(sets) do
        setList
            :tag('li')
                :wikitext('[[' .. setname .. ']]')
                :done()
            :done()
            :newline()
    end

    return setList
end

function p.getSetskins(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

	local skinData = collectAllSkins()
    local skinList = mw.html.create('ul')
    local championtable = {}
    local result = false

    skinList:newline()

    for x in pairs(skinData) do
        table.insert(championtable, x)
    end
    table.sort(championtable)

    for _, championname in pairs(championtable) do
        local skintable  = {}

        for championname in pairs(skinData[championname]["skins"]) do
            table.insert(skintable, championname)
        end
        table.sort(skintable)

        for _, skinname in pairs(skintable) do
            local hit = false
            local t = skinData[championname]["skins"][skinname]

            if t.set ~= nil then
                if type(t.set) == "table" then
                    for _, subset in pairs(t.set) do
                        if subset == args[1] then
                            hit = true
                            result = true
                        end
                    end
                else
                    if t.set == args[1] then
                        hit = true
                        result = true
                    end
                end
            end
            if hit == true then
                skinList
                    :tag('li')
                        :tag('span')
                            :addClass('skin-icon')
                            :attr('data-champion', championname)
                            :attr('data-skin', skinname)
                            :wikitext('[[File:' .. FN.championcircle({championname, skinname}) .. '|20px|link=' .. championname .. ']] [[' .. championname .. '|' .. lib.ternary(t["formatname"] ~= nil, t["formatname"], skinname .. " " .. championname) .. ']]')
                        :done()
                    :done()
                    :newline()
            end
        end
    end

    if result == false then
        skinList
            :tag('li')
                :wikitext('No match found for ' .. args[1] .. '.')
            :done()
            :newline()
    end

    return skinList
end

function p.getChromacount(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end
    local t = skinData[args[1]].skins[args[2] or rusLib.adjustOriginal(args['champion'] or args[1])].chromas
    local s = ""

    local chromatable  = {}
    for chromaname in pairs(t) do
        table.insert(chromatable, chromaname)
    end

    return #chromatable or "N/A"
end

-- Выдает список названий ЦС (заменить на геттер)
function p.getChromaNames(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local championName = lib.validateName(args["champion"] or args[1])
    local skinName = args["skin"] or args[2] or p.get{championName, fieldname="original"}

    -- Вся информация об хромах
    local chromas = p.get{championName, skinName, "chromas"}
    if(chromas == "") then
    	return ""
    end

    local chromaList = {}
    for chromaName in lib.pairsByAlphabeticalKeys(chromas) do
        table.insert(chromaList, chromaName)
    end

    return mw.text.listToText(chromaList, ", ")
end

-- Выдает имя формы (заменить на геттер)
function p.getFormnames(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end
    local t = skinData[args[1]].skins[args[2] or rusLib.adjustOriginal(args[1])].forms
    local s = ""

    local formtable  = {}
    for formname in pairs(t) do
        table.insert(formtable, formname)
    end
    table.sort(formtable)

    for i, formname in pairs(formtable) do
        if i ~= 1 then
            s = s  .. ", " .. formname
        else
            s = s .. formname
        end
    end

    return s
end

-- Выдает иконку формы (заменить на геттер)
function p.getFormicon(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    return skinData[args[1]].skins[args[2] or rusLib.adjustOriginal(args[1])].formicon
end

-- Создает список всех образов
function p.getAllSkinsTable()
	local allSkins = p.collectAllSkins()
    local lang = mw.language.new( "ru" )
    local html = require("Модуль:SimpleHTMLBuilder")

    --returns: cssClass (класс CSS), Symbol (значок), Sort Number (порядковый номер)
    local function generateAvailabilityBlock(availabilityEnum)
    	if(availabilityEnum == "Legacy") then
    		return "lol-full-skins-table-availability--legacy", "‒", 2
    	elseif(availabilityEnum == "Limited") then
    		return "lol-full-skins-table-availability--limited", "✘", 3
    	elseif(availabilityEnum == "Rare") then
    		return "lol-full-skins-table-availability--limited", "⭐", 4
    	elseif(availabilityEnum == "Upcoming") then
    		return "lol-full-skins-table-availability--upcoming", "⭘", 5
    	else
    		return "lol-full-skins-table-availability--available", "✔", 1
    	end
    end

    local function generateCostBlock(cost)
    	-- Образы за RP (150000 - Урфвик, 2000 - стандартное кол-во токенов события)
    	if(type(cost) ~= "number") then
    		return "Особая цена", "inherit"
    	elseif(cost >= 260 and cost < 150000 and cost ~= 2000) then
    		return cost, "gold"
    	else
    		-- Все остальные
    		return "Особая цена", "inherit"
    	end
    end

    local function generateMarkCell(skinFlag)
    	local markCell = html.create("td")
    	if(skinFlag) then
    		markCell
    			:addClass("lol-full-skins-table-green-mark")
    			:attr("data-sort-value", 1)
    			:wikitext("✔")
    			:done()
		else
    		markCell
    			:addClass("lol-full-skins-table-green-mark")
    			:attr("data-sort-value", 2)
    			:wikitext("&nbsp;")
    			:done()
    	end
    	return markCell
    end

    -- Иллюстрации иконок
    local ICON_AVAILABILITY = "[[File:Availability.png|20px|link=|]]"
    local ICON_RELEASE = "[[File:Release.png|20px|link=|]]"
    local ICON_COST = "[[File:RP icon.png|20px|link=|]]"
    local ICON_FILTER = "[[File:Voice filter.png|20px|link=|]]"
    local ICON_QUOTES = "[[File:Additional quotes.png|20px|link=|]]"
    local ICON_NEWVOICE = "[[File:New voice.png|20px|link=|]]"
    local ICON_EFFECTS = "[[File:New effects.png|20px|link=|]]"
    local ICON_ANIMATIONS = "[[File:New animations.png|20px|link=|]]"
    local ICON_TRANSFORM = "[[File:Transforming.png|20px|link=|]]"
    local ICON_CHROMA = "[[File:Chromaskins.png|20px|link=|]]"

    -- Блок таблицы и заглавная строка
    local skinTableBlock = html.create("table")
    skinTableBlock
        :addClass("sortable article-table lol-full-skins-table")
        :newline()
        :tag("tr")
            :tag("th")
            	:addClass("lol-full-skins-table--icon-header")
            	:done()
            :tag("th")
            	:addClass("lol-full-skins-table--name-header")
            	:wikitext("Название")
            	:done()
            :newline()
            :tag("th")
                :attr("data-sort-type", "number")
                :addClass("lol-full-skins-table--icon-header")
                :wikitext(ICON_AVAILABILITY)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--date")
                :attr("data-sort-type", "date")
                :wikitext(ICON_RELEASE)
            	:done()
            :newline()
            :tag("th")
                :attr("data-sort-type", "number")
                :addClass("lol-full-skins-table--icon-header")
                :wikitext(ICON_COST)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_FILTER)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_QUOTES)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_NEWVOICE)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_EFFECTS)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_ANIMATIONS)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_TRANSFORM)
            	:done()
            :newline()
            :tag("th")
                :addClass("lol-full-skins-table--icon-header")
                :attr("data-sort-type", "number")
                :wikitext(ICON_CHROMA)
            	:done()
        	:done()
        :newline()

        -- Основная таблица
        for champion, championData in lib.pairsByAlphabeticalKeys(allSkins) do
        	for skin, skinData in skinIter(championData["skins"]) do
        		-- Общие данные
        		local skinName = p.get{champion, skin, "name"}
        		local skinAvailability = p.get{champion, skin, "availability"}
        		local skinRelease = p.get{champion, skin, "release"}
        		local skinCost = p.get{champion, skin, "cost"}
        		local skinFilter = p.get{champion, skin, "filter"}
        		local skinQuotes = p.get{champion, skin, "newquotes"}
        		local skinNewVoice = p.get{champion, skin, "newvoice"}
        		local skinVisuals = p.get{champion, skin, "neweffects"}
        		local skinAnimations = p.get{champion, skin, "newanimations"}
        		local skinTransform = p.get{champion, skin, "transforming"}
        		local skinChromas = (p.get{champion, skin, "chromas"} ~= "")

        		-- Блок с символами доступности
        		local cssClass, availabilityMark, sortNumber = generateAvailabilityBlock(skinAvailability)
        		local availabilityCell = html.create("td")
        		availabilityCell
        			:addClass(cssClass)
        			:attr("data-sort-value", sortNumber)
        			:wikitext(availabilityMark)
        			:done()

        		-- Блок с ценой
        		local costText, costColor = generateCostBlock(skinCost)
        		local costCell = html.create("td")
        		costCell
        			:css("color", costColor)
        			:wikitext(costText)
        			:done()
	        	local skinTableRow = html.create("tr")
	        	skinTableRow
	        		:tag("td")
	        			:attr("data-sort-value", champion)
	        			:wikitext(tostring(IL.skin{
	                        ["champion"] = champion,
	                        ["skin"] = skin,
	                        ["text"] = "*none*",
	                        ["size"] = "64px",
	                        ["circle"] = "true"
						}))
						:done()
	        		:tag("td")
	        			:addClass("lol-full-skins-table--skin-name")
	        			:wikitext(skinName)
	        			:done()
					:node(availabilityCell)
					:tag("td")
						:wikitext(lang:formatDate("d.m.y", skinRelease) or "")
					:newline()
					:node(costCell)
					:newline()
					:node(generateMarkCell(skinFilter))
					:newline()
					:node(generateMarkCell(skinQuotes))
					:newline()
					:node(generateMarkCell(skinNewVoice))
					:newline()
					:node(generateMarkCell(skinVisuals))
					:newline()
					:node(generateMarkCell(skinAnimations))
					:newline()
					:node(generateMarkCell(skinTransform))
					:newline()
					:node(generateMarkCell(skinChromas))
					:newline()
					:done()
				skinTableBlock:node(skinTableRow)
			end
        end
    return tostring(skinTableBlock)
end

-- Выдает некоторое количество самых последних образов
function p.newestSkins(frame)
	local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

	local skinCount = tonumber(args[1]) or 6
	local skinData = p.collectAllSkins()
	-- Линеаризированная таблица-список образов
    local skinSequence = {}
    for championName, championValue in pairs(skinData) do
    	local championSkins = championValue["skins"]
    	local VALID_AVAILABILITY = {
    		["Available"] = true,
    		["Legacy"] = true,
    		["Rare"] = true,
    		["Limit"] = true,
    	}
    	for skinName, skinValue in pairs(championSkins) do
    		if(VALID_AVAILABILITY[skinValue.availability] and skinValue.engname ~= "Original") then
	    		table.insert(skinSequence, {
	    			["champion"] = championName,
	    			["skin"] = skinName,
	    			["release"] = skinValue["release"],
	    			["cost"] = skinValue["cost"]
	    		})
	    	end
    	end
    end

    -- Сравнивает по дате выхода. Если одинаковая, то сортирует по образу, затем по чемпиону
    local function compareByRelease(a, b)
    	if(a["release"] ~= b["release"]) then
    		return a["release"] > b["release"]
    	elseif(a["skin"] ~= b["skin"]) then
    		return a["skin"] < b["skin"]
    	elseif(a["champion"] ~= b["champion"]) then
    		return a["champion"] < b["champion"]
    	--[[else
    		local costA = a["cost"]
    		local costB = b["cost"]
    		if(tonumber(costA) ~= nil) then
    			if(tonumber(costB) ~= nil) then
    				return costA > tonumber(costB)
    			end

    		end
    		return true]]
    	end
		return false
    end
    table.sort(skinSequence, compareByRelease)
    mw.log(skinSequence[1]["champion"] .. " " .. skinSequence[1]["skin"])

    local index = 1
    local galleryNode = mw.html.create("div")
    galleryNode
    	:attr("id", "newskins")
    	:addClass("centered-flex portal__newest-skins-block")
    	:done()

    repeat
    	galleryNode:node(p.skinPortrait{
    		skinSequence[index]["champion"],
    		skinSequence[index]["skin"]
    	}):newline():done()
    	index = index + 1
    until(index > skinCount)
    return frame:preprocess(tostring(galleryNode))
end

function p.skinPortrait(frame)
	local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end
	local champion = args["champion"] or args[1]
	local skin = args["skin"] or args[2]
	local size = args["size"] or args[3] or "120px"
	local style = args["style"] or ""

	local currency = "RP"
	local cost = p.get{champion, skin, "cost"}
	local costText = ""
	if(tonumber(cost) ~= nil) then
		local numericalCost = tonumber(cost)
		if(numericalCost == 10) then currency = "Gems"
		elseif(numericalCost == 100) then currency = "ОП" end
	else
		currency = "special"
	end
	if(currency == "special") then
		costText = "Особая цена"
	else
		costText = mw.ustring.format("{{%s|%s}}", currency, tostring(cost))
	end

	local lang = mw.language.new("ru")
	local releaseDate = lang:formatDate("j xg", p.get{champion, skin, "release"})

	local portraitNode = mw.html.create("div")
	portraitNode
		:css("width", size)
		:cssText(style)
		:addClass("skin_portrait skin-icon")
		:attr("data-champion", champion)
		:attr("data-skin", skin)
		:wikitext(
			mw.ustring.format(
				"[[File:%s|%s|link=%s/Коллекция]]",
				FN.loading{champion, skin},
				size,
				champion
			)
		)
		:tag("p")
			:wikitext(mw.ustring.format("[[%s/Коллекция|%s]]", champion, p.get{champion, skin, "name"}))
			:done()
		:tag("div")
			:wikitext(costText)
			:done()
		:tag("div")
			:wikitext(releaseDate)
			:done()
		:done()

	return portraitNode
end

-- Создает каталог образов по чемпионам
function p.skinCatalog(frame)
	local skinData      = p.collectAllSkins()
    local dlib          = require("Dev:Datecalc")
    local lang          = mw.language.new( "ru" )
    local championtable = {}
    local skinTableBlock       = mw.html.create('table')

    skinTableBlock
        :addClass('sortable article-table novpadding hcpadding sticky-header')
        :css('width','100%')
        :css('text-align','center')
        :css('font-size','12px')
        :newline()
        :tag('tr')
            :tag('th')
                :css('font-size','12px')
                :css('width','140x')
                :wikitext('Чемпион')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "number")
                :wikitext('<div title="Доступны в магазине или через Хекстековое ремесло.">Доступные</div>')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "number")
                :wikitext('<div title="Доступны через Хекстековое ремесло или ограниченные распродажи.">Архивные</div>')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "number")
                :wikitext('<div title="Доступны периодически или могут быть получены при особых условиях.">Редкие</div>')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "number")
                :wikitext('Недоступные')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "number")
                :wikitext('Всего')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "isoDate")
                :wikitext('Последний образ')
            :done()
            :newline()
            :tag('th')
                :css('font-size','12px')
                :attr('data-sort-type', "number")
                :wikitext('Дней назад')
            :done()
            :newline()
        :done()
        :newline()

    for x in pairs(skinData) do
        table.insert(championtable, x)
    end
    table.sort(championtable)

    for _, championname in pairs(championtable) do
        local t              = skinData[championname]["skins"]
        local availablecount = 0
	    local availablecircles = ""
        local legacycount    = 0
	    local legacycircles = ""
        local limitedcount   = 0
	    local rarecircles = ""
        local rarecount   = 0
	    local limitedcircles = ""
        local result         = {"","",""}
        local sdnode         = mw.html.create('tr')
        local border         = ""
        local skintable      = {}

        for skinname in pairs(t) do
            if (skinname == "Классический"
                or
                skinname == "Классическая"
                or
                skinname == "Original"
                or
                championname == "Акали"      and skinname == "Алая"
                or
                championname == "Амуму"      and skinname == "Лоскутный хаос"
                or
                championname == "Блицкранк" and skinname == "Лоскутный хаос"
                or
                championname == "Райз"       and skinname == "Человек"
            ) then
                -- skip
            else
                table.insert(skintable, skinname)
            end
        end
        table.sort(skintable, function(a, b) return t[a].release<t[b].release end)

        for i, skinname in pairs(skintable) do
            if i == #skintable then
                border = "border-radius:13px; width:26px; height:26px; box-shadow: 0 0 2px 2px #70fff2, 0 0 4px #111;"
            end

            if t[skinname].availability == "Available" then
                availablecount = availablecount + 1
                availablecircles = availablecircles .. '<li class="skin-icon" data-champion="' .. championname ..'" data-skin="' .. skinname .. '" style="'.. border ..'">[[File:' .. FN.championcircle({championname, skinname}) .. '|26px|link=]]'
            end
            if t[skinname].availability == "Legacy" then
                legacycount    = legacycount    + 1
                legacycircles = legacycircles .. '<li class="skin-icon" data-champion="' .. championname ..'" data-skin="' .. skinname .. '" style="'.. border ..'">[[File:' .. FN.championcircle({championname, skinname}) .. '|26px|link=]]'
            end
            if t[skinname].availability == "Rare" then
                rarecount    = rarecount    + 1
                rarecircles = rarecircles .. '<li class="skin-icon" data-champion="' .. championname ..'" data-skin="' .. skinname .. '" style="'.. border ..'">[[File:' .. FN.championcircle({championname, skinname}) .. '|26px|link=]]'
            end
            if t[skinname].availability == "Limited" then
                limitedcount   = limitedcount   + 1
                limitedcircles = limitedcircles .. '<li class="skin-icon" data-champion="' .. championname ..'" data-skin="' .. skinname .. '" style="'.. border ..'">[[File:' .. FN.championcircle({championname, skinname}) .. '|26px|link=]]'
            end

            if t[skinname].release ~= "N/A" then
                if t[skinname].release > result[2] then
                    result[1] = skinname
                    result[2] = t[skinname].release
                    result[3] = t[skinname].formatname
                end
            end
        end

        sdnode
            :tag('td')
                :addClass('skin-icon')
                :attr('data-sort-value', championname)
                :attr('data-champion', championname)
                :attr('data-skin', rusLib.adjustOriginal(championname))
                :css('text-align', 'left')
                :wikitext('[[File:' .. FN.championcircle({championname, rusLib.adjustOriginal(championname)}) .. '|26px|link=' .. championname .. ']] ' .. championname)
            :done()

        -- Available skins
        sdnode
            :tag('td')
                :addClass('icon_list')
                :attr('data-sort-value', availablecount)
                :css('text-align', 'left')
                :css('background-color', '#0a1827')
                :wikitext(availablecircles)
            :done()

        -- Legacy skins
        sdnode
            :tag('td')
                :addClass('icon_list')
                :attr('data-sort-value', legacycount)
                :css('text-align', 'left')
                :wikitext(legacycircles)
            :done()

        -- Rare skins
        sdnode
            :tag('td')
                :addClass('icon_list')
                :attr('data-sort-value', rarecount)
                :css('text-align', 'left')
                :css('background-color', '#0a1827')
                :wikitext(rarecircles)
            :done()

        -- Limited skins
        sdnode
            :tag('td')
                :addClass('icon_list')
                :attr('data-sort-value', limitedcount)
                :css('text-align', 'left')
                :wikitext(limitedcircles)
            :done()

        -- Total

        sdnode
            :tag('td')
                :wikitext(availablecount + legacycount + rarecount + limitedcount)
            :done()

        -- Last Skin
        local y, m, d = result[2]:match("(%d+)-(%d+)-(%d+)")
        if y == nil or m == nil or d == nil then
            sdnode
                :tag('td')
                    :addClass('skin-icon')
                    :css('white-space', 'nowrap')
                    :attr('data-sort-value', result[2])
                    :attr('data-champion', championname)
                    :attr('data-skin', result[1])
                    :wikitext(result[2])
                :done()
                :tag('td')
                    :wikitext(result[2])
                :done()
        else
            sdnode
                :tag('td')
                    :addClass('skin-icon')
                    :css('white-space', 'nowrap')
                    :attr('data-sort-value', result[2])
                    :attr('data-champion', championname)
                    :attr('data-skin', result[1])
                    :wikitext(lang:formatDate('d-m-Y', result[2]))
                :done()
                :tag('td')
                    :wikitext(dlib.main{"diff", lang:formatDate('Y-m-d'), result[2]})
                :done()
        end

        -- Add skin row to the table
        skinTableBlock
            :newline()
            :node(sdnode)
    end

    return skinTableBlock
end

-- Задает описание всплывающей подсказки с образом
function p.skintooltip(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local championname = args["champion"]
    local skinname     = args["skin"] or p.get{championname, "Original", "original"}
    local variant      = args["variant"]
    local filename     = FN.skin{championname, skinname, variant}
    local formatname   = p.get{championname, skinname, "name"}
    local cost         = p.get{championname, skinname, "cost"}
    local distribution = p.get{championname, skinname, "distribution"}
    local lore         = p.get{championname, skinname, "lore"}
    local filter       = p.get{championname, skinname, "filter"}
    local newquotes    = p.get{championname, skinname, "newquotes"}
    local newvoice     = p.get{championname, skinname, "newvoice"}
    local neweffects   = p.get{championname, skinname, "neweffects"}
    local newrecall    = p.get{championname, skinname, "newrecall"}
    local newanimations= p.get{championname, skinname, "newanimations"}
    local transforming = p.get{championname, skinname, "transforming"}
    local extras       = p.get{championname, skinname, "extras"}
    local chromas      = p.get{championname, skinname, "chromas"}
    local variantof    = p.get{championname, skinname, "variant"}
    local voiceactor   = p.get{
    	championname,
    	skinname,
    	"voiceactor",
    	output = "custom",
    	separator = ",&nbsp;",
    	preprocess = false
    }
    local splashartist = p.get{
    	championname,
    	skinname,
    	"splashartist",
    	output = "custom",
    	separator = ",&nbsp;",
    	preprocess = false
    }
    local set = p.get{
    	championname,
    	skinname,
    	"set",
    	output = "custom",
    	separator = ",&nbsp;",
    	preprocess = false
    }

    local ACTOR_ICON = "[[File:Actor.png|20px|link=]]"
    local ARTIST_ICON = "[[File:Artist.png|20px|link=]]"
    local SET_ICON = "[[File:Set piece.png|20px|link=]]"

    -- Заголовок подписи
    local nameText = formatname
    if(variant ~= nil) then
    	nameText = nameText .. mw.ustring.format("&nbsp;<small>(%s)</small>", variant)
    end

    local costText = ""
    if(type(cost) ~= "number") then
    	costText = "Особая цена"
    elseif(cost == 10) then
    	costText = "[[Файл:ME icon.png|20px|link=Самоцвет]] 10"
    elseif(cost == 100) then
    	costText = "[[Файл:Hextech Crafting Prestige token.png|20px|link=Очки престижа|alt=ОП]] 100"
    elseif(cost == 150000) then
    	costText = "Ограниченное издание ([[Файл:BE icon.png|20px|link=Синяя эссенция]] 150000)"
    else
    	costText = "[[File:RP icon.png|20px|link=RP|alt=RP]] " .. cost
    end

    local skinFeaturesHeader = mw.html.create("div")
    skinFeaturesHeader
    	:addClass("lol-skin-banner-features-header")
    	:tag("span")
    		:addClass("lol-skin-banner-features-header__name")
    		:wikitext(formatname)
    		:done()
    	:tag("span")
    		:wikitext("&nbsp; – ")
    		:done()
    	:tag("span")
    		:addClass("lol-skin-banner-features-header__cost")
    		:wikitext(costText)
    		:done()
    	:newline()
    	:done()

    -- Озвучивание, художники и вселенная
    local skinFeaturesCreators = mw.html.create("div")
    skinFeaturesCreators:addClass("lol-skin-banner-features-creators")
    if(voiceactor ~= "") then
    	skinFeaturesCreators
	    	:tag("div")
	    		:wikitext(ACTOR_ICON .. voiceactor)
	    		:done()
	    	:newline()
	    	:done()
    end
    if(splashartist ~= "") then
    	skinFeaturesCreators
	    	:tag("div")
	    		:wikitext(ARTIST_ICON .. splashartist)
	    		:done()
	    	:newline()
    		:done()
    end
    if(set ~= "") then
	    skinFeaturesCreators
	    	:tag("div")
	    		:wikitext(SET_ICON .. set)
	    		:done()
	    	:newline()
    		:done()
    end

    local tooltipBlock = mw.html.create("div")
    tooltipBlock
    	:addClass("lol-skin-banner-image")
    	:wikitext(mw.ustring.format("[[Файл:%s|700px]]", filename))
    	:tag("div")
    		:addClass("lol-skin-banner-features")
    		:node(skinFeaturesHeader)
    		:node(skinFeaturesCreators)
    		:tag("div")
    			:addClass("lol-skin-banner-features-lore")
    			:wikitext(lore)
    			:done()
    		:done()
    	:done()

    return tostring(tooltipBlock)
end

-- Создает таблицу актеров озвучки чемпионов
function p.getVoiceActorRoster()
	local skinData = p.collectAllSkins()
	local deceased = mw.loadData("Модуль:SkinData/deceased")
	local DECEASED_MARK = "&nbsp;&#8224;"

	local function concatenateActorList(actorList)
		local result = ""
		for i, actorName in ipairs(actorList) do
        	result = result .. actorName
        	if(lib.find(deceased, actorName) ~= -1) then
        		result = result .. DECEASED_MARK
        	end
        	if(i < #actorList) then
        		result = result .. ", "
        	end
		end
    	return result
	end

    local tableNode = mw.html.create("table")
    tableNode
        :addClass("sortable article-table lol-voiceactors-table")
        :newline()
        :tag("tr")
            :tag("th")
            	:addClass("lol-voiceactors-table__champion")
                :wikitext("Чемпион")
                :done()
            :tag("th")
            	:addClass("lol-voiceactors-table__voice")
                :wikitext("Актер дубляжа")
                :done()
            :done()
        :newline()

    for champion, v in lib.pairsByAlphabeticalKeys(skinData) do
    	local original = _getSkinById(champion, 0) -- Образ с ID = 0 и есть Классический
        local defaultActorList = lib.cloneTable(v["skins"][original]["voiceactor"])
        local formattedDefaultActor = ""

        if(defaultActorList ~= nil) then
            formattedDefaultActor = concatenateActorList(defaultActorList)
        else
        	formattedDefaultActor = "Неизвестный актер озвучки"
        end

        -- Формируем строку таблицы
        local rowNode = mw.html.create("tr")
        rowNode
            :tag("td")
            	:addClass("lol-voiceactors-table__champion")
                :attr("data-sort-value", champion)
                :wikitext(tostring(IL.champion{
                    ["champion"] = champion,
                    ["skin"] = original,
                    ["circle"] = "true",
                    ["link"] = champion .. "/LoL/Фразы"
                }))
            :done()
            :tag("td")
            	:addClass("lol-voiceactors-table__voice")
                :wikitext(formattedDefaultActor)
                :done()
            :newline()

        tableNode:node(rowNode):newline()

        for skinName, skinValue in pairs(v["skins"]) do
            if(skinValue["voiceactor"] ~= nil) then
            	local currentActorList = lib.cloneTable(skinValue["voiceactor"])
            	local formattedCurrentActor = concatenateActorList(currentActorList)
                if(lib.tbl_concat{currentActorList} ~= lib.tbl_concat{defaultActorList}) then
                    local skinNode = mw.html.create("tr")
                    skinNode
                        :tag("td")
            				:addClass("lol-voiceactors-table__champion")
                            :attr("data-sort-value", champion)
                            :wikitext(tostring(IL.champion{
                                ["champion"] = champion,
                                ["skin"] = skinName,
                                ["text"] = p.get{champion, skinName, "name"},
                                ["circle"] = "true",
                    			["link"] = champion .. "/LoL/Фразы"
                                }))
                            :done()
                        :tag("td")
            				:addClass("lol-voiceactors-table__voice")
                            :wikitext(formattedCurrentActor)
                            :done()
                        :newline()
                    tableNode:node(skinNode):newline()
                end
            end
        end
    end

    return tostring(tableNode)
end

-- Выводит стилизованную галерею образов чемпионов с меню выбора текущего образа для просмотра
-- Автор оригинала: de:Benutzer:TheTimebreaker (редактор немецкой Вики по League of Legends)
function p.skinSlider(frame)
    local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

    local championData = require("Модуль:ChampionData")
    local lang = mw.language.new("ru")

    local championName = lib.validateName(args["champion"] or args[1] or mw.title.getCurrentTitle().rootText)

    local t = p.get{championName, "Original" , "skins"}
    local apiName = championData.get{championName, "apiname"}
    local engName = championData.get{championName, "engname"}
    local futureSkins = {}

    local skinSliderContainer = mw.html.create("div"):addClass("lazyimg-wrapper")

    local navigationBlock = mw.html.create("div")
        :addClass("lol-skinslider-navigation")
        :addClass("hidden")
        :done()

    local sliderTabBlock = mw.html.create("div")
    sliderTabBlock
    	:addClass("skinviewer-tab-container")
    	:addClass("lol-skinslider-slider")
    	:done()

    for k, v, i in skinIter(t) do
    	local skinFullName = p.get{championName, k, "name"}
        local releaseDate = ""
        if(v["release"] == "N/A") then
        	releaseDate = v["release"]
        else
        	releaseDate = lang:formatDate("d-m-Y", v["release"])
        end

        local costText = ""
        local priceTitle = ""
        if(type(v["cost"]) ~= "number") then
        	costText = "Особая цена"
        	priceTitle = v['distribution'] and v['distribution'] or "Этот образ нельзя приобрести за игровую валюту"
        elseif(v["cost"] == 10) then
        	costText = "[[Файл:ME icon.png|20px|link=Самоцвет]] 10"
            priceTitle = "Этот образ можно приобрести в системе Хекстекового ремесла."
        elseif(v["cost"] == 100) then
        	costText = "[[Файл:Hextech Crafting Prestige token.png|20px|link=Очки престижа|alt=ОП]] 100"
            priceTitle = "Этот образ можно купить за Очки престижа в системе Хекстекового ремесла."
        elseif(v["cost"] == 150000) then
        	costText = "Ограниченное издание ([[Файл:BE icon.png|20px|link=Синяя эссенция]] 150000)"
            priceTitle = "Этот образ можно было приобрести во время особенного события."
        else
        	costText = "[[File:RP icon.png|20px|link=RP|alt=RP]] " .. v["cost"]
            priceTitle = "Этот образ можно купить за RP по обычным правилам."
        end

        if(v["availability"] == "Upcoming") then
            table.insert(futureSkins, {k, v, i})
        else
        	local chromaBlockText = v["chromas"] and "[[File:Chromaskins.png|x60px||link=]]" or ""
        	local skinIcon = mw.ustring.format("[[Файл:%s||link=|x56px]]", FN.championcircle({ championName, k }))

        	-- Переключатель образов (ряд круглых иконок)
            navigationBlock
                :tag("span")
                    :attr("id", i)
                    :addClass("show")
                    :addClass("lol-skinslider-navigation__chroma-icon")
                    :wikitext(chromaBlockText)
                    :tag("span")
                        :attr("title", skinFullName)
                    	:addClass("lol-skinslider-navigation__skin-icon")
                        :wikitext(skinIcon)
                        :done()
                    :done()
                :done()

            -- Изображение
            local skinImageBlock = mw.html.create("div")
            skinImageBlock
            	:addClass("lol-skinslider-skin__image")
            	:wikitext(mw.ustring.format("[[Файл:%s||link=|]]", FN.skin({ championName, k })))
            	:done()

            -- Цена образа
            local priceBlock = mw.html.create("div")
	        priceBlock
	        	:addClass("lol-skinslider-skin__price")
	        	:attr("title", priceTitle)
	        	:wikitext(costText)
	        	:done()

            -- Кнопка "Посмотреть в 3D"
            local skinCaptionBlock3DLink = mw.html.create("div")
            local linkButton = mw.html.create("span")
            linkButton
            	:attr("title", "Посмотреть модель")
            	:addClass("button-gold")
            	:wikitext("'''3D модель'''")
            	:done()

            local teemoLink = mw.ustring.format(
            	"[https://teemo.gg/model-viewer?game=league-of-legends&type=champions&object=%s&skinid=%s-%s %s]",
            	apiName,
            	string.lower(apiName),
            	i - 1,
            	tostring(linkButton)
            )
            skinCaptionBlock3DLink
            	:addClass("lol-skinslider-skin__caption__3dbutton")
            	:tag("span")
            		:addClass("plainlinks")
            		:wikitext(teemoLink)
            		:done()
            	:done()

            -- Название образа в центре подписи
            local skinCaptionBlockText = mw.html.create("div")
            skinCaptionBlockText
            	:addClass("lol-skinslider-skin__caption__text")
            	:wikitext(skinFullName)
            	:done()

            -- Дата выхода образа
            local skinCaptionBlockRelease = mw.html.create("div")
            skinCaptionBlockRelease
            	:addClass("lol-skinslider-skin__caption__release")
            	:wikitext(releaseDate)
            	:done()

            -- Блок подписи - сборка компонентов
            local skinCaptionBlock = mw.html.create("div")
            skinCaptionBlock
            	:addClass("lol-skinslider-skin__caption")
            	:node(skinCaptionBlock3DLink)
            	:node(skinCaptionBlockText)
            	:node(skinCaptionBlockRelease)

            -- Блок информации
            -- Блок информации - лорное описание
            local skinInfoLore = mw.html.create("div")
            local skinInfoLoreText = ""
            if(v["lore"]) then
            	skinInfoLoreText = v["lore"]
            end
            skinInfoLore
            	:addClass("lol-skinslider-info__lore")
            	:wikitext(skinInfoLoreText)
            	:done()

            -- Блок информации - малые иконки
            local voiceActors = v["voiceactor"] -- table
            local voiceActorText = "Неизвестный актер озвучки"
            if(voiceActors ~= nil) then
	            voiceActorText = "[[File:Actor.png|20px|link=]]" .. lib.tbl_concat{
	            	voiceActors,
	            	["prepend"] = "[[Актеры озвучивания|",
	            	["append"] = "]]",
	            	["separator"] = ",&nbsp;"
	            }
	        end

            local splashArtists = v["splashartist"] -- table
            local splashArtistText = ""
            if(splashArtists ~= nil) then
	            splashArtistText = "[[File:Artist.png|20px|link=]]" .. lib.tbl_concat{
	            	splashArtists,
	            	["separator"] = ",&nbsp;"
	            }
	        end

            local sets = v["set"] -- table
            local setText = ""
            if(sets ~= nil) then
            	setText = "[[File:Set piece.png|20px|link=]][[" .. sets[1] .. "]]"
            end

            local isLootEligible = v["looteligible"] -- boolean
            local lootText = ""
            if(isLootEligible == false) then
            	lootText = "[[File:Loot ineligible.png|20px|link=]] Не выпадает из сундуков"
            else
            	lootText = "[[File:Loot eligible.png|20px|link=]] [[Хекстековое ремесло|Выпадает из Хекстекового сундука]]"
            end

            local skinInfoSmallIcons = mw.html.create("div")
            skinInfoSmallIcons
            	:addClass("lol-skinslider-info__small-icons")
            	:addClass("hideHyperlinkColor")
            	:tag("div")
            		:wikitext(voiceActorText)
            		:done()
            	:tag("div")
            		:wikitext(splashArtistText)
            		:done()
            	:tag("div")
            		:wikitext(setText)
            		:done()
            	:tag("div")
            		:wikitext(lootText)
            		:done()
            	:done()


            -- Блок информации - крупные иконки
            local skinInfoLargeIcons = mw.html.create("div")
            skinInfoLargeIcons
            	:addClass("lol-skinslider-info__large-icons")
            	:done()

            -- Функция для генерации большой иконки и подписи под ней
            local function generateLargeIcon(imageLink, imageCaption)
            	local largeIconNode = mw.html.create("div")
            	largeIconNode
	            	:addClass("lol-skinslider-info__large-icons__element")
            			:tag("div")
            				:wikitext(imageLink)
            				:done()
            			:tag("div")
            				:wikitext(imageCaption)
            				:done()
            			:done()
            		:done()
	            return largeIconNode
            end

            if(v["availability"] == "Legacy") then
            	local availabilityNode = generateLargeIcon(
            		"[[File:Limited skin.png|50px|link=]]",
            		"Архив"
            	)
            	skinInfoLargeIcons:node(availabilityNode)
            elseif(v["availability"] == "Limited") then
            	local availabilityNode = generateLargeIcon(
            		"[[File:Limited skin.png|50px|link=]]",
            		"Ограниченное издание"
            	)
            	skinInfoLargeIcons:node(availabilityNode)
            end
            if(v["filter"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:Voice filter.png|50px|link=]]",
	            		"Фильтр голоса"
            		))
            end
            if(v["newquotes"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:Additional quotes.png|50px|link=]]",
	            		"Дополнительные фразы"
            		))
            end
            if(v["newvoice"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:New voice.png|50px|link=]]",
	            		"Новая озвучка"
            		))
            end

            if(v["neweffects"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:New effects.png|50px|link=]]",
	            		"Новые эффекты"
            		))
            end
            if(v["newanimations"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:New animations.png|50px|link=]]",
	            		"Новые анимации"
            		))
            end
            if(v["transforming"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:Transforming.png|50px|link=]]",
	            		"Несколько форм"
            		))
            end
            if(v["extras"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:Includes extras.png|50px|link=]]",
	            		"Дополнительные материалы"
            		))
            end
            if(v["chromas"] ~= nil) then
            	skinInfoLargeIcons
            		:node(generateLargeIcon(
	            		"[[File:Chromas available.png|50px|link=]]",
	            		"Цв. схемы"
            		))
            end

            local skinInfoBlock = mw.html.create("div")
            skinInfoBlock
            	:addClass("lol-skinslider-info")
            	:node(skinInfoLore)
            	:node(skinInfoSmallIcons)
            	:node(skinInfoLargeIcons)
            	:done()

            -- Блок информации - текст про вариацию образа (если есть)
            if(v["variant"] ~= nil) then
            	local skinInfoVariantOf = mw.html.create("div")
            	local variantOfText = "Этот образ является вариацией образа " .. tostring(IL.skin{
            			champion = championName,
            			skin = _getSkinById(championName, v["variant"]),
            			circle = "true",
            			link = '*none*',
            			engname = engName
            		})
            	skinInfoVariantOf
            		:addClass("lol-skinslider-info__variant-of")
            		:wikitext(variantOfText)
            		:done()

            	skinInfoBlock
            		:node(skinInfoVariantOf)
            		:done()
            end

            -- Блок изображения образа с названием и ценой
            local sliderSkinBlock = mw.html.create("div")
            sliderSkinBlock
            	:addClass("skinviewer-tab-skin")
            	:addClass("lol-skinslider-skin")
                :node(skinImageBlock)
                :node(priceBlock)
                :node(skinCaptionBlock)
                :done()

            -- Блок с цветовыми схемами
            local sliderChromasBlock = mw.html.create("div")
            sliderChromasBlock
            	:addClass("lol-skinslider-chromas")
            	:wikitext(v["chromas"] and p.chromagallery{championName, k} or "")
				:done()

			-- Блок с дополнительными иллюстрациями
			local sliderGalleryBlock = mw.html.create("div")
			sliderGalleryBlock
				:tag("span")
		    		:css("font-weight", "bold")
		    		:wikitext(mw.ustring.format("Форматы образа"))
		    		:done()
		    	:tag("div") -- Вложенный div нужен, чтобы span-заголовок не попадал в flex-box
					:addClass("lol-skinslider-gallery")
					:tag("div")
						:addClass("lol-skinslider-gallery__centered")
						:tag("div")
							:wikitext(mw.ustring.format("[[Файл:%s]]", FN.centered{ championName, k }))
							:done()
						:tag("div")
							:addClass("lol-skinslider-gallery__caption")
							:wikitext("Центрированный")
							:done()
						:done()
					:tag("div")
						:addClass("lol-skinslider-gallery__loading")
						:tag("div")
							:wikitext(mw.ustring.format("[[Файл:%s]]", FN.loading{ championName, k }))
							:done()
						:tag("div")
							:addClass("lol-skinslider-gallery__caption")
							:wikitext("Экран загрузки")
							:done()
						:done()
				:done()

            -- Блок одного слайда образа (со всей информацией)
            local sliderElementBlock = mw.html.create("div")
            sliderElementBlock
                :addClass("skinviewer-tab-content")
                :addClass(i == 1 and "skinviewer-active-tab" or "")
                :attr("id", "item-" .. i)
                :css("display", i ~= 1 and "none" or "block")
                :node(sliderSkinBlock)
                :node(skinInfoBlock)
                :node(sliderGalleryBlock)
                :node(sliderChromasBlock)
            	:done()

            sliderTabBlock
                :node(sliderElementBlock)
                :done()
        end
    end

    local resultContainer = skinSliderContainer:node(navigationBlock):node(sliderTabBlock)

    if(#futureSkins > 0) then
        local futureSkinsNode = mw.html.create('div')
        futureSkinsNode
            :tag('h2')
                :wikitext('Будущие')
                :done()
            :done()

        for i, fskin in ipairs(futureSkins) do
            local imageNode = mw.html.create('div')
            imageNode
                :cssText('display:inline-block; margin:5px; width:342px')
                :wikitext(mw.ustring.format(
                    "[[File:%s|340px|border]]",
                    FN.skin{championName, fskin[1]}
                    ))
                :tag('div')
                    :cssText('text-align:center; font-size:90%;')
                    :wikitext(p.get{championName, fskin[1], "name"})
                :done()
            futureSkinsNode
                :node(imageNode)
                :tag('div')
                    :addClass('skinviewer-tab-chroma')
                    :wikitext(fskin[2]['chromas'] and p.chromagallery{championName, fskin[1]} or '')
                    :done()
                :done()
        end

        resultContainer:node(futureSkinsNode)
    end

    return resultContainer
end

-- Генерирует стандартную надпись на странице озвучки чемпиона по указанному имени чемпиона
function p.getSkinQuotesCaption(frame)
	local args; if frame.args == nil then args = lib.arguments(frame) else args = lib.arguments(frame.args) end

	local champion = args["champion"] or args[1]
    local append = args["append"] or
        "Указанные образы обладают дополнительными звуковыми эффектами: наложенными фильтрами или новыми репликами, - но в общем случае используют озвучку Классического образа."
	if(champion == nil) then
		return userError("Чемпион не найден", "SkinData errors")
	end

	local engnames = mw.loadData("Модуль:ChampionData/engnames")
	local championEngname = engnames[champion]
	if(championEngname == nil) then
		return userError("Чемпион " .. champion .. " не указан в Модуль:ChampionData/engnames", "SkinData errors")
	end
	local skinData = mw.loadData("Модуль:SkinData/data/" .. championEngname)
	local championData = skinData[champion]
    if(championData == nil) then
        return userError("Чемпион " .. " не найден в Модуль:SkinData/data", "SkinData errors")
    end

    local filteredSkins = {}

    for k, v in skinIter(championData["skins"]) do
        repeat
            if(v.newvoice == true) then break end
            if(v.filter or v.newquotes --[[or v.neweffects--]] or (v.id == 0)) then
                table.insert(filteredSkins, k)
            end
            break
        until true
    end

    local blockNode = mw.html.create("div")
    blockNode
        :addClass("lol-quotes-caption")
        :tag("div")
            :addClass("lol-quotes-caption-prepended-text")
            :wikitext("Условные обозначения")
            :done()
        :newline()
        :done()

    for i, v in ipairs(filteredSkins) do
        local flexNode = mw.html.create("div")
        flexNode
            :addClass("lol-quotes-caption-node")
            :wikitext(tostring(IL.skin{
                ["champion"] = champion,
                ["engname"] = championEngname,
                ["skin"] = v,
                ["circle"] = "true",
                ["link"] = champion .. "/LoL/Фразы",
                ["text"] = v,
                ["size"] = "36px"
            }))
            :done()
        :newline()
        blockNode:node(flexNode)
    end

    blockNode
        :tag("div")
            :addClass("lol-quotes-caption-appended-text")
            :wikitext(append)
            :done()
        :done()

    return tostring(blockNode)
end

-- Input: "skins" Tabelle eines Champs in Modul:SkinData/data
-- Output: Iterator über nach Skin-ID sortierte Tabelle mit 3 nutzbaren return values:
    -- k, v, i -> Key, Value -> Iterationszähler i -> Bsp Ahri: Standard Ahri   table   1
        -- table ist die Tabelle aus "skins" hinter dem Key ["Standard Ahri"]
    -- Nutzungsmögl.: for k, v, i in skinIter(t) - for k, v in skinIter(t) - for k in skinIter(t)
    -- entfernte skins werden aktuell übersprungen (sollte vllt an und ausschaltbar sein)
function skinIter(t)
    local keys = {}
    for k in pairs(t) do
        if t[k]['id'] ~= nil then
            keys[#keys+1] = k
        end
    end

    table.sort(keys, function(a,b) return t[a]['id'] < t[b]['id'] end)

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]], i
        end
    end
end

-- Замена шаблону SkinPortrait
function _skinPortrait(champion, skin, text, cost, currency, release)
    local portraitBlock = mw.html.create('div')
    portraitBlock
        :addClass('skin_portrait skin-icon')
        :css('width', '120px')
        :attr('data-champion', champion)
        :attr('data-skin', skin)
        :wikitext(mw.ustring.format(
            '[[Файл:%s|120px|link=%s/Коллекция]]',
            tostring(FN.loading{
                ['champion'] = champion,
                ['skin'] = skin
            }), champion))
        :tag('div')
            :wikitext(mw.ustring.format('[[%s/Коллекция|%s]]', champion, text))
            :done()
        :tag('div')
            :wikitext(lib.ternary(currency == 'none', 'Особая цена', mw.ustring.format('{{%s|%s}}', currency, cost)))
            :done()
        :tag('div')
            :tag('span')
                :addClass('date')
                :wikitext(release)
                :done()
            :done()
        :done()

    return tostring(portraitBlock)
end

-- Генерирует список цветовых схем, которые могут получить участники Партнерской программы
function p.chromapartner(frame)
    local s = ''

    s = s .. '<div id="chromaexhibition" style="position:relative">'
    s = s .. '<b>Эксклюзивные цветовые схемы</b>'
    s = s .. '<div class="chroma-gallery" style="width:718px; text-align:center">'

    local championtable = {}
    for x in pairs(skinData) do
        table.insert(championtable, x)
    end
    table.sort(championtable)

    local resulttable = {}
    for _, championname in pairs(championtable) do
        local skintable  = {}
        for championname in pairs(skinData[championname]["skins"]) do
            table.insert(skintable, championname)
        end
        table.sort(skintable)

        for _, skinname in pairs(skintable) do
            local chromatable = {}
            local t           = skinData[championname]["skins"][skinname]
            local formatname  = t.formatname

            if t.chromas ~= nil then
                t = t.chromas
                for chromaname in pairs(t) do
                    if t[chromaname].distribution == "Partner Program" then
                        s = s .. '<div class="skin-icon" data-game="lol" data-champion="' .. championname .. '" data-skin="' .. skinname .. '"><div class="chroma partner-border">[[File:' .. FN.chroma({championname, skinname, chromaname}) .. '|100px|border|link=]]</div> <div class="chroma-caption">[[File:' .. FN.championcircle({championname, skinname}) .. '|20px|link=' .. championname .. ']] [[' .. championname .. '|' .. lib.ternary(formatname, formatname, skinname .. ' ' .. championname) .. ']]</div></div>'
                    end

                end
            end
        end
    end
    s = s .. '</div>'

    return s
end

-- Данная функция собирает в одну таблицу все данные по образам чемпионов
-- Для вызова всех модулей ей необходимо получить список чемпионов на английском языке
function p.collectAllSkins()
	local skinData = {}
	-- Список имён чемпионов
	local champions = mw.loadData("Модуль:ChampionData/engnames")
	for k, v in lib.pairsByAlphabeticalKeys(champions) do
		local data = mw.loadData("Модуль:SkinData/data/" .. v)
		skinData[k] = data[k]
	end

	return skinData
end

-- Возвращает образ чемпиона по его ID
function _getSkinById(championName, skinId)
    local getter = require("Модуль:SkinData/getter")
    return getter.skinById(championName, skinId)
end

return p

-- </pre>
-- [[Category:Lua]]