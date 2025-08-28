package funkin.editors.modchart;

import flixel.util.FlxDestroyUtil;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.system.Conductor;
import flixel.util.FlxAxes;

class ModchartTimelineUI extends FlxBasic {

	private var timeline:ModchartTimeline;

	public var valuesBG = new FlxSprite();
	public var itemsBG = new FlxSprite();
	public var valuesLine = new FlxSprite();
	public var itemsLine = new FlxSprite();
	

	public var nameTexts:FlxTypedGroup<UIText> = new FlxTypedGroup<UIText>();
	public var valueTexts:FlxTypedGroup<UIText> = new FlxTypedGroup<UIText>();

	public var overlays:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var beatSeparator:FlxBackdrop; //TODO: rework for time sig changes
	var sectionSeparator:FlxBackdrop;
	
	override public function new(timeline:ModchartTimeline) {
		super();
		this.timeline = timeline;

		valuesBG.makeGraphic(1,1);
		valuesBG.setGraphicSize(50,1280);
		valuesBG.updateHitbox();
		valuesBG.color = 0xff302e32;
		valuesBG.cameras = [ModchartEditor.instance.camTimelineValueList];
		valuesBG.scrollFactor.set();

		valuesLine = new FlxSprite(200-2,0);
		valuesLine.makeGraphic(1,1);
		valuesLine.setGraphicSize(2,1280);
		valuesLine.updateHitbox();
		valuesLine.cameras = [ModchartEditor.instance.camTimelineList];
		valuesLine.scrollFactor.set();

		itemsLine = new FlxSprite(50-2,0);
		itemsLine.makeGraphic(1,1);
		itemsLine.setGraphicSize(2,1280);
		itemsLine.updateHitbox();
		itemsLine.cameras = [ModchartEditor.instance.camTimelineValueList];
		itemsLine.scrollFactor.set();

		sectionSeparator = new FlxBackdrop(null, FlxAxes.X, 0, 0);
		sectionSeparator.x = -2;

		beatSeparator = new FlxBackdrop(null, FlxAxes.X, 0, 0);
		beatSeparator.x = -1;

		for(sep in [sectionSeparator, beatSeparator]) {
			sep.makeSolid(1, 1, -1);
			sep.alpha = 0.5;
			sep.scrollFactor.set(1, 0);
			sep.scale.set(sep == sectionSeparator ? 4 : 2, 720);
			sep.cameras = [ModchartEditor.instance.camTimeline];
			sep.updateHitbox();
		}		

		nameTexts.cameras = [ModchartEditor.instance.camTimelineList];
		valueTexts.cameras = [ModchartEditor.instance.camTimelineValueList];
	}

	public function generateUI() {

		nameTexts.clear();
		valueTexts.clear();
		
		for (i => name in timeline.list) {
			nameTexts.add(new UIText(10, 0, 0, name, 15));
			valueTexts.add(new UIText(10, 0, 0, "-", 15));
		}
	}

	override public function update(elapsed:Float) {
		for (i in 0...nameTexts.members.length) {
			nameTexts.members[i].y = valueTexts.members[i].y = ModchartEditor.instance.ROW_SIZE_Y * i;
		}

		sectionSeparator.spacing.x = ((ModchartEditor.instance.ROW_SIZE_X/4) * Conductor.beatsPerMeasure * Conductor.stepsPerBeat) - 1;
		beatSeparator.spacing.x = ((ModchartEditor.instance.ROW_SIZE_X/2) * Conductor.stepsPerBeat) - 1;
		valuesLine.x = ModchartEditor.instance.VALUE_LIST_POS-2;

		for (obj in [valuesBG, valuesLine, itemsLine, nameTexts, valueTexts, beatSeparator, sectionSeparator]) {
			obj.update(elapsed);
		}
	}

	override public function draw() {
		for (obj in [valuesBG, valuesLine, itemsLine, nameTexts, valueTexts, beatSeparator, sectionSeparator]) {
			obj.draw();
		}
	}

	override public function destroy() {
		super.destroy();
		itemsBG = FlxDestroyUtil.destroy(itemsBG);
		valuesBG = FlxDestroyUtil.destroy(valuesBG);
		valuesLine = FlxDestroyUtil.destroy(valuesLine);
		itemsLine = FlxDestroyUtil.destroy(itemsLine);
		nameTexts = FlxDestroyUtil.destroy(nameTexts);
		valueTexts = FlxDestroyUtil.destroy(valueTexts);
		overlays = FlxDestroyUtil.destroy(overlays);
		beatSeparator = FlxDestroyUtil.destroy(beatSeparator);
		sectionSeparator = FlxDestroyUtil.destroy(sectionSeparator);
	}
}