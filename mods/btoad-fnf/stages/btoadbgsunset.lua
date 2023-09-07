function onCreate()
    -- Background objects
    makeLuaSprite('sky', 'btoadBGSunset/sky', -350, -150);
    setScrollFactor('sky', 0.9, 0.9);
    scaleObject('sky', 1.25, 1.25);

    makeLuaSprite('background', 'btoadBGSunset/background', -350, -50);
    setScrollFactor('background', 0.5, 0.93);
    scaleObject('background', 1.2, 1.2);

    makeLuaSprite('back', 'btoadBGSunset/back', -350, -100);
    setScrollFactor('back', 0.9, 0.85);
    scaleObject('back', 1.2, 1.2);

    -- Floor
    makeLuaSprite('floor', 'btoadBGSunset/floor', -550, 650);
    setScrollFactor('floor', 1, 1);
    scaleObject('floor', 1.4, 1.4);

    -- Foreground Objects
    makeLuaSprite('foreground', 'btoadBGSunset/foreground', -400, 500);
    setScrollFactor('foreground', 1.1, 1.1);
    scaleObject('foreground', 1.3, 1.3);

    makeLuaSprite('mushroomFG1', 'btoadBGSunset/foreground_mushroom', 100, 700);
    setScrollFactor('mushroomFG1', 1.1, 1.1);
    scaleObject('mushroomFG1', 0.9, 0.9);

    makeLuaSprite('mushroomFG2', 'btoadBGSunset/foreground_mushroom_2', 1450, 600);
    setScrollFactor('mushroomFG2', 1.1, 1.1);
    scaleObject('mushroomFG2', 0.9, 0.9);
    -- Add Lua Sprites
    -- Behind Characters
    addLuaSprite('sky');
    addLuaSprite('background');
    addLuaSprite('back');
    addLuaSprite('floor');
    -- In front of Characters
    addLuaSprite('foreground', true);
    addLuaSprite('mushroomFG1', true);
    addLuaSprite('mushroomFG2', true);

    -- Performance
end

function onCreatePost()
    if not getPropertyFromClass("backend.ClientPrefs", "data.shaders") then
      return close();
    end

    makeLuaSprite("die2");
    makeGraphic("die2", screenWidth, screenHeight, "000000");

    initLuaShader("bloom", 140);
    setSpriteShader("die2", "bloom");

    addHaxeLibrary("ShaderFilter", "openfl.filters");
    runHaxeCode([[
      game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("die2").shader)]);
      game.camGame.setFilters([new ShaderFilter(game.getLuaObject("die2").shader)]);
    ]]);
end

function onUpdatePost()
  setShaderFloat("die2", "iTime", os.clock());
end