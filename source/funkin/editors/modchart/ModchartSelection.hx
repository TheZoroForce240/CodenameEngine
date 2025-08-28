package funkin.editors.modchart;

import flixel.util.FlxColor;
import funkin.backend.chart.Chart;
import funkin.backend.chart.ChartData;
import funkin.editors.charter.SongCreationScreen.SongCreationData;
import funkin.editors.EditorTreeMenu;
import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.options.type.*;
import haxe.Json;

using StringTools;

class ModchartSelection extends EditorTreeMenu {
	override function create() {
		super.create();
		DiscordUtil.call("onEditorTreeLoaded", ["Modchart Editor"]);
		addMenu(new ModchartSelectionScreen());
		bgType = 'charter';
	}
}

class ModchartSelectionScreen extends EditorTreeMenuScreen {
	public var freeplayList:FreeplaySonglist;
	public var songList:Array<String> = [];
	public var curSong:ChartMetaData;

	inline public function makeChartOption(d:String, v:String, name:String):TextOption {
		return new TextOption(d, getID('acceptDifficulty'), () -> FlxG.switchState(new ModchartEditor(name, d, v)));
	}

	inline public function makeVariationOption(s:ChartMetaData):TextOption {
		return new TextOption(s.variant, getID('acceptVariation'), " >", () -> openSongOption(s, false));
	}

	public function openSongOption(s:ChartMetaData, first = true) {
		curSong = s;

		var isVariant = s.variant != null && s.variant != '';
		var screen = new EditorTreeMenuScreen((first || !isVariant) ? (s.name + (isVariant ? ' (${s.variant})' : '')) : s.variant, getID('selectDifficulty'));

		for (d in s.difficulties) if (d != '') screen.add(makeChartOption(d, isVariant ? s.variant : null, s.name));
		screen.add(new Separator());
		for (v in s.variants) if (s.metas.get(v) != null) screen.add(makeVariationOption(s.metas.get(v)));

		parent.addMenu(screen);
	}

	public function makeSongOption(s:ChartMetaData):IconOption {
		songList.push(s.name.toLowerCase());

		var opt = new IconOption(s.name, getID('acceptSong'), s.icon, () -> openSongOption(s, true));
		opt.suffix = " >";
		opt.editorFlashColor = s.color.getDefault(FlxColor.WHITE);

		return opt;
	}

	public function new() {
		super('editor.modchart.name', 'modchartSelection.desc', 'modchartSelection.');
		freeplayList = FreeplaySonglist.get(false);

		for (i => s in freeplayList.songs) add(makeSongOption(s));
	}
}