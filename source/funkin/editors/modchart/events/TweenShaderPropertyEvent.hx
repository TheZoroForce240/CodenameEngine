package funkin.editors.modchart.events;

class TweenShaderPropertyEvent extends ModchartEvent {
	public var name:String = "";
	public var property:String = "";
	public var time:Float = 0;
	public var ease:String = "linear";
	public var startValue:Float = 0;

	//Downscroll Inverse
	//TODO
	public var DI_startValue:Bool = false;
	public var DI_value:Bool = false;

	override public function getTimelineItemName() { return name + "." + property; }
	override public function loadXML(node:Xml) {
		this.name = node.get("name");
		this.property = node.get("property");
		this.time = Std.parseFloat(node.get("time"));
		this.ease = node.get("ease");
		this.startValue = Std.parseFloat(node.get("startValue"));

		//needs to be called after to get correct endStep
		super.loadXML(node);
	}

	override public function setStep(s:Float) {
		super.setStep(s);
		endStep = step + time;
	}

	override public function update(currentStep:Float, item:ModchartTimelineItem) {
		var downscroll = ModchartEditor.instance.downscroll;
		if (currentStep < endStep) {
			var easeFunc:Float->Float = CoolUtil.flxeaseFromString(ease, "");

			var startVMult:Float = (DI_startValue && downscroll) ? -1.0 : 1.0;
			var vMult:Float = (DI_value && downscroll) ? -1.0 : 1.0;

			var l = (currentStep - step) * (1.0 / (endStep - step));
			var newValue = FlxMath.lerp(startValue*startVMult, value*vMult, easeFunc(l));

			item.currentValue = newValue;
		} else {
			var vMult:Float = (DI_value && downscroll) ? -1.0 : 1.0;
			item.currentValue = value*vMult;
		}
	}
}