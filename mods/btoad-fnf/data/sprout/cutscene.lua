local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode then --Block the first countdown
		startVideo('sprout');
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end