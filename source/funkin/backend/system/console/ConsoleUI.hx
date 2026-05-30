package funkin.backend.system.console;

#if IMGUI
import lime.tools.imgui.ImGui;
import lime.tools.imgui.ImGuiIO;
import lime.tools.imgui.ImGuiStyle;
import lime.tools.imgui.ImGuiHandler;
import lime.tools.imgui.ImGuiFlags;
import lime.tools.imgui.ImGuiTypes;
import lime.tools.imgui.ImGuiPtr;
import lime.tools.imgui.ImGuiInputTextCallbackData;
#end
import funkin.backend.system.Logs;
import funkin.backend.utils.NativeAPI.ConsoleColor;

typedef ConsoleSearchData = {
	var name:String;
	var desc:String;
	var searchIndex:Int;
	var isCommand:Bool;
	var ?autoComplete:String;
}

typedef ConsoleLogData = {
	var log:Array<LogText>;
	var times:Int;
}

class ConsoleUI {

	static final CONSOLE_BG_COLOR = 0xFF380051;
	static final SEARCH_HIGHLIGHT_COLOR = 0xFF00FF00;
	static final SEARCH_SELECTED_COLOR = 0xFFFFFF00;
	static final SEARCH_DESC_COLOR = 0xFF636363;

	static final CONSOLE_MAX_OUPUT = 100;
	static final SEARCH_MAX_OUTPUT = 25;

	public static var instance(default, null):ConsoleUI;

	private var active:Bool = false;
	#if IMGUI
	private var style:ImGuiStyle;
	#end
	private var consoleHscript:ConsoleHscript;

	var commandSearch:Array<ConsoleSearchData> = [];
	var prevCommands:Array<String> = [];
	var forceFocusTextInput = false;
	var cyclingCommands = false;
	var cyclingPrevCommands = false;
	var cycleIndex = 0;

	#if IMGUI
	var consoleInputString:ImGuiStringPtr = new ImGuiStringPtr("");
	var consoleInputTextCallback:ImGuiInputTextCallback;
	#end
	var consoleOutput:Array<ConsoleLogData> = [];
	var consoleOutputCurrentIndex:Int = 0;
	var wrapConsoleOutput = false;
	var autoScrollNextFrame = false;


	#if IMGUI
	var settingsOpen:ImGuiBoolPtr = new ImGuiBoolPtr(false);

	var timeFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var typeFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);

	var infoFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var warningFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var errorFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var traceFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var verboseFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);

	var commandsFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var hscriptClassFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var hscriptFunctionFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var hscriptBasicTypesFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var hscriptObjectsFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	var hscriptScriptsFilter:ImGuiBoolPtr = new ImGuiBoolPtr(true);
	#end

	public static function init() {
		ConsoleUI.instance = new ConsoleUI();
		#if IMGUI
		ImGuiIO.configFlags |= ImGuiConfigFlags.DockingEnable | ImGuiConfigFlags.ViewportsEnable;
		ImGuiHandler.instance.addCallback(ConsoleUI.instance.displayUI);
		#end
	}

	public function new() {
		#if IMGUI
		consoleInputTextCallback = new ImGuiInputTextCallback(onInputTextCallback);
		var vcrFont = ImGuiIO.fonts.addFontFromFileTTF("assets/fonts/vcr.ttf");
		ImGuiIO.fontDefault = vcrFont;
		style = ImGui.getStyle();
		style.windowBorderSize = 2;
		style.childBorderSize = 2;
		style.popupBorderSize = 2;
		style.frameBorderSize = 2;
		style.windowRounding = 6;
		style.childRounding = 6;
		style.popupRounding = 6;
		style.frameRounding = 6;
		style.scrollbarRounding = 6;
		style.grabRounding = 6;
		style.setColor(ImGuiCol.WindowBg,               new ImVec4(0.11, 0.00, 0.16, 0.8)); //TODO: this should be moved if we want imgui in other places
		style.setColor(ImGuiCol.Border,                 new ImVec4(0.59, 0.59, 0.59, 0.50));
		style.setColor(ImGuiCol.FrameBg,                new ImVec4(0.13, 0.00, 0.19, 0.54));
		style.setColor(ImGuiCol.FrameBgHovered,         new ImVec4(0.33, 0.15, 0.42, 0.40));
		style.setColor(ImGuiCol.FrameBgActive,          new ImVec4(0.33, 0.15, 0.42, 0.67));
		style.setColor(ImGuiCol.TitleBg,                new ImVec4(0.38, 0.36, 0.40, 0.32));
		style.setColor(ImGuiCol.TitleBgActive,          new ImVec4(0.38, 0.36, 0.40, 0.72));
		style.setColor(ImGuiCol.CheckMark,              new ImVec4(0.80, 0.60, 1.00, 1.00));
		style.setColor(ImGuiCol.SliderGrab,             new ImVec4(0.33, 0.30, 0.35, 1.00));
		style.setColor(ImGuiCol.SliderGrabActive,       new ImVec4(0.80, 0.60, 1.00, 1.00));
		style.setColor(ImGuiCol.Button,                 new ImVec4(0.14, 0.13, 0.13, 0.99));
		style.setColor(ImGuiCol.ButtonHovered,          new ImVec4(0.39, 0.00, 0.59, 1.00));
		style.setColor(ImGuiCol.ButtonActive,           new ImVec4(0.76, 0.00, 1.00, 1.00));
		style.setColor(ImGuiCol.Header,                 new ImVec4(0.15, 0.13, 0.13, 0.8));
		style.setColor(ImGuiCol.HeaderHovered,          new ImVec4(0.39, 0.00, 0.59, 0.80));
		style.setColor(ImGuiCol.HeaderActive,           new ImVec4(0.76, 0.00, 1.00, 1.00));
		style.setColor(ImGuiCol.SeparatorHovered,       new ImVec4(0.39, 0.00, 0.59, 0.78));
		style.setColor(ImGuiCol.SeparatorActive,        new ImVec4(0.76, 0.00, 1.00, 1.00));
		style.setColor(ImGuiCol.ResizeGrip,             new ImVec4(0.15, 0.13, 0.13, 0.20));
		style.setColor(ImGuiCol.ResizeGripHovered,      new ImVec4(0.39, 0.00, 0.59, 0.67));
		style.setColor(ImGuiCol.ResizeGripActive,       new ImVec4(0.76, 0.00, 1.00, 0.95));
		style.setColor(ImGuiCol.TabHovered,             new ImVec4(0.39, 0.00, 0.59, 0.80));
		style.setColor(ImGuiCol.Tab,                    new ImVec4(0.21, 0.19, 0.19, 0.86));
		style.setColor(ImGuiCol.TabSelected,            new ImVec4(0.76, 0.00, 1.00, 1.00));
		style.setColor(ImGuiCol.TabSelectedOverline,    new ImVec4(0.76, 0.00, 1.00, 1.00));
		style.setColor(ImGuiCol.TabDimmed,              new ImVec4(0.36, 0.18, 0.41, 1.00));
		style.setColor(ImGuiCol.TabDimmedSelected,      new ImVec4(0.46, 0.21, 0.54, 1.00));
		style.setColor(ImGuiCol.DockingPreview,         new ImVec4(0.56, 0.11, 0.71, 1.00));
		#end

		for (i in 0...CONSOLE_MAX_OUPUT) {
			consoleOutput.push({log: [], times: 0});
		}
	};

	private function addToConsole(text:Array<LogText>) {
		//if (wrapConsoleOutput) for (i in consoleOutputCurrentIndex...CONSOLE_MAX_OUPUT) {	//TODO: make it work with the wrapped lines

		//}

		//check for repeats
		var min = consoleOutputCurrentIndex-10;
		if (min < 0) min = 0;
		for (i in min...consoleOutputCurrentIndex) {
			var matching = true;
			if (text.length > 4 && text.length == consoleOutput[i].log.length) {
				for (textIndex in 3...consoleOutput[i].log.length) {
					if (text[textIndex].text != consoleOutput[i].log[textIndex].text) matching = false;
				}
			} else {
				matching = false;
			}
			if (matching) {
				consoleOutput[i].log = text;
				consoleOutput[i].times++;
				if (i != consoleOutputCurrentIndex-1) { //TODO: this should push to bottom instead of swapping since it doesnt always work
					var temp = consoleOutput[consoleOutputCurrentIndex-1];
					consoleOutput[consoleOutputCurrentIndex-1] = consoleOutput[i];
					consoleOutput[i] = temp;
				}
				return;
			}
		}
		addToConsoleOutput(text);
		//addToConsoleOutput([Logs.logText("\n")]);
		autoScrollNextFrame = true;
	}

	private inline function addToConsoleOutput(text:Array<LogText>) {
		consoleOutput[consoleOutputCurrentIndex] = {log: text, times: 1};
		consoleOutputCurrentIndex++;

		if (consoleOutputCurrentIndex >= CONSOLE_MAX_OUPUT) { //wrap around like a ring buffer
			consoleOutputCurrentIndex = 0;
			wrapConsoleOutput = true;
		}
	}

	public function toggleUI() {
		#if IMGUI
		active = !active;

		if (active) {
			FlxG.autoPause = false;
			FlxG.game.focusLostFramerate = 60;
			forceFocusTextInput = true;
			if (consoleHscript == null) consoleHscript = new ConsoleHscript();
		} else {
			FlxG.autoPause = Options.autoPause;
			ImGui.setKeyboardFocusHere(0);
		}
		#end
	}

	public function displayUI() {
		#if IMGUI
		ImGui.dockSpaceOverViewport(ImGui.getIDFromStr("windowDockspace"), null, ImGuiDockNodeFlags.PassthruCentralNode | ImGuiDockNodeFlags.AutoHideTabBar);
		if (ImGui.isKeyPressed(ImGuiKey.GraveAccent, false)) toggleUI();
		if (!active) return;

		ImGui.setNextWindowDockID(ImGui.getIDFromStr("windowDockspace"), ImGuiCond.Once);
		if (ImGui.begin("Console", null, 0)) {
			displayOutput();
			ImGui.separator();
			displayInput();
		}
		ImGui.end();

		if (settingsOpen.value) {
			if (ImGui.begin("Settings", settingsOpen, ImGuiWindowFlags.AlwaysAutoResize)) {
				//TODO: setup in translation xml
				ImGui.separatorText("Log Filter:");
				ImGui.checkbox("Time", timeFilter); ImGui.setItemTooltip("Toggles if timestamp shows in each log");
				ImGui.checkbox("Type", typeFilter); ImGui.setItemTooltip("Toggles if the type shows in each log");
				ImGui.separator();
				ImGui.checkbox("Info", infoFilter); ImGui.setItemTooltip("Toggles if info logs show");
				ImGui.checkbox("Warning", warningFilter); ImGui.setItemTooltip("Toggles if warning logs show");
				ImGui.checkbox("Error", errorFilter); ImGui.setItemTooltip("Toggles if error logs show");
				ImGui.checkbox("Trace", traceFilter); ImGui.setItemTooltip("Toggles if trace logs show");
				ImGui.checkbox("Verbose", verboseFilter); ImGui.setItemTooltip("Toggles if verbose logs show");
				ImGui.separatorText("Search Filter:");
				ImGui.checkbox("Commands", commandsFilter); ImGui.setItemTooltip("Toggles if commands show in the autofill");
				ImGui.checkbox("Classes", hscriptClassFilter); ImGui.setItemTooltip("Toggles if classes show in the autofill");
				ImGui.checkbox("Functions", hscriptFunctionFilter); ImGui.setItemTooltip("Toggles if functions show in the autofill");
				ImGui.checkbox("Basic Types", hscriptBasicTypesFilter); ImGui.setItemTooltip("Toggles if basic types (Int, Float, String) show in the autofill");
				ImGui.checkbox("Objects", hscriptObjectsFilter); ImGui.setItemTooltip("Toggles if objects show in the autofill");
				ImGui.checkbox("Script Variables", hscriptScriptsFilter); ImGui.setItemTooltip("Toggles if script variables show in the autofill");
			}
			ImGui.end();
		}
		#end
	}

	#if IMGUI
	private function displayOutput() {
		var windowWidth = ImGui.getWindowWidth();
		var windowHeight = ImGui.getWindowHeight();
		var outputHeight = windowHeight - (40 * style.fontScaleDpi); //I think scaling the dpi should be good enough?	//TODO: should probably look at this again
		//var outputHeight = windowHeight - (ImGui.getFrameHeightWithSpacing()*2);
		//if (ImGui.isWindowDocked()) windowHeight -= ImGui.getFrameHeightWithSpacing();
		if (outputHeight > 0) {
			ImGui.pushTextWrapPos();
			if (ImGui.beginChild("Console output", windowWidth, outputHeight)) {
				if (wrapConsoleOutput) {
					outputLog(consoleOutputCurrentIndex, CONSOLE_MAX_OUPUT);
				}
				outputLog(0, consoleOutputCurrentIndex);
			}
			if (autoScrollNextFrame) {
				ImGui.setScrollHereY(1.0);
				autoScrollNextFrame = false;
			}
			ImGui.endChild();
			ImGui.popTextWrapPos();
		}
	}

	private inline function outputLog(start:Int, end:Int) {
		var indicesToIgnore:Array<Int> = [];
		if (!timeFilter.value && !typeFilter.value) indicesToIgnore = [0, 1, 2, 3, 4];
		else if (!timeFilter.value) indicesToIgnore = [1, 2];
		else if (!typeFilter.value) indicesToIgnore = [2, 3];

		var i = start;
		while (i < end) {

			/*if (consoleOutput[i].log.length == 1) {
				ImGui.newLine();
				i++;
				continue;
			}*/
			if (consoleOutput[i].log.length > 4) {
				var type = consoleOutput[i].log[3].text;
				switch(type) {
					case Logs.LOG_INFORMATION_TEXT:
						if (!infoFilter.value) { i++; continue; }
					case Logs.LOG_WARNING_TEXT:
						if (!warningFilter.value) { i++; continue; }
					case Logs.LOG_ERROR_TEXT:
						if (!errorFilter.value) { i++; continue; }
					case Logs.LOG_TRACE_TEXT:
						if (!traceFilter.value) { i++; continue; }
					case Logs.LOG_VERBOSE_TEXT:
						if (!verboseFilter.value) { i++; continue; }
				}
			}

			for (textIndex => t in consoleOutput[i].log) {
				if (indicesToIgnore.contains(textIndex)) continue;
				if (!timeFilter.value && textIndex == 0) { //fix padding
					ImGui.sameLine(0, 0);
					ImGui.pushStyleColor(ImGuiCol.Text, consoleColorToImColor(t.color));
					ImGui.textUnformatted("[");
					ImGui.popStyleColor();
					continue;
				} else if (!typeFilter.value && textIndex == 4) {
					ImGui.sameLine(0, 0);
					ImGui.pushStyleColor(ImGuiCol.Text, consoleColorToImColor(t.color));
					ImGui.textUnformatted("  ] ");
					ImGui.popStyleColor();
					continue;
				}

				ImGui.sameLine(0, 0);
				ImGui.pushStyleColor(ImGuiCol.Text, consoleColorToImColor(t.color));
				var lines = t.text.split("\n");
				for (i => l in lines) {
					ImGui.textUnformatted(l);
				}
				ImGui.popStyleColor();
			}

			if (consoleOutput[i].times > 1) {
				ImGui.sameLine(0, 0);
				ImGui.textUnformatted("  ("+consoleOutput[i].times +"x)");
			}

			ImGui.newLine();
			i++;
		}
	}

	private function displayInput() {
		var inputTextCursorPos = ImGui.getCursorScreenPos();
		var temp = consoleInputString.value;
		final flags = ImGuiInputTextFlags.EnterReturnsTrue | ImGuiInputTextFlags.CallbackCompletion | ImGuiInputTextFlags.CallbackHistory | ImGuiInputTextFlags.CallbackEdit | ImGuiInputTextFlags.CallbackAlways;
		if (ImGui.inputText("Input##Console", consoleInputString, flags | (forceFocusTextInput ? ImGuiInputTextFlags.ReadOnly : 0), consoleInputTextCallback)) {
			if (consoleInputString.value != "") {
				//addToConsole(consoleInputString.value);
				tryExecuteCommand(consoleInputString.value);
				if (prevCommands[0] != consoleInputString.value) prevCommands.insert(0, consoleInputString.value);
				consoleInputString.value = "";
				ImGui.setKeyboardFocusHere(-1);
				autoScrollNextFrame = true;
				cyclingCommands = false;
				cyclingPrevCommands = false;
				commandSearch = [];
			}
		}
		if (forceFocusTextInput) {
			ImGui.setKeyboardFocusHere(-1);
			forceFocusTextInput = false;
		}
		
		if (consoleInputString.value != temp) {
			if ((cyclingCommands && getConsoleInputStringForSearch(commandSearch[cycleIndex]) == getCommandSearchAutoComplete(commandSearch[cycleIndex])) || (cyclingPrevCommands && consoleInputString.value == prevCommands[cycleIndex])) {
				
			} else {
				searchCommands(consoleInputString.value, consoleInputString.value.length < temp.length || temp.length == 0);
			}
		}
		ImGui.setScrollHereY(1.0);

		ImGui.sameLine();
		var settingButtonWidth = ImGui.calcTextSize("Settings").x + style.framePaddingX * 2;
		var pos = ImGui.getCursorPos();
		ImGui.setCursorPos(pos.x + ImGui.getContentRegionAvail().x - settingButtonWidth, pos.y);
		if (ImGui.button("Settings")) {
			settingsOpen.value = true;
		}

		if (commandSearch.length > 0) {
			var targetIndex = cyclingCommands ? cycleIndex : commandSearch.length;
			var start = targetIndex - (SEARCH_MAX_OUTPUT-1);
			var end = targetIndex+1;
			if (start < 0) start = 0;
			if (end < SEARCH_MAX_OUTPUT) end = SEARCH_MAX_OUTPUT;
			if (end > commandSearch.length) end = commandSearch.length;

			ImGui.pushStyleColor(ImGuiCol.WindowBg, CONSOLE_BG_COLOR);
			ImGui.setNextWindowPos(inputTextCursorPos.x, inputTextCursorPos.y - (ImGui.getTextLineHeightWithSpacing() * (end-start))-12);
			if (ImGui.begin("Command Search window", null, ImGuiWindowFlags.NoDecoration | ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoInputs | ImGuiWindowFlags.NoFocusOnAppearing)) {
				for (i in start...end) {
					var cmd = commandSearch[i];
					if (!cyclingCommands) {
						var cmdName:String = cmd.name;
						var inputName:String = getConsoleInputStringForSearch(cmd);
						var before:String = cmdName.substring(0, cmd.searchIndex);
						var after:String = cmdName.substring(cmd.searchIndex+inputName.length, cmdName.length);

						if (before != "") {
							if (i == commandSearch.length-1) ImGui.pushStyleColor(ImGuiCol.Text, 0xFFEEFF00);
							ImGui.textUnformatted(before);
							ImGui.sameLine(0, 0);
							if (i == commandSearch.length-1) ImGui.popStyleColor();
						}
						ImGui.pushStyleColor(ImGuiCol.Text, SEARCH_HIGHLIGHT_COLOR);
						ImGui.textUnformatted(cmdName.substring(cmd.searchIndex, cmd.searchIndex+inputName.length));
						ImGui.popStyleColor();
						if (after != "") {
							if (i == commandSearch.length-1) ImGui.pushStyleColor(ImGuiCol.Text, SEARCH_SELECTED_COLOR);
							ImGui.sameLine(0, 0);
							ImGui.textUnformatted(after);
							if (i == commandSearch.length-1) ImGui.popStyleColor();
						}

						if (inputName.length == cmd.name.length && cmd.autoComplete != null) {
							ImGui.sameLine();
							ImGui.textUnformatted("(TAB to Autocomplete)");
						}
					} else {
						if (i == cycleIndex) ImGui.pushStyleColor(ImGuiCol.Text, SEARCH_SELECTED_COLOR);
						ImGui.textUnformatted(cmd.name);
						if (i == cycleIndex) ImGui.popStyleColor();
					}

					if (cmd.desc != "") {
						ImGui.sameLine();
						//ImGui.indent();
						ImGui.pushStyleColor(ImGuiCol.Text, SEARCH_DESC_COLOR);
						ImGui.textUnformatted(cmd.desc);
						ImGui.popStyleColor();
					}
				}
			}
			ImGui.popStyleColor();
			ImGui.end();
		}
	}

	var thingsThatMeanTheresANewThing = " +-*/=|();,"; //TODO: name this something better
	var currentCursorPos = 0;
	var currentHscriptVarStart = 0;
	var currentHscriptVarEnd = 0;

	private function searchCommands(str:String, fullSearch:Bool) {
		cyclingCommands = false;
		cyclingPrevCommands = false;
		if (fullSearch) commandSearch = [];
		if (str == "") return;

		//for commands only, allow any case
		var strLower = str.toLowerCase();
		if (strLower.indexOf(" ") != -1) {
			strLower = strLower.substring(0, strLower.indexOf(" "));
		}
		
		//figure out the current hscript variable where the cursor is
		var pos:Int = currentCursorPos;
		if (pos < 0) pos = 0;
		if (pos > str.length-1) pos = str.length-1;
		var begin:Int = 0;
		var end:Int = str.length;
		for (i in 0...thingsThatMeanTheresANewThing.length) {
			var c = thingsThatMeanTheresANewThing.charAt(i);
			var b = str.lastIndexOf(c, pos);
			var e = str.indexOf(c, pos);
			if (b != -1 && b+1 > begin+1) begin = b+1;
			if (e != -1 && e < end) end = e;
		}
		var scriptVarStr = str.substring(begin, end);
		currentHscriptVarStart = begin;
		currentHscriptVarEnd = end;
		
		//trace(scriptVarStr, currentHscriptVarStart, currentHscriptVarEnd);

		if (!fullSearch) {	//TODO: something better to restore search when pressing backspace
			var prev = commandSearch;
			commandSearch = [];
			for (cmd in prev) {
				cmd.searchIndex = cmd.isCommand ? cmd.name.toLowerCase().indexOf(strLower) : cmd.name.indexOf(scriptVarStr);
				if (cmd.searchIndex != -1) {
					commandSearch.push(cmd);
				}
			}
		} else {
			if (commandsFilter.value) for (cmdName in ConsoleCommandManager.commandsStringList) {
				var searchIndex = cmdName.indexOf(strLower);
				if (searchIndex != -1) {
					commandSearch.push({
						name: cmdName,
						desc: ConsoleCommandManager.commands.get(cmdName).desc,
						searchIndex: searchIndex,
						isCommand: true
					});
				}
			}
		}

		//root hscript variables/classes
		if (fullSearch || scriptVarStr.length == 1) if (scriptVarStr.indexOf(".") == -1) {
			for (f in consoleHscript.variableFields) {
				if (!hscriptScriptsFilter.value && f.isScriptVar) continue;
				if (f.isStatic) {
					if (!hscriptClassFilter.value) continue;
				} else if (f.type == "Function") {
					if (!hscriptFunctionFilter.value) continue;
				} else if (f.type == "Int" || f.type == "Float" || f.type == "String") {
					if (!hscriptBasicTypesFilter.value) continue;
				} else {
					if (!hscriptObjectsFilter.value) continue;
				}

				var searchIndex = f.name.indexOf(scriptVarStr);
				if (searchIndex != -1) {
					commandSearch.push({
						name: f.name,
						desc: (f.isStatic ? "Class (" + f.type + ")" : f.type) + (f.value != "" ? " (" + f.value + ")" : "") + (f.extraDesc != null ? " (" + f.extraDesc + ")" : ""),
						searchIndex: searchIndex,
						isCommand: false,
						autoComplete: f.autoComplete
					});
				}
			}
		}

		//hscript var fields (after pressing .)
		if (scriptVarStr.charAt(scriptVarStr.length-1) == ".") {
			var fields = consoleHscript.tryGetFields(scriptVarStr.substr(0, -1));
			for (f in fields) {
				if (f.isStatic) {
					if (!hscriptClassFilter.value) continue;
				} else if (f.type == "Function") {
					if (!hscriptFunctionFilter.value) continue;
				} else if (f.type == "Int" || f.type == "Float" || f.type == "String") {
					if (!hscriptBasicTypesFilter.value) continue;
				} else {
					if (!hscriptObjectsFilter.value) continue;
				}
				var full = scriptVarStr + f.name;
				var searchIndex = full.indexOf(scriptVarStr);
				if (searchIndex != -1) {
					commandSearch.push({
						name: full,
						desc: f.type + (f.value != "" ? " (" + f.value + ")" : "") + (f.extraDesc != null ? " (" + f.extraDesc + ")" : ""),
						searchIndex: searchIndex,
						isCommand: false
					});
				}
			}
		}
		commandSearch.sort(function(a, b) {
			if (a.searchIndex < b.searchIndex) return 1;
			else if (a.searchIndex > b.searchIndex) return -1;
			else {
				if (a.name.length < b.name.length) return 1;
				else if (a.name.length > b.name.length) return -1;
				else return 0;
			}
		});
	}

	private inline function getCommandSearchAutoComplete(cmd:ConsoleSearchData) {
		return cmd.autoComplete != null ? cmd.autoComplete : cmd.name;
	}
	private inline function getConsoleInputStringForSearch(cmd:ConsoleSearchData) {
		return cmd.isCommand ? consoleInputString.value : consoleInputString.value.substring(currentHscriptVarStart, currentHscriptVarEnd);
	}

	private function onInputTextCallback(data:ImGuiInputTextCallbackData) {

		if (data.eventFlag == ImGuiInputTextFlags.CallbackHistory) { //when pressing up/down

			var justStartedCycling = false;
			if (commandSearch.length > 0 && !cyclingCommands && !cyclingPrevCommands) {
				cyclingCommands = true;
				cycleIndex = (data.eventKey == ImGuiKey.DownArrow) ? commandSearch.length-1 : 0;
				justStartedCycling = true;
			} else if (commandSearch.length == 0 && !cyclingPrevCommands && !cyclingCommands && consoleInputString.value == "" && prevCommands.length > 0 && data.eventKey == ImGuiKey.UpArrow) {
				cyclingPrevCommands = true;
				cycleIndex = 0;
				justStartedCycling = true;
			}

			if (cyclingCommands) {
				if (data.eventKey == ImGuiKey.UpArrow) {
					cycleIndex--;
					if (cycleIndex < 0) cycleIndex = commandSearch.length-1;
				} else {
					cycleIndex++;
					if (cycleIndex > commandSearch.length-1) cycleIndex = 0;
				}

				if (commandSearch[cycleIndex].isCommand) {
					data.deleteChars(0, data.bufTextLen);
					data.insertChars(0, getCommandSearchAutoComplete(commandSearch[cycleIndex]));
					data.setSelection(data.bufTextLen, data.bufTextLen);
				} else {
					var autoComplete = getCommandSearchAutoComplete(commandSearch[cycleIndex]);
					data.deleteChars(currentHscriptVarStart, currentHscriptVarEnd-currentHscriptVarStart);
					data.insertChars(currentHscriptVarStart, autoComplete);
					currentHscriptVarEnd = currentHscriptVarStart+autoComplete.length;
					data.setSelection(currentHscriptVarEnd, currentHscriptVarEnd);
				}
			}
			if (cyclingPrevCommands) {
				if (data.eventKey == ImGuiKey.DownArrow) {
					if (!justStartedCycling) cycleIndex--;
					if (cycleIndex < 0) cycleIndex = 0;
				} else {
					if (!justStartedCycling) cycleIndex++;
					if (cycleIndex > prevCommands.length-1) cycleIndex = prevCommands.length-1;
				}
				data.deleteChars(0, data.bufTextLen);
				data.insertChars(0, prevCommands[cycleIndex]);
				data.setSelection(data.bufTextLen, data.bufTextLen);
			}
		}
		else if (data.eventFlag == ImGuiInputTextFlags.CallbackCompletion) { //when pressing tab
			if (commandSearch.length > 0 && consoleInputString.value != getCommandSearchAutoComplete(commandSearch[commandSearch.length-1])) {
				if (commandSearch[commandSearch.length-1].isCommand) {
					data.deleteChars(0, data.bufTextLen);
					data.insertChars(0, getCommandSearchAutoComplete(commandSearch[commandSearch.length-1]));
					data.setSelection(data.bufTextLen, data.bufTextLen);
				} else {
					var autoComplete = getCommandSearchAutoComplete(commandSearch[commandSearch.length-1]);
					data.deleteChars(currentHscriptVarStart, currentHscriptVarEnd-currentHscriptVarStart);
					data.insertChars(currentHscriptVarStart, autoComplete);
					currentHscriptVarEnd = currentHscriptVarStart+autoComplete.length;
					data.setSelection(currentHscriptVarEnd, currentHscriptVarEnd);
				}
			}
		}
		else if (data.eventFlag == ImGuiInputTextFlags.CallbackEdit) {
			cyclingCommands = false;
			cyclingPrevCommands = false;
		} else if (data.eventFlag == ImGuiInputTextFlags.CallbackAlways) {
			currentCursorPos = data.cursorPos;
		}
	}
	#end

	private function clearConsole() {
		commandSearch = [];
		consoleOutputCurrentIndex = 0;
		wrapConsoleOutput = false;
	}

	private function tryExecuteCommand(str:String) {
		if (!ConsoleCommandManager.tryExecute(str)) { //run hscript if there was no command
			Logs.infos("Executing hscript: " + str, LIGHTGRAY, "Console");
			Logs.infos(Std.string(consoleHscript.tryExecute(str)), LIGHTGRAY, "Console");
		}
	}

	public static function consoleColorToImColor(color:ConsoleColor) {
		return switch(color) {
			case BLACK:			0xFF000000;
			case DARKBLUE:		0xFF0909C3;
			case DARKGREEN:		0xFF008800;
			case DARKCYAN:		0xFF008888;
			case DARKRED:		0xFF880000;
			case DARKMAGENTA:	0xFF9A1CC5;
			case DARKYELLOW:	0xFFBCBC00;
			case LIGHTGRAY:		0xFFD4D4D4;
			case GRAY:			0xFFA4A4A4;
			case BLUE:			0xFF2A4AEA;
			case GREEN:			0xFF00FF00;
			case CYAN:			0xFF008CFF;
			case RED:			0xFFFF0000;
			case MAGENTA:		0xFFFF00FF;
			case YELLOW:		0xFFFFFF00;
			case WHITE | _:		0xFFFFFFFF;
		}
	}
}