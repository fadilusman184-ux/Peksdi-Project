--
-- SelectLayer
--
function SelectLayer:init()
    log('Initial SelectLayer...')

    self.mode = _G.mode
    self.isOneVsOne = self.mode == GameMode.OneVsOne
    self.isBossMode = self.mode == GameMode.Boss
    self.enableCustomSelect = _G.enableCustomSelect
    if self.mode == GameMode.Clone or self.mode == GameMode.OneVsOne then
        self.enableCustomSelect = false
        self.is3v3Mode = false
        self.is4v4Mode = false
    else
        self.is3v3Mode = self.mode == GameMode.Classic or self.mode ==
                             GameMode.RandomDeathmatch
        self.is4v4Mode = self.mode == GameMode.FourVsFour or self.mode ==
                             GameMode.HardCore_4Vs4
    end
    self.enableHardCore = false

    self.pageNum = 3

    self._comLabel1 = nil
    self._comLabel2 = nil
    self._comLabel3 = nil
    self._com1Select = nil
    self._com2Select = nil
    self._com3Select = nil

    self._heroName = nil
    self._heroHalfImage = nil
    self._enemyHalfImage = nil
    self._enemyName = nil
    self._enemySelect = nil

    self.pageLayers = {}
    self.pageButtons = {}

    self._playerSelect = nil
    self.selectHero = nil

    tools.addSprites('Record.plist', 'Record2.plist', 'Select.plist',
                     'UI.plist', 'Report.plist', 'Ougis.plist', 'Ougis2.plist',
                     'Map.plist', 'Gears.plist')

    -- if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    -- if not KTools:checkMD5() then
    -- 	SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
    -- 	CCDirector:sharedDirector():end()
    -- 	return false
    -- end
    -- end

    local width, height = display.width, display.height

    local bg_src = self.enableCustomSelect and 'red_bg.png' or 'blue_bg.png'
    local bgSprite = display.newSprite(bg_src, 0, 0)
    bgSprite:setAnchorPoint(0, 0)
    bgSprite:fullScreen()
    self:addChild(bgSprite, -5)

    -- produce groud
    local gold_left = display.newSprite('#gold_left.png', 0, 20)
    gold_left:setAnchorPoint(0, 0)
    self:addChild(gold_left, 1)

    local gold_right = display.newSprite('#gold_right.png')
    gold_right:setAnchorPoint(0, 1)
    gold_right:setPosition(width - gold_right:getContentSize().width - 20,
                           height - 20)
    self:addChild(gold_right, 1)

    -- produce the cloud
    local cloud_left = display.newSprite('#cloud.png', 0, 15)
    cloud_left:setAnchorPoint(0, 0)
    cloud_left:setFlipX(true)
    cloud_left:setFlipY(true)
    self:addChild(cloud_left, 2)

    local cmv1 = CCMoveBy:create(1, CCPoint(-15, 0))
    local cseq1 = CCRepeatForever:create(
                      transition.sequence({cmv1, cmv1:reverse()}))
    cloud_left:runAction(cseq1)

    local cloud_right = display.newSprite('#cloud.png')
    cloud_right:setAnchorPoint(0, 0)
    cloud_right:setPosition(width - cloud_right:getContentSize().width, 15)
    cloud_right:setFlipY(true)
    self:addChild(cloud_right, 2)

    local cmv2 = CCMoveBy:create(1, CCPoint(15, 0))
    local cseq2 = CCRepeatForever:create(
                      transition.sequence({cmv2, cmv2:reverse()}))
    cloud_right:runAction(cseq2)

    local cloud_top = display.newSprite('#cloud_top.png')
    cloud_top:setAnchorPoint(0.5, 0)
    cloud_top:setPosition(width / 2,
                          height - (cloud_top:getContentSize().height + 12))
    self:addChild(cloud_top, 1)

    -- produce the menu_bar
    local menu_bar_b = display.newSprite('menu_bar2.png')
    menu_bar_b:setAnchorPoint(0, 0)
    menu_bar_b:fullScreen()
    self:addChild(menu_bar_b, 2)

    local menu_bar_t = display.newSprite('menu_bar3.png')
    menu_bar_t:setAnchorPoint(0, 0)
    menu_bar_t:setPosition(0, height - menu_bar_t:getContentSize().height)
    menu_bar_t:fullScreen()
    self:addChild(menu_bar_t, 2)

    local select_title = display.newSprite('#hcmode_title.png')
    select_title:setAnchorPoint(0, 0)
    select_title:setPosition(2,
                             height - select_title:getContentSize().height - 2)
    self:addChild(select_title, 3)

    local selectNameList = {}
    local selectButtons = {}

    for i = 1, self.pageNum do
        -- initial page list
        local index = i
        local pageLayer = TouchGroup:create() -- display.newLayer()
        local page_btn = ui.newImageMenuItem({
            image = '#page' .. tostring(i) .. '_off.png',
            imageSelected = '#page' .. tostring(i) .. '_on.png',
            listener = function()
                return self:onPageButtonClick(index)
            end
        })

        self:addChild(pageLayer, 5)
        if i == 1 then
            pageLayer:show()
            page_btn:selected()
        else
            pageLayer:hide()
            pageLayer:setPositionY(2000)
        end

        table.insert(self.pageLayers, pageLayer)
        table.insert(self.pageButtons, page_btn)
    end

    local charactersList = ns.CharactersLayout
    local pageNum = #self.pageLayers

    for i = 1, #charactersList do
        local charName = charactersList[i]

        selectNameList[#selectNameList + 1] = charName

        local idx = i - 1
        local Column = idx % 7
        local Row = toint(idx / 7)
        local Page = toint(idx / 21)
        -- log(
        --     ' -> load character %s\t[ Column: %d Row: %d Page: %d ] [ pos: %f, %f ]',
        --     charName, Column, Row, Page,
        --     width / 2 - 36 + (Column - 1) * 27 + Column / 4 * 10,
        --     height - 112 - (72 * (Row - 3 * Page)))

        local select_btn = SelectButton:create(charName .. '_select.png')
        select_btn._selectLayer = self
        select_btn._charName = charName
        --           -- LAYOUT --
        -- --- LEFT ---        --- RIGHT ---
        -- 1, 2, 3, 4, padding 5, 6, 7
        local groupPadding = toint(Column / 4) * 10
        select_btn:setPosition(CCPoint(width / 2 - 36 + (Column - 1) * 27 +
                                           groupPadding,
                                       height - 112 - (72 * (Row - 3 * Page))))

        if Page + 1 > pageNum then
            log('Select page index out of range')
            break
        end
        self.pageLayers[Page + 1]:addWidget(select_btn)

        selectButtons[#selectButtons + 1] = select_btn
    end

    local page_menu = ui.newMenu(self.pageButtons)
    page_menu:alignItemsHorizontallyWithPadding(20)
    page_menu:setPosition(width / 2 + 48, 42)
    self:addChild(page_menu, 10)

    self.selectButtons = selectButtons
    self.selectNameList = selectNameList
    self:setSelectList(table.toCCArray(selectNameList))

    local hero = selectNameList[1]
    if hero then
        local heroHalfImage = display.newSprite('#' .. hero .. '_half.png', 10,
                                                10)
        heroHalfImage:setAnchorPoint(0, 0)
        self:addChild(heroHalfImage, 1)

        local heroName = display.newSprite('#' .. hero .. '_font.png', 100, 20)
        heroName:setAnchorPoint(0.5, 0)
        self:addChild(heroName, 5)

        self._heroName = heroName
        self._heroHalfImage = heroHalfImage
    end

    -- 1VS1: show a stationary default enemy portrait on the right.
    if self.isOneVsOne then
        local enemyHalf = display.newSprite('#Naruto_half.png')
        enemyHalf:setAnchorPoint(0, 0)
        enemyHalf:setPosition(width - enemyHalf:getContentSize().width - 10, 10)
        enemyHalf:setFlipX(true)
        self:addChild(enemyHalf, 1)
        self._enemyHalfImage = enemyHalf

        local enemyName = display.newSprite('#Naruto_font.png')
        enemyName:setAnchorPoint(0.5, 0)
        enemyName:setPosition(width - 92, 20)
        self:addChild(enemyName, 5)
        self._enemyName = enemyName
    end

    local selectBtn = selectButtons[1]
    local selectImg = display.newSprite('#1p.png', selectBtn:getPositionX() - 2,
                                        selectBtn:getPositionY() - 2)
    selectImg:setAnchorPoint(0, 0)
    self:addChild(selectImg, 500)
    local blink = CCBlink:create(0.6, 1)
    selectImg:runAction(CCRepeatForever:create(blink))
    self._selectImg = selectImg
    self.selectHero = selectBtn._charName

    if self.enableCustomSelect then
        if self.is3v3Mode or self.is4v4Mode then
            self:initCustomSelectMode()
        end
    end

    local ranking_btn = ui.newImageMenuItem({
        image = '#ranking_btn.png',
        listener = handler(self, SelectLayer.onRankingButtonClick)
    })
    ranking_btn:setAnchorPoint(1, 0.5)
    local menu3 = ui.newMenu({ranking_btn})
    menu3:setPosition(width - 15, height - 34)
    self:addChild(menu3, 5)

    local start_btn = ui.newImageMenuItem({
        image = '#start_btn.png',
        -- Boss mode requires the player to finish character selection first.
        listener = function()
            if not self._playerSelect then
                self:setTip('Please select your character first')
                return
            end
            if self.isBossMode then
                self:openBossSelect()
            else
                self:openMapSelect()
            end
        end
    })
    local menu = ui.newMenu({start_btn})
    menu:setAnchorPoint(0, 0)
    menu:setPosition(width - 40, 36)
    self:addChild(menu, 5)

    local skill_btn = ui.newImageMenuItem({
        image = '#skill_btn.png',
        listener = handler(self, SelectLayer.onSkillMenuButtonClick)
    })
    local menu2 = ui.newMenu({skill_btn})
    menu2:setAnchorPoint(0, 0)
    menu2:setPosition(width - 35, 96)
    self:addChild(menu2, 5)

    -- Desktop return button
    if _G.platform == 'desktop' then
        local skill_btn = ui.newImageMenuItem({
            image = 'UI/return_btn.png',
            listener = backToStartMenu
        })
        local menu3 = ui.newMenu({skill_btn})
        menu3:setAnchorPoint(0, 0)
        menu3:setPosition(width - 35, 135)
        self:addChild(menu3, 5)
    end

    if save.isBGM() then audio.playMusic(ns.music.SELECT_MUSIC, true) end
end

function SelectLayer:initCustomSelectMode()
    log('Initial Custom Select Mode...')
    local teamSelector = display.newLayer()
    -- local uiLayer = TouchGroup:create()
    -- teamSelector:addChild(uiLayer, 5)

    -- local hardcore_switch_btn = CheckBox:create()
    -- hardcore_switch_btn:loadTextures( -- load textures
    -- "check_bg.png", "check_bg.png", "check.png", "", "", ns.UITexType.Local)
    -- -- "", -- backGround
    -- -- "", -- backGroundSelected
    -- -- "", -- cross
    -- -- "", -- backGroundDisabled
    -- -- "", -- frontCrossDisabled
    -- -- ns.UITexType.Plist)
    -- hardcore_switch_btn:setPosition(
    --     CCPoint(text:getContentSize().width + 5, 260))
    -- hardcore_switch_btn:setScale(0.4)
    -- hardcore_switch_btn:addEventListenerCheckBox(
    --     function(_, event)
    --         self.enableHardCore = event == ns.CheckBoxEventType.selected
    --         -- log('Is enable hardcore [ %s ]', tostring(self.enableHardCore))
    --     end)
    -- uiLayer:addWidget(hardcore_switch_btn)

    local teamBg = display.newSprite('#team_bg.png', 0, 185)
    teamBg:setAnchorPoint(0, 0)
    teamSelector:addChild(teamBg)

    -- init com selector 1
    local comSelector1 = display.newSprite('#unknow_select.png', 2, 194)
    comSelector1:setAnchorPoint(0, 0)
    teamSelector:addChild(comSelector1)
    self._comSelector1 = comSelector1

    self._comLabel1 = display.newSprite('#com_label.png')
    self._comLabel1:setPosition(comSelector1:getPositionX() +
                                    comSelector1:getContentSize().width + 2 + 18,
                                comSelector1:getPositionY() +
                                    comSelector1:getContentSize().height / 2)
    teamSelector:addChild(self._comLabel1)

    -- init com selector 2
    local comSelector2 = display.newSprite('#unknow_select.png')
    comSelector2:setAnchorPoint(0, 0)
    comSelector2:setPosition(comSelector1:getPositionX() +
                                 comSelector1:getContentSize().width + 40,
                             comSelector1:getPositionY())
    teamSelector:addChild(comSelector2)

    self._comLabel2 = display.newSprite('#com_label.png')
    self._comLabel2:setPosition(comSelector2:getPositionX() +
                                    comSelector2:getContentSize().width + 2 + 18,
                                comSelector2:getPositionY() +
                                    comSelector2:getContentSize().height / 2)
    teamSelector:addChild(self._comLabel2)
    self._comSelector2 = comSelector2

    -- init com selector 3
    if self.is4v4Mode then
        local comSelector3 = display.newSprite('#unknow_select.png')
        comSelector3:setAnchorPoint(0, 0)
        comSelector3:setPosition(comSelector2:getPositionX() +
                                     comSelector2:getContentSize().width + 40,
                                 comSelector2:getPositionY())
        teamSelector:addChild(comSelector3)

        self._comLabel3 = display.newSprite('#com_label.png')
        self._comLabel3:setPosition(comSelector3:getPositionX() +
                                        comSelector3:getContentSize().width + 3 +
                                        18, comSelector3:getPositionY() +
                                        comSelector3:getContentSize().height / 3)
        teamSelector:addChild(self._comLabel3)
        self._comSelector3 = comSelector3
    end

    self:addChild(teamSelector, 50)
end

function SelectLayer:onQuestBtn()
    -- not support
    self:setTip('ComingSoon')
end

function SelectLayer:onRankingButtonClick()
    -- not support
    self:setTip('ComingSoon')
end

function SelectLayer:onSkillMenuButtonClick()
    local scene = CCScene:create()
    local skillLayer = SkillLayer:create(self)
    scene:addChild(skillLayer)

    director.pushScene(scene)
end

function SelectLayer:onPageButtonClick(index)
    audio.playSound(ns.menu.SELECT_SOUND)

    for i, pageBtn in pairs(self.pageButtons) do
        if i == index then
            pageBtn:selected()
        else
            pageBtn:unselected()
        end
    end
    for i, pageLayer in pairs(self.pageLayers) do
        if i == index then
            pageLayer:show()
            pageLayer:setPositionY(0)
        else
            pageLayer:hide()
            pageLayer:setPositionY(10000)
        end
    end
end

function SelectLayer:setSelected(btn)
    if self._selectImg then
        self._selectImg:setPosition(CCPoint(btn:getPositionX() - 2,
                                            btn:getPositionY() - 2))
    end

    -- 1VS1: select Player 1 first, then select the enemy independently.
    if self.isOneVsOne then
        self.selectHero = btn._charName
        local charName = '#' .. btn._charName

        if not self._playerSelect then
            if self._heroHalfImage then
                self._heroHalfImage:removeFromParentAndCleanup(true)
            end
            self._heroHalfImage = display.newSprite(charName .. '_half.png', 10, 10)
            self._heroHalfImage:setAnchorPoint(CCPoint(0, 0))
            self:addChild(self._heroHalfImage, 1)

            if self._heroName then
                self._heroName:removeFromParentAndCleanup(true)
            end
            self._heroName = display.newSprite(charName .. '_font.png', 100, 20)
            self._heroName:setAnchorPoint(CCPoint(0.5, 0))
            self:addChild(self._heroName, 5)

            if btn._clickTime >= 2 then
                self:setSelectHero(btn._charName)
                self._playerSelect = btn._charName
                if self._selectImg then
                    self._selectImg:setDisplayFrame(display.newSpriteFrame('2p.png'))
                end
                log('1VS1 Player selected: ' .. btn._charName)
            end
        elseif not self._enemySelect then
            if btn._charName == self._playerSelect then return end

            if self._enemyHalfImage then
                self._enemyHalfImage:removeFromParentAndCleanup(true)
            end
            self._enemyHalfImage = display.newSprite(charName .. '_half.png')
            self._enemyHalfImage:setAnchorPoint(CCPoint(0, 0))
            self._enemyHalfImage:setPosition(display.width -
                self._enemyHalfImage:getContentSize().width - 10, 10)
            self._enemyHalfImage:setFlipX(true)
            self:addChild(self._enemyHalfImage, 1)

            if self._enemyName then
                self._enemyName:removeFromParentAndCleanup(true)
            end
            self._enemyName = display.newSprite(charName .. '_font.png')
            self._enemyName:setAnchorPoint(CCPoint(0.5, 0))
            self._enemyName:setPosition(display.width - 92, 20)
            self:addChild(self._enemyName, 5)

            if btn._clickTime >= 2 then
                self._enemySelect = btn._charName
                self:setEnemySelect(self._enemySelect)
                if self._selectImg then
                    self._selectImg:removeFromParentAndCleanup(true)
                    self._selectImg = nil
                end
                log('1VS1 Enemy selected: ' .. btn._charName)
            end
        end
        return
    end

    if not self.enableCustomSelect and self._playerSelect then return end

    self.selectHero = btn._charName
    local fd = CCFadeOut:create(1.0)
    local seq = CCRepeatForever:create(transition.sequence({fd, fd:reverse()}))

    if not self._playerSelect then
        if btn._clickTime >= 2 then
            self:setSelectHero(btn._charName)
            self._playerSelect = self.selectHero
            if not self.enableCustomSelect then
                self._selectImg:removeFromParent()
                self._selectImg = nil
            elseif self._comLabel1 then
                self._comLabel1:runAction(seq)
            end
        end

        self._heroHalfImage:removeFromParent()
        local charName = '#' .. btn._charName
        self._heroHalfImage = display.newSprite(charName .. '_half.png', 10, 10)
        self._heroHalfImage:setAnchorPoint(CCPoint(0, 0))
        self:addChild(self._heroHalfImage, 1)

        self._heroName:removeFromParent()
        self._heroName = display.newSprite(charName .. '_font.png', 100, 20)
        self._heroName:setAnchorPoint(CCPoint(0.5, 0))
        self:addChild(self._heroName, 5)
    elseif not self._com1Select then
        self._comSelector1:setDisplayFrame(display.newSpriteFrame(self.selectHero .. '_small.png'))
        if btn._clickTime >= 2 then
            self._com1Select = self.selectHero
            self:setCom1Select(self._com1Select)
            self._comLabel1:stopAllActions()
            self._comLabel1:setOpacity(255)
            self._comLabel1:setDisplayFrame(display.newSpriteFrame('com_label2.png'))
        end
    elseif not self._com2Select then
        self._comSelector2:setDisplayFrame(display.newSpriteFrame(self.selectHero .. '_small.png'))
        if btn._clickTime >= 2 then
            self._com2Select = self.selectHero
            self:setCom2Select(self._com2Select)
            self._comLabel2:stopAllActions()
            self._comLabel2:setOpacity(255)
            self._comLabel2:setDisplayFrame(display.newSpriteFrame('com_label2.png'))
        end
    elseif not self._com3Select then
        self._comSelector3:setDisplayFrame(display.newSpriteFrame(self.selectHero .. '_small.png'))
        if btn._clickTime >= 2 then
            self._com3Select = self.selectHero
            self:setCom3Select(self._com3Select)
            self._comLabel3:stopAllActions()
            self._comLabel3:setOpacity(255)
            self._comLabel3:setDisplayFrame(display.newSpriteFrame('com_label2.png'))
            self._selectImg:removeFromParent()
            self._selectImg = nil
        end
    end
end

function SelectLayer:noComSelect()
    if self.isOneVsOne then
        return self._enemySelect
    elseif self.is4v4Mode then
        return self._com3Select
    elseif self.is3v3Mode then
        return self._com2Select
    else
        return self._playerSelect
    end
end

function backToStartMenu()
    log('back to main menu')

    _G.mode = nil
    audio.playSound('Audio/Menu/cancel.ogg')
    local menuScene = CCScene:create()
    local menuLayer = StartMenu:create()

    hook.registerInitHandlerOnly(menuLayer)
    menuScene:addChild(menuLayer)
    director.replaceSceneWithFade(menuScene, 1)
end


-- Boss Guardian Select. This overlay is exclusive to Boss mode.
-- RETURN closes this overlay and keeps the player's character selection.
function SelectLayer:openBossSelect()
    if not self.isBossMode or self._bossSelectLayer then return end
    if not self._playerSelect then
        self:setTip('Please select your character first')
        return
    end

    local width, height = display.width, display.height
    local layer = display.newLayer()
    self:addChild(layer, 900)
    self._bossSelectLayer = layer

    local bg = display.newSprite('blue_bg.png', 0, 0)
    bg:setAnchorPoint(0, 0)
    bg:fullScreen()
    layer:addChild(bg, -2)

    local barTop = display.newSprite('menu_bar3.png')
    barTop:setAnchorPoint(0, 0)
    barTop:setPosition(0, height - barTop:getContentSize().height)
    barTop:fullScreen()
    layer:addChild(barTop, 1)

    local barBottom = display.newSprite('menu_bar2.png')
    barBottom:setAnchorPoint(0, 0)
    barBottom:fullScreen()
    layer:addChild(barBottom, 1)

    local title = CCLabelTTF:create('SELECT GUARDIAN', 'Arial', 28)
    title:setPosition(width / 2, height - 38)
    layer:addChild(title, 5)

    local selected = self._bossGuardian
    local hanLabel, roshiLabel
    local function refreshSelection()
        if hanLabel then hanLabel:setColor(selected == 'Han' and ccc3(255, 220, 80) or ccc3(255, 255, 255)) end
        if roshiLabel then roshiLabel:setColor(selected == 'Roshi' and ccc3(255, 220, 80) or ccc3(255, 255, 255)) end
    end

    local hanItem = ui.newImageMenuItem({
        image = '#Naruto_half.png',
        listener = function()
            selected = 'Han'
            self._bossGuardian = selected
            self:setEnemySelect(selected)
            refreshSelection()
        end
    })
    local roshiItem = ui.newImageMenuItem({
        image = '#RockLee_half.png',
        listener = function()
            selected = 'Roshi'
            self._bossGuardian = selected
            self:setEnemySelect(selected)
            refreshSelection()
        end
    })

    local guardians = ui.newMenu({hanItem, roshiItem})
    guardians:alignItemsHorizontallyWithPadding(110)
    guardians:setPosition(width / 2, height / 2 + 15)
    layer:addChild(guardians, 5)

    hanLabel = CCLabelTTF:create('HAN', 'Arial', 23)
    hanLabel:setPosition(width / 2 - 75, height / 2 - 65)
    layer:addChild(hanLabel, 6)
    roshiLabel = CCLabelTTF:create('ROSHI', 'Arial', 23)
    roshiLabel:setPosition(width / 2 + 75, height / 2 - 65)
    layer:addChild(roshiLabel, 6)
    refreshSelection()

    local back = ui.newImageMenuItem({
        image = 'UI/return_btn.png',
        listener = function()
            layer:removeFromParentAndCleanup(true)
            self._bossSelectLayer = nil
        end
    })
    local start = ui.newImageMenuItem({
        image = '#start_btn.png',
        listener = function()
            if selected ~= 'Han' and selected ~= 'Roshi' then
                self:setTip('Please select Han or Roshi')
                return
            end
            self:setEnemySelect(selected)
            layer:removeFromParentAndCleanup(true)
            self._bossSelectLayer = nil
            self:openMapSelect()
        end
    })
    local actions = ui.newMenu({back, start})
    actions:alignItemsHorizontallyWithPadding(28)
    actions:setPosition(width - 150, 42)
    layer:addChild(actions, 10)
end

-- Map Select: uses the original map background images and existing menu atlas.
-- The Character Select layer remains alive underneath this child layer, so the
-- selected characters and mode settings are preserved.
function SelectLayer:openMapSelect()
    if self._mapSelectLayer then return end

    local width, height = display.width, display.height
    local mapCount = 5 -- Maps/1.tmx ... Maps/5.tmx are included in this source.
    self._selectedMapId = self._selectedMapId or 1

    local layer = display.newLayer()
    self:addChild(layer, 1000)
    self._mapSelectLayer = layer

    local bg = display.newSprite('blue_bg.png', 0, 0)
    bg:setAnchorPoint(0, 0)
    bg:fullScreen()
    layer:addChild(bg, -2)

    local barTop = display.newSprite('menu_bar3.png')
    barTop:setAnchorPoint(0, 0)
    barTop:setPosition(0, height - barTop:getContentSize().height)
    barTop:fullScreen()
    layer:addChild(barTop, 1)

    local barBottom = display.newSprite('menu_bar2.png')
    barBottom:setAnchorPoint(0, 0)
    barBottom:fullScreen()
    layer:addChild(barBottom, 1)

    local title = CCLabelTTF:create('SELECT MAP', 'Arial', 28)
    title:setPosition(width / 2, height - 38)
    layer:addChild(title, 5)

    local preview = nil
    local mapLabel = nil
    local function refreshPreview()
        if preview then preview:removeFromParentAndCleanup(true) end
        if mapLabel then mapLabel:removeFromParentAndCleanup(true) end

        preview = display.newSprite(string.format('Maps/map_bg%d.png', self._selectedMapId))
        preview:setPosition(width / 2, height / 2 + 12)
        local size = preview:getContentSize()
        local maxW, maxH = width * 0.72, height * 0.58
        local scale = math.min(maxW / size.width, maxH / size.height)
        preview:setScale(scale)
        layer:addChild(preview, 3)

        mapLabel = CCLabelTTF:create(string.format('MAP %d / %d', self._selectedMapId, mapCount), 'Arial', 22)
        mapLabel:setPosition(width / 2, 82)
        layer:addChild(mapLabel, 5)
    end

    local prev = ui.newImageMenuItem({
        image = '#page1_off.png',
        imageSelected = '#page1_on.png',
        listener = function()
            self._selectedMapId = self._selectedMapId - 1
            if self._selectedMapId < 1 then self._selectedMapId = mapCount end
            refreshPreview()
        end
    })
    local next = ui.newImageMenuItem({
        image = '#page2_off.png',
        imageSelected = '#page2_on.png',
        listener = function()
            self._selectedMapId = self._selectedMapId + 1
            if self._selectedMapId > mapCount then self._selectedMapId = 1 end
            refreshPreview()
        end
    })
    local arrows = ui.newMenu({prev, next})
    arrows:alignItemsHorizontallyWithPadding(90)
    arrows:setPosition(width / 2, 42)
    layer:addChild(arrows, 10)

    local back = ui.newImageMenuItem({
        image = 'UI/return_btn.png',
        listener = function()
            layer:removeFromParentAndCleanup(true)
            self._mapSelectLayer = nil
            if self.isBossMode then
                self:openBossSelect()
            end
        end
    })
    local start = ui.newImageMenuItem({
        image = '#start_btn.png',
        listener = function()
            local selected = self._selectedMapId or 1
            self:setSelectedMap(selected)
            self._mapSelectLayer = nil
            self:onGameStart()
        end
    })
    local actions = ui.newMenu({back, start})
    actions:alignItemsHorizontallyWithPadding(28)
    actions:setPosition(width - 150, 42)
    layer:addChild(actions, 10)

    refreshPreview()
end
