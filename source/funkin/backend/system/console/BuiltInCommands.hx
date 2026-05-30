package funkin.backend.system.console;
import funkin.backend.system.console.ConsoleCommand;


class BuiltInCommands {
	static var clear = new FuncCommand("clear", "", function(args) { @:privateAccess ConsoleUI.instance.clearConsole(); });
	static var loadSong = new FuncCommand("loadSong", "[song] [diff] [variation] [opponentMode] [coopMode]", function(args) {
		if (args.length == 0) return;
		PlayState.loadSong(args[0], args[1], args[2] != null ? (args[2] == "default" ? null : args[2]) : null, args[3] != null ? args[3] == "true" : false, args[4] != null ? args[4] == "true" : false);
		FlxG.switchState(new PlayState());
	});
	static var endSong = new FuncCommand("endSong", "", function(args) {
		if (PlayState.instance != null) {
			PlayState.instance.endSong();
		}
	});
	static var switchMod = new FuncCommand("switchMod", "[name]", function(args) { funkin.backend.assets.ModsFolder.switchMod(args[0]); });
	static var reloadMod = new FuncCommand("reloadMod", "[name]", function(args) { funkin.backend.assets.ModsFolder.reloadMods(); });
}