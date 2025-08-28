package funkin.editors.modchart.events;

class AddCameraZoomEvent extends ModchartEvent {
	public var triggered:Bool = false;

	override public function getTimelineItemName() { return "AddCameraZoom"; }

	override public function update(currentStep:Float, item:ModchartTimelineItem) {
		if (!triggered && Math.floor(currentStep) == Math.floor(step)) {
			ModchartEditor.instance.camGame.zoom += value;
			triggered = true; 
		}
		if (Math.floor(currentStep) != Math.floor(step)) {
			triggered = false; //reset once the step has changed
		}
	}
}