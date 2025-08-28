package funkin.editors.modchart;

import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import funkin.game.Stage;
import funkin.game.HudCamera;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UITopMenu.UITopMenuButton;
import funkin.backend.system.Conductor;

import funkin.editors.modchart.items.*;

class ModchartEditor extends UIState {
	public static var __song:String;
	static var __diff:String;
	static var __variant:String;
	static var __reload:Bool;

	public static var instance(get, never):ModchartEditor;
	private static inline function get_instance()
		return FlxG.state is ModchartEditor ? cast FlxG.state : null;

	public var topMenu:Array<UIContextMenuOption>;
	public var topMenuSpr:UITopMenu;

	public var timeline:ModchartTimeline;
	public var timelineUI:ModchartTimelineUI;
	var timelineWindow:UIWindow;

	public var camBack:FlxCamera;

	public var camGame:FlxCamera;
	public var camHUD:HudCamera;
	public var camOther:FlxCamera;

	public var camEditor:FlxCamera;
	public var camEditorTop:FlxCamera;
	public var camTimelineList:FlxCamera;
	public var camTimelineValueList:FlxCamera;
	public var camTimeline:FlxCamera;

	var conductorSprY:Float = 0.0;
	var vocals:FlxSound;
	var strumLineVocals:Array<FlxSound> = [];

	var songPosInfo:UIText;

	public var downscroll:Bool = false;

	var stage:Stage;
	var defaultCamZoom:Float = 1;

	public var ROW_SIZE_X = 20.0;
	public var ROW_SIZE_Y = 20.0;
	var _targetRowSizeX = 20.0;
	var _targetRowSizeY = 20.0;

	public var VALUE_LIST_POS = 200.0; //maybe can add dragging?
	public var VALUE_LIST_WIDTH = 50.0;

	public function new(song:String, diff:String, variant:String, reload:Bool = true) {
		super();
		if (song != null) {
			__song = song;
			__diff = diff;
			__variant = variant;
			__reload = reload;
		}
	}

	public override function create() {
		super.create();

		if (__reload) {
			PlayState.loadSong(__song, __diff, __variant, false, false);
		}

		topMenu = [
			{
				label: "File",
				childs: [
					{
						label: "Save",
						keybind: [FlxKey.CONTROL, FlxKey.S],
						onSelect: _save
					},
					null,
					{
						label: "Export Packaged Modchart",
						onSelect: _export_package
					},
					null,
					{
						label: "Exit",
						onSelect: _exit
					}
				]
			},
			{
				label: "Edit",
				childs: [
					/*{
						label: "Undo",
						keybind: [FlxKey.CONTROL, FlxKey.Z],
						onSelect: _edit_undo
					},
					{
						label: "Redo",
						keybinds: [[FlxKey.CONTROL, FlxKey.Y], [FlxKey.CONTROL, FlxKey.SHIFT, FlxKey.Z]],
						onSelect: _edit_redo
					},
					null,*/
					{
						label: "Copy",
						keybind: [FlxKey.CONTROL, FlxKey.C],
						onSelect: _edit_copy
					},
					{
						label: "Paste",
						keybind: [FlxKey.CONTROL, FlxKey.V],
						onSelect: _edit_paste
					},
					null,
					{
						label: "Cut",
						keybind: [FlxKey.CONTROL, FlxKey.X],
						onSelect: _edit_cut
					},
					{
						label: "Delete",
						keybind: [FlxKey.DELETE],
						onSelect: _edit_delete
					},
					null,
					{
						label: "Shift Selection Left",
						keybind: [FlxKey.SHIFT, FlxKey.LEFT],
						onSelect: _edit_shiftleft
					},
					{
						label: "Shift Selection Right",
						keybind: [FlxKey.SHIFT, FlxKey.RIGHT],
						onSelect: _edit_shiftright
					}
				]
			},
			{
				label: "Modchart",
				childs: [
					{
						label: "Edit Timeline Items",
						onSelect: _modchart_edititems
					}
				]
			},
			{
				label: "View",
				childs: [
					{
						label: "Fullscreen",
						keybind: [FlxKey.F],
						onSelect: _view_fullscreen
					},
					{
						label: "Swap Scroll",
						onSelect: _view_downscroll
					}
				]
			},
			{
				label: "Song",
				childs: [
					{
						label: "Go back to the start",
						keybind: [FlxKey.HOME],
						onSelect: _song_start
					},
					{
						label: "Go to the end",
						keybind: [FlxKey.END],
						onSelect: _song_end
					},
					null,
					{
						label: "Mute instrumental",
						onSelect: _song_muteinst
					},
					{
						label: "Mute voices",
						onSelect: _song_mutevoices
					}
				]
			},
			{
				label: "Playback",
				childs: [
					{
						label: "Play/Pause",
						keybind: [FlxKey.SPACE],
						onSelect: _playback_play
					},
					null,
					{
						label: "↑ Speed 25%",
						onSelect: _playback_speed_raise
					},
					{
						label: "Reset Speed",
						onSelect: _playback_speed_reset
					},
					{
						label: "↓ Speed 25%",
						onSelect: _playback_speed_lower
					},
					null,
					{
						label: "Go back a section",
						keybind: [FlxKey.A],
						onSelect: _playback_back
					},
					{
						label: "Go forward a section",
						keybind: [FlxKey.D],
						onSelect: _playback_forward
					}
				]
			}
		];

		camBack = FlxG.camera;

		camGame = new FlxCamera();
		camGame.width = 1280;
		camGame.height = 720;
		camGame.bgColor = 0;
		FlxG.cameras.add(camGame);

		camHUD = new HudCamera();
		camHUD.width = 1280;
		camHUD.height = 720;
		camHUD.bgColor = 0;
		camHUD.downscroll = downscroll;
		FlxG.cameras.add(camHUD);

		camOther = new FlxCamera();
		camOther.width = 1280;
		camOther.height = 720;
		camOther.bgColor = 0;
		FlxG.cameras.add(camOther);

		camEditor = new FlxCamera();
		camEditor.bgColor = 0;
		FlxG.cameras.add(camEditor);

		camEditorTop = new FlxCamera();
		camEditorTop.bgColor = 0;
		FlxG.cameras.add(camEditorTop);

		topMenuSpr = new UITopMenu(topMenu);
		topMenuSpr.scrollFactor.set(1,1);
		topMenuSpr.cameras = [camEditorTop];
		add(topMenuSpr);

		/*
		quants.reverse();
		for (quant in quants) {
			var button = new CharterQuantButton(0, 0, quant);
			button.cameras = [camEditorTop];
			button.onClick = () -> {setquant(button.quant);};
			quantButtons.push(add(button));
		}
		quants.reverse();
		
		buildSnapsUI();
		*/

		camTimelineList = new FlxCamera();
		camTimelineList.width = Std.int(VALUE_LIST_POS);
		camTimelineList.height = 590;
		camTimelineList.bgColor = 0;
		FlxG.cameras.add(camTimelineList);

		camTimelineValueList = new FlxCamera();
		camTimelineValueList.x = Std.int(VALUE_LIST_POS);
		camTimelineValueList.width = Std.int(VALUE_LIST_WIDTH);
		camTimelineValueList.height = 590;
		camTimelineValueList.bgColor = 0;
		FlxG.cameras.add(camTimelineValueList);

		camTimeline = new FlxCamera();
		camTimeline.x = Std.int(VALUE_LIST_WIDTH) + Std.int(VALUE_LIST_POS);
		camTimeline.width = FlxG.width;
		camTimeline.height = 590;
		camTimeline.bgColor = 0;
		FlxG.cameras.add(camTimeline);

		var bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/menuEditors'));
		bg.scrollFactor.set();
		bg.cameras = [camBack];
		add(bg);

		if (PlayState.SONG.stage == null) PlayState.SONG.stage = "stage";
		stage = new Stage(PlayState.SONG.stage);
		for (obj in stage.stageSprites) {
			trace(obj);
			obj.cameras = [camGame];
		}
		//if (stage.stageXML != null && stage.stageXML.exists("zoom")) {
		//	defaultCamZoom = Std.parseFloat(stage.stageXML.get("zoom"));
		//}
		FlxG.mouse.visible = true;

		
		songPosInfo = new UIText(FlxG.width - 30 - 400, 35, 400, "00:00\nBeat: 0\nStep: 0\nMeasure: 0\nBPM: 0\nTime Signature: 4/4");
		songPosInfo.alignment = "right";
		songPosInfo.cameras = [camEditor];
		songPosInfo.scrollFactor.set(0,0);
		add(songPosInfo);
		//if (!stagePreviewMode) add(songPosInfo);
		

		timelineWindow = new UIWindow(0, 360, 1280, 600, "Timeline");
		timelineWindow.cameras = [camEditor];
		add(timelineWindow);

		

		/*
		scrollBar = new UIScrollBarHorizontal();
		scrollBar.newnew(250, timelineWindow.y+5, 1000, 0, 10, 1280-270, 20);
		scrollBar.cameras = [camEditor];
		scrollBar.onChange = function(v) {
			if (!FlxG.sound.music.playing)
				Conductor.songPosition = Conductor.getTimeForStep(v) + Conductor.songOffset;
		}
		add(scrollBar);
		*/

		//createStrumlines();

		loadSong();
		loadTimeline();

		DiscordUtil.call("onEditorLoaded", ["Modchart Editor", __song + " (" + __diff + ")" + (__variant != null && __variant != "" ? " (" + __variant + ")" : "")]);
	}

	var __crochet:Float = 0;
	var __firstFrame:Bool = true;
	public override function update(elapsed:Float) {
		
		ROW_SIZE_X = CoolUtil.fpsLerp(ROW_SIZE_X, _targetRowSizeX, 0.2);
		ROW_SIZE_Y = CoolUtil.fpsLerp(ROW_SIZE_Y, _targetRowSizeY, 0.2);

		if (FlxG.sound.music.playing || __firstFrame) {
			conductorSprY = curStepFloat * ROW_SIZE_X;
		} else {
			conductorSprY = CoolUtil.fpsLerp(conductorSprY, curStepFloat * ROW_SIZE_X, __firstFrame ? 1 : 1/3);
		}

		super.update(elapsed);

		updateUI();

		if(FlxG.keys.justPressed.ANY && currentFocus == null)
			UIUtil.processShortcuts(topMenu);

		__crochet = ((60 / Conductor.bpm) * 1000);
		if (timelineWindow.hovered) {
			if (FlxG.keys.pressed.CONTROL) {
				if (FlxG.mouse.wheel != 0.0) {
					_targetRowSizeX = FlxMath.bound(_targetRowSizeX + (FlxG.mouse.wheel * 2), 4, 100);
				}
			} else {
				_timelineScrollY += (FlxG.keys.pressed.SHIFT ? 8.0 : 1.0) * -FlxG.mouse.wheel * ROW_SIZE_Y;
				_timelineScrollY = FlxMath.bound(_timelineScrollY, 0, Math.max(0, 30 + (ROW_SIZE_Y * timeline.list.length) - (-timelineWindow.y + FlxG.height)));
				camTimelineValueList.scroll.y = camTimeline.scroll.y = camTimelineList.scroll.y = CoolUtil.fpsLerp(camTimelineList.scroll.y, _timelineScrollY, 0.15);
			}
		} else {
			if (!FlxG.sound.music.playing) {
				Conductor.songPosition -= (__crochet*0.25 * (FlxG.keys.pressed.SHIFT ? 8.0 : 1.0) * FlxG.mouse.wheel) - Conductor.songOffset;
			}
		}


		var songLength = FlxG.sound.music.length;
		Conductor.songPosition = FlxMath.bound(Conductor.songPosition + Conductor.songOffset, 0, songLength);
		if (Conductor.songPosition >= songLength - Conductor.songOffset) {
			FlxG.sound.music.pause();
			vocals.pause();
			for (v in strumLineVocals) v.pause();
		}

		songPosInfo.text = CoolUtil.timeToStr(Conductor.songPosition) + '/' + CoolUtil.timeToStr(songLength)
			+ '\nStep: ' + curStep
			+ '\nBeat: ' + curBeat
			+ '\nMeasure: ' + curMeasure
			+ '\nBPM: ' + Conductor.bpm;

		camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, defaultCamZoom, 0.05);
		camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.05);

		__firstFrame = false;
	}

	var _grabbedTimeline = false;
	var _grabTimelineY:Float = 0;

	var _grabbedValues = false;
	var _grabValuesX:Float = 0;

	var _doTimelineLerp = true;
	var _fullscreen = false;
	var _timelineScrollY:Float = 0.0;
	var _timeSinceLastMouseMove = 0.0;

	final TIMELINE_HEIGHT = 30;
	final TIMELINE_DEFAULT_Y = 360;
	final TIMELINE_MIN_Y = 130;
	final TIMELINE_MAX_Y = 690;
	
	final VALUES_MIN_X = 10;
	final VALUES_MAX_X = 1230;

	function updateUI() {
		_timeSinceLastMouseMove += FlxG.elapsed;
		if (FlxG.mouse.justMoved) _timeSinceLastMouseMove = 0.0;

		camTimeline.scroll.x = conductorSprY;

		if (FlxG.mouse.justReleased) {
			timelineWindow.cursor = ARROW;
			_grabbedTimeline = false;
			_grabbedValues = false;
			_fullscreen = timelineWindow.y >= TIMELINE_MAX_Y;
			if (_fullscreen) _doTimelineLerp = true;
		}
		var mousePos = FlxG.mouse.getWorldPosition(camEditor);
		if (!_grabbedTimeline && !_grabbedValues) {
			if (mousePos.y >= timelineWindow.y && mousePos.y < timelineWindow.y + TIMELINE_HEIGHT) {
				if (FlxG.mouse.justPressed) {
					_grabbedTimeline = true;
					_grabTimelineY = mousePos.y - timelineWindow.y;
					_doTimelineLerp = false;
				}
				timelineWindow.cursor = CLICK;
			}

			if (mousePos.y >= timelineWindow.y + TIMELINE_HEIGHT && mousePos.x >= VALUE_LIST_POS && mousePos.x < VALUE_LIST_POS + VALUE_LIST_WIDTH) {
				if (FlxG.mouse.justPressed) {
					_grabbedValues = true;
					_grabValuesX = mousePos.x - VALUE_LIST_POS;
				}
				timelineWindow.cursor = CLICK;
			}
		} else {

			if (_grabbedTimeline) {
				timelineWindow.y = FlxMath.bound(mousePos.y - _grabTimelineY, TIMELINE_MIN_Y, TIMELINE_MAX_Y);
				timelineWindow.cursor = CLICK;
			}

			if (_grabbedValues) {
				VALUE_LIST_POS = FlxMath.bound(mousePos.x - _grabValuesX, VALUES_MIN_X, VALUES_MAX_X);
				timelineWindow.cursor = CLICK;

				var val = Std.int(VALUE_LIST_POS);
				camTimelineList.width = val;
				camTimelineValueList.x = val;
				camTimeline.x = Std.int(VALUE_LIST_WIDTH) + val;
			}
		}
		
		if (_doTimelineLerp) {
			timelineWindow.y = CoolUtil.fpsLerp(timelineWindow.y, _fullscreen ? (_timeSinceLastMouseMove > 1.0 ? FlxG.height : TIMELINE_MAX_Y) : TIMELINE_DEFAULT_Y, 0.15);
		}

		var hideTopBar:Bool = timelineWindow.y >= TIMELINE_MAX_Y;
		timelineWindow.titleSpr.y = timelineWindow.y + ((TIMELINE_HEIGHT - timelineWindow.titleSpr.height) / 2);
		camEditorTop.scroll.y = CoolUtil.fpsLerp(camEditorTop.scroll.y, hideTopBar ? 100 : 0, 0.15);
		camTimelineValueList.y = camTimelineList.y = camTimeline.y = timelineWindow.y + TIMELINE_HEIGHT; // + 40;
		
		var lastCamScale = camGame.flashSprite.scaleX;
		var camScale = FlxMath.bound(FlxMath.remapToRange(timelineWindow.y, TIMELINE_MAX_Y, 70, 1.0, 0.0), 0.0, 1.0);
		var newScale = CoolUtil.fpsLerp(camGame.flashSprite.scaleX, camScale, 0.15);
		if (Math.abs(camScale-newScale) < 0.01) newScale = camScale;
		camGame.flashSprite.scaleX = camGame.flashSprite.scaleY = camOther.flashSprite.scaleX = camOther.flashSprite.scaleY = camHUD.flashSprite.scaleX = camHUD.flashSprite.scaleY = newScale;
		
		if (camGame.flashSprite.scaleX != lastCamScale) {
			ShaderResizeFix.fixSpriteShaderSize(camGame.flashSprite);
			ShaderResizeFix.fixSpriteShaderSize(camHUD.flashSprite);
			ShaderResizeFix.fixSpriteShaderSize(camOther.flashSprite);
		}

		camGame.y = camHUD.y = camOther.y = ((-720/4) + 16) * (-((camGame.flashSprite.scaleX-0.5)*2)+1);
	}

	function loadSong() {
		Conductor.setupSong(PlayState.SONG);

		CoolUtil.setMusic(FlxG.sound, FlxG.sound.load(Paths.inst(__song, __diff, PlayState.SONG.meta.instSuffix)));
		if (Assets.exists(Paths.voices(__song, __diff, PlayState.SONG.meta.vocalsSuffix)))
			vocals = FlxG.sound.load(Paths.voices(__song, __diff, PlayState.SONG.meta.instSuffix));
		else
			vocals = new FlxSound();

		vocals.muted = !PlayState.SONG.meta.needsVoices;
		vocals.group = FlxG.sound.defaultMusicGroup;

		for (strL in PlayState.SONG.strumLines) {
			if (strL.vocalsSuffix.length > 0 && Assets.exists(Paths.voices(__song, __diff, strL.vocalsSuffix))) {
				var v = FlxG.sound.load(Paths.voices(__song, __diff, strL.vocalsSuffix));
				v.group = FlxG.sound.defaultMusicGroup;
				strumLineVocals.push(v);
			}
		}

		//scrollBar.length = Conductor.getStepForTime(FlxG.sound.music.length);
	}

	var xml:Xml;
	function loadTimeline() {

		var xmlPath = Paths.getPath("songs/"+PlayState.SONG.meta.name+"/modchart.xml");
		if (Assets.exists(Paths.getPath("songs/"+PlayState.SONG.meta.name+"/modchart-" + PlayState.difficulty + ".xml"))) {
			xmlPath = Paths.getPath("songs/"+PlayState.SONG.meta.name+"/modchart-" + PlayState.difficulty + ".xml");
		}
		if (!Assets.exists(xmlPath)) return;

		xml = Xml.parse(Assets.getText(xmlPath)).firstElement();

		timeline = new ModchartTimeline();
		timeline.loadItems(xml);
		timeline.loadEvents(xml);

		timelineUI = new ModchartTimelineUI(timeline);
		add(timelineUI);
		timelineUI.generateUI();
	}



	function _save(_) {
		/*
		xml = buildXMLFromEvents();
		var path = Paths.getAssetsRoot() + '/songs/'+PlayState.SONG.meta.name+'/modchart.xml';
		if (Assets.exists(Paths.getPath("songs/"+PlayState.SONG.meta.name+"/modchart-" + PlayState.difficulty + ".xml"))) {
			path = Paths.getAssetsRoot() + '/songs/'+PlayState.SONG.meta.name+"/modchart-" + PlayState.difficulty + ".xml";
		}
		CoolUtil.safeSaveFile(path, Printer.print(xml, true));
		*/
	}
	function _export_package(_) {
		/*
		var packagedXML = buildXMLFromEvents(null, true);
		CoolUtil.safeSaveFile("testpackage.xml", Printer.print(packagedXML, true));
		*/
	}
	function _exit(_) {
		FlxG.switchState(new ModchartSelection());
	}
	function _modchart_edititems(_) {
		/*
		CURRENT_XML = xml;
		ITEM_EDIT_LOADED_SCRIPTS = itemScripts;
		ITEM_EDIT_SAVE_CALLBACK = function() {
			xml = buildXMLFromEvents(ITEM_EDIT_SAVED_INIT_EVENTS);
			xml = buildXMLFromEvents(); //do twice just in case

			loadEvents(true);
		}
		var win = new UISubstateWindow(true, 'ModchartEditDataSubstate');
		FlxG.sound.music.pause();
		vocals.pause();
		openSubState(win);
		*/
	}

	function _view_fullscreen(_) {
		
		_fullscreen = !_fullscreen;
		_doTimelineLerp = true;
		//for (name => script in itemScripts) {
		//	script.call("onFullscreen", [_fullscreen]);
		//}
	}
	function _view_downscroll(_) {
		/*
		downscroll = !downscroll;
		camHUD.downscroll = downscroll;
		refreshEventTimings();

		for (name => script in itemScripts) {
			script.call("onFlipScroll", [downscroll]);
		}
		*/
	}

	function _song_start(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition = 0;
	}
	function _song_end(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition = FlxG.sound.music.length;
	}

	function _song_muteinst(t) {
		FlxG.sound.music.volume = FlxG.sound.music.volume > 0 ? 0 : 1;
		t.icon = 1 - Std.int(Math.ceil(FlxG.sound.music.volume));
	}
	function _song_mutevoices(t) {
		vocals.volume = vocals.volume > 0 ? 0 : 1;
		for (v in strumLineVocals) v.volume = vocals.volume;
		t.icon = 1 - Std.int(Math.ceil(vocals.volume));
	}

	function _playback_speed_change(change) {
		var v = FlxG.sound.music.pitch + change;
		if (v < 0.25) v = 0.25;
		if (v > 2.0) v = 2.0;
		FlxG.sound.music.pitch = vocals.pitch = v;
		for (voc in strumLineVocals) voc.pitch = v;
	}

	function _playback_speed_raise(_) _playback_speed_change(0.25);
	function _playback_speed_reset(_) FlxG.sound.music.pitch = vocals.pitch = 1;
	function _playback_speed_lower(_) _playback_speed_change(-0.25);

	function _playback_play(_) {
		if (Conductor.songPosition >= FlxG.sound.music.length - Conductor.songOffset) return;

		if (FlxG.sound.music.playing) {
			FlxG.sound.music.pause();
			vocals.pause();
			for (v in strumLineVocals) v.pause();
		} else {
			FlxG.sound.music.play(true, Conductor.songPosition + Conductor.songOffset);
			vocals.play(true, FlxG.sound.music.getActualTime());
			for (v in strumLineVocals) v.play(true, FlxG.sound.music.getActualTime());
			//vocals.time = FlxG.sound.music.time = Conductor.songPosition + Conductor.songOffset * 2;
			//for (strumLine in strumLines.members) {
			//	strumLine.vocals.play();
			//	strumLine.vocals.time = vocals.time;
			//}
		}
	}
	function _playback_back(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition -= (Conductor.beatsPerMeasure * __crochet);
	}
	function _playback_forward(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition += (Conductor.beatsPerMeasure * __crochet);
	}

	/*
	function selectEvent(e, reset:Bool) {
		if (reset) {
			resetSelection();
		}
		SortedArrayUtil.addSorted(selectedEvents, e, function(n){return n.step;});
		e.selected = true;
	}
	function resetSelection() {
		for (event in selectedEvents) {
			event.selected = false;
		}
		selectedEvents = [];
	}
	*/

	function _edit_undo(_) {

	}
	function _edit_redo(_) {

	}
	function _edit_copy(_) {
		/*
		clipboard = [];
		for (event in selectedEvents) {
			clipboard.push(callEventScriptFromEvent(event, "copyEventEditor", [event]));
		}
		clipboard.sort(function(a, b) {
			if(a.step < b.step) return -1;
			else if(a.step > b.step) return 1;
			else return 0;
		});
		*/
	}
	function _edit_paste(_) {
		/*
		resetSelection();
		if (clipboard.length > 0) {
			var diff = curStep - clipboard[0].step; //TODO: maybe switch to use mouse pos instead?

			//trace(clipboard[0].step);
			//trace(diff);

			for (event in clipboard) {
				var e = callEventScriptFromEvent(event, "copyEventEditor", [event]);
				e.step += diff;
				SortedArrayUtil.addSorted(events, e, function(n){return n.step;});
				selectEvent(e, false);
			}

			refreshEventTimings();
		}
		*/
	}
	function _edit_cut(_) {
		/*
		_edit_copy();
		_edit_delete();
		*/
	}
	function _edit_delete(_) {
		/*
		for (e in selectedEvents) {
			events.remove(e);
		}
		selectedEvents = [];
		refreshEventTimings();
		*/
	}
	function _edit_shiftleft(_) {
		/*
		for (event in selectedEvents) {
			event.step -= 1;
			if (event.step < 0) event.step = 0;
		}
		sortAllEvents();
		refreshEventTimings();
		*/
	}
	function _edit_shiftright(_) {
		/*
		for (event in selectedEvents) {
			event.step += 1;
		}
		sortAllEvents();
		refreshEventTimings();
		*/
	}
}



