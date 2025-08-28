package funkin.editors.modchart;

class ModchartTimelineItem {
	public var name:String;

	public var defaultValue:Float = 0;
	public var currentValue:Float = 0;
	public var lastValue:Float = 0;

	public function new(name:String) { this.name = name; }

	public function getTimelineItemName() { return name; }
	public function getEventName() { return "Unknown"; }

	public function update() {}
}