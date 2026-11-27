#pragma once
#include "GameMode/IGameModeHandler.hpp"

class ModeBoss : public IGameModeHandler
{
public:
	void init()
	{
		CCLOG("Enter Boss mode.");

		gd.isHardCore = true;
		setMap(0); // Use the map selected in the map-select layer.
		setTower(false, false);
		setFlog(false, false);
		setHero(false); // No rebirth in this one-on-one duel.
	}

	void onInitHeros()
	{
		// The player is the only hero in the normal hero roster.
		// GameLayer creates the selected Guardian separately.
		initHeros(1, 0);
	}

	void onGameStart() {}
	void onGameOver() {}

	void onCharacterInit(CharacterBase *c) {}

	void onCharacterDead(CharacterBase *c)
	{
		if (!c || !c->isPlayerOrCom())
			return;

		auto layer = getGameLayer();
		if (!layer || layer->_isGameOver)
			return;

		if (c->isGuardian())
			layer->onGameOver(true);
		else if (c->isPlayer())
			layer->onGameOver(false);
	}

	void onCharacterReborn(CharacterBase *c) {}

	const char *getSelectedGuardian() const override
	{
		if (selectLayer && selectLayer->_enemySelect)
			return selectLayer->_enemySelect;
		return GuardianEnum::Han;
	}
};
