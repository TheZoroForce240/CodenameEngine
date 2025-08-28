package funkin.editors.modchart;

import funkin.editors.modchart.events.*;
import funkin.editors.modchart.items.*;
import funkin.editors.modchart.managers.*;

class ModchartTimeline {
	public var list:Array<String> = [];
	public var items:Array<ModchartTimelineItem> = [];
	public var indexMap:Map<String, Int> = [];

	public var events:Array<ModchartEvent> = [];
	public var eventIndexList:Array<Int> = [];

	var lastStep = Math.NEGATIVE_INFINITY;

	var registeredItemManagers:Map<String, ModchartTimelineItemManager> = [];
	public function new() {
		registeredItemManagers.set("PostProcessShaderItemManager", new PostProcessShaderItemManager(this));
	}

	public function addTimelineItem(item:ModchartTimelineItem) {
		if (indexMap.exists(item.name)) {
			trace("duplicate timeline item?");
		}
		items.push(item);
		list.push(item.name);
		indexMap.set(item.name, items.length-1);
	}

	public inline function resetValuesToDefault() {
		for (item in items) {
			item.currentValue = item.defaultValue;
		}
	}
	public function refreshEventTimings() {
		eventIndexList = [];
		for (item in items) {
			item.currentValue = item.defaultValue;
			item.lastValue = Math.NEGATIVE_INFINITY;
			eventIndexList.push(-1);
		}
		lastStep = Math.NEGATIVE_INFINITY; //todo

		//map indexes and values so each event knows its last/next index and value
		for (i in 0...events.length) {
			var e = events[i];
			e.lastIndex = -1;
			e.nextIndex = -1;

			var itemIndex = indexMap.get(e.getTimelineItemName());
			var item = items[itemIndex];

			e.lastValue = item.currentValue;
			e.itemIndex = itemIndex;

			if (eventIndexList[itemIndex] == -1) {
				eventIndexList[itemIndex] = i;
			} else {
				var lastIndex = eventIndexList[itemIndex];
				events[lastIndex].nextIndex = i;
				e.lastIndex = lastIndex;
				e.lastValue = events[lastIndex].value;

				//if (events[lastIndex].DI_value != null && events[lastIndex].DI_value)
					//e.lastValue = -e.lastValue;

				eventIndexList[itemIndex] = i;
			}
		}
	}

	public function updateEvents(currentStep:Float) {
		for (itemIndex => index in eventIndexList) {
			var i = index;
			if (events[i] == null) continue;

			if (lastStep != currentStep) {

				if (currentStep > lastStep) {
					//check for next event
					if (events[i].nextIndex != -1) {
						while(true) {
							var nextIndex = events[i].nextIndex;
							if (currentStep >= events[nextIndex].step) {
								i = nextIndex;
								if (events[i].nextIndex == -1) {
									break;
								}
							} else {
								break;
							}
						}
					}
				} else {
					//check for last (for rewinding)
					if (events[i].lastIndex != -1) {
						while(true) {
							var lastIndex = events[i].lastIndex;
							if (currentStep < events[lastIndex].endStep) {
								i = lastIndex;
								if (events[i].lastIndex == -1) {
									break;
								}
							} else {
								break;
							}
						}
					}
				}
			}

			if (i != index) {
				eventIndexList[itemIndex] = i;
			}

			var e = events[i];
			if (currentStep >= e.step) {
				e.update(currentStep, items[itemIndex]);
			} else {
				items[itemIndex].currentValue = e.lastValue;
			}
		}

		for (i => item in items) {
			if (item.currentValue != item.lastValue) {
				item.lastValue = item.currentValue;
				item.update();
			}
		}

		lastStep = currentStep;
	}

	function sortEvents() {
		events.sort(function(a, b) {
			if(a.step < b.step) return -1;
			else if(a.step > b.step) return 1;
			else return 0;
		});
	}

	public function loadItems(xml:Xml) {
		for (itemList in xml.elementsNamed("Init")) {
			for (name => manager in registeredItemManagers) {
				manager.parseItems(itemList);
			}
		}
	}

	public function loadEvents(xml:Xml) {

	}
}