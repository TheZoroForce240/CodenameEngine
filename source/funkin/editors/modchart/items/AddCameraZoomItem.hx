package funkin.editors.modchart.items;

class AddCameraZoomItem extends ModchartTimelineItem {
	public function new() { super("AddCameraZoom"); } //can only be one
	override public function getEventName() { return "AddCameraZoom"; }
}