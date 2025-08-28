package funkin.editors.modchart.items;

import funkin.backend.shaders.CustomShader;

class PostProcessShaderItem extends ModchartTimelineItem {

	public var property:String;
	public var shader:CustomShader;

	override public function new(name:String, property:String, shader:CustomShader) {
		super(name);
		this.property = property;
		this.shader = shader;
	}

	override public function getTimelineItemName() { return name + "." + property; }
	override public function getEventName() { return "TweenShaderProperty"; }

	override public function update() {
		shader.hset(property, currentValue);
	}
}