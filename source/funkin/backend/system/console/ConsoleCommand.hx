package funkin.backend.system.console;
import funkin.backend.system.console.ConsoleCommandManager;

class BaseCommand {
	public var name:String;
	public var desc:String;

	@:allow(funkin.backend.system.console.ConsoleCommandManager)
	private var _nameLower:String;

	public function new(name:String, desc:String) {
		this.name = name;
		this.desc = desc;
		_nameLower = name.toLowerCase();
		ConsoleCommandManager.registerCommand(this);
	}
	public function execute(raw:String) {};

	public static function parseArgs(raw:String) {
		var args:Array<String> = [];
		if (raw == "") return args;

		var i:Int = 0;
		var curStr = "";
		var parseState = 0;
		while(true) {
			var char = raw.charAt(i);
			if (parseState == 0 && char == " ") {
				if (curStr != "") args.push(curStr);
				curStr = "";
			} else if (parseState == 0 && char == "\"") {
				parseState = 1;
			} else if (parseState == 1 && char == "\"") {
				parseState = 0;
			} else if (parseState == 0 && char == "'") {
				parseState = 2;
			} else if (parseState == 2 && char == "'") {
				parseState = 0;
			} else {
				curStr += char;
			}
			
			i++;
			if (i > raw.length-1) {
				if (curStr != "") args.push(curStr);
				break;
			}
		}
		return args;
	}
}

class FuncCommand extends BaseCommand {
	public var func:Array<String>->Void;
	override public function new (name:String, desc:String, func:Array<String>->Void) {
		super(name, desc);
		this.func = func;
	}
	override public function execute(raw:String) {
		func(BaseCommand.parseArgs(raw));
	}
}
