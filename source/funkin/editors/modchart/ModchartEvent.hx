package funkin.editors.modchart;

class ModchartEvent {

	public var step:Float = 0;
	public var endStep:Float = 0;
	public var value:Float = 0;
	public var lastValue:Float = 0;

	public var lastIndex:Int = -1;
	public var nextIndex:Int = -1;
	public var itemIndex:Int = -1;

	public var selected:Bool = false;
	
	public function new() {}

	public function getTimelineItemName() { return "Unknown"; }
	public function loadXML(node:Xml) {
		setStep(Std.parseFloat(node.get("step")));
		this.value = Std.parseFloat(node.get("value"));
	}

	public function setStep(s:Float) {
		//can override for other events to correctly set endstep
		this.step = this.endStep = s;
	}

	public function update(currentStep:Float, item:ModchartTimelineItem) {
		item.currentValue = value;
	}
}