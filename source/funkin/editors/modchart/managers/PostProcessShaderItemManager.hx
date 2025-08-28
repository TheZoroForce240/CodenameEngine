package funkin.editors.modchart.managers;

import funkin.backend.shaders.CustomShader;

class PostProcessShaderItemManager extends ModchartTimelineItemManager {
	override public function parseItems(xml:Xml) {
		for (node in xml.elementsNamed("Shader")) {
			var shader = new CustomShader(node.get("shader"));
		}
	}
	override public function parseEvents(xml:Xml) {
		
	}
}