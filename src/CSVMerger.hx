import js.html.SelectElement;
import js.html.Console;
import CSV.CSVData;
import js.html.Blob;
import js.html.InputElement;
import js.html.TextAreaElement;
import js.html.Element;

class CSVMerger {
	static inline function find<T:Element>(query:String, ?c:Class<T>):T {
		return document.querySelectorAuto(query);
	}
	static function mergeLoc(
		base:CSVFieldSet, patch:CSVFieldSet,
		skipGroupsText:String, skipExceptions:Map<String, Bool>,
		resultCtxValue:String
	) {
		var baseTable = base.parse();
		var baseCtx = base.wantContext(baseTable);
		var baseTextAt = baseCtx ? 3 : 2;
		//
		var patchTable = patch.parse();
		var patchCtx = patch.wantContext(patchTable);
		var patchCtxAt = patchCtx ? 3 : 2;
		//
		var resultCtx = switch (resultCtxValue) {
			case "on": true;
			case "off": false;
			default: baseCtx || patchCtx;
		}
		//
		var skipGroups:Array<Array<String>> = [];
		for (row in skipGroupsText.split("\n")) {
			row = row.trim();
			if (row == "") continue;
			skipGroups.push(row.split("*"));
		}
		function shouldSkipGroup(group:String, skipGroups:CSVData) {
			for (skipper in skipGroups) {
				var start = 0;
				var useSnip = false;
				var match = true;
				for (part in skipper) {
					useSnip = part != "";
					if (useSnip) {
						var pos = group.indexOf(part, start);
						if (pos < 0) {
							match = false;
							break;
						}
						start = pos + part.length;
					}
				}
				if (!match) continue;
				if (useSnip && start < group.length) continue;
				return true;
			}
			return false;
		}
		//
		var header = patchTable[0];
		var out:CSVData = [header];
		var cols = header.length;
		for (i in 1 ... baseTable.length) {
			var baseRow = baseTable[i];
			var group = baseRow[0];
			var key = baseRow[1];
			var text = baseRow[baseTextAt];
			if (shouldSkipGroup(group, skipGroups)) {
				if (!skipExceptions[group + ":" + key]) {
					continue;
				}
			}
			//
			var patchRow = patchTable.find(row -> {
				return row[0] == group && row[1] == key && row[patchCtxAt] == text;
			});
			if (patchRow != null) {
				if (resultCtx) {
					if (!patchCtx) patchRow.insert(2, "");
				} else {
					if (patchCtx) patchRow.splice(2, 1);
				}
				out.push(patchRow);
			} else {
				Console.log("Missing:", [group, key, text]);
				if (resultCtx) {
					if (!baseCtx) baseRow.insert(2, "");
				} else {
					if (baseCtx) baseRow.splice(2, 1);
				}
				// pad out
				for (_ in baseRow.length ... cols) baseRow.push("");
				out.push(baseRow);
			}
		}
		return CSV.serialize(out);
	}
	public static function main() {
		//
		var base = new CSVFieldSet(find("#base"));
		var patch = new CSVFieldSet(find("#patch"));
		var result:TextAreaElement = find("#result");
		var resultCtx:SelectElement = find("#result-ctx");
		var skipGroupsField:TextAreaElement = find("#skip-groups");
		var skipExceptions:TextAreaElement = find("#skip-exceptions");
		var merge:InputElement = find("#merge");
		merge.onclick = (e) -> {
			result.value = "Merging...";
			var exceptMap = new Map();
			for (line in skipExceptions.value.split("\n")) exceptMap[line] = true;
			window.setTimeout(() -> {
				result.value = mergeLoc(base, patch,
					skipGroupsField.value, exceptMap,
					resultCtx.value);
			});
		}
		//
		var saveResult:InputElement = find("#result-save");
		saveResult.onclick = (e) -> {
			var blob = new Blob([result.value]);
			(cast window).saveAs(blob, "result.csv");
		}
	}
}
