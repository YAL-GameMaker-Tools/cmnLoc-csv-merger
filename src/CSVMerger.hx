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
	static function mergeLoc(base:CSVFieldSet, patch:CSVFieldSet, skipGroupsText:String) {
		var baseTable = base.parse();
		var baseCtx = base.wantContext(baseTable);
		var baseTextAt = baseCtx ? 3 : 2;
		//
		var patchTable = patch.parse();
		var patchCtx = patch.wantContext(patchTable);
		var patchCtxAt = patchCtx ? 3 : 2;
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
				for (part in skipper) {
					useSnip = part != "";
					if (useSnip) {
						var pos = group.indexOf(part, start);
						if (pos < 0) continue;
						start = pos + part.length;
					}
				}
				if (useSnip && start < group.length) continue;
				return true;
			}
			return false;
		}
		(cast window).shouldSkipGroup = shouldSkipGroup;
		//
		var header = patchTable[0];
		var out:CSVData = [header];
		var cols = header.length;
		for (i in 1 ... baseTable.length) {
			var baseRow = baseTable[i];
			var group = baseRow[0];
			var key = baseRow[1];
			var text = baseRow[baseTextAt];
			var patchRow = patchTable.find(row -> {
				return row[0] == group && row[1] == key && row[patchCtxAt] == text;
			});
			if (patchRow != null) {
				out.push(patchRow);
			} else {
				Console.log("Missing:", [group, key, text]);
				var copy = baseRow.copy();
				for (_ in copy.length ... cols) copy.push("");
				out.push(copy);
			}
		}
		return CSV.serialize(out);
	}
	public static function main() {
		//
		var base = new CSVFieldSet(find("#base"));
		var patch = new CSVFieldSet(find("#patch"));
		var result:TextAreaElement = find("#result");
		var skipGroupsField:TextAreaElement = find("#skip-groups");
		var merge:InputElement = find("#merge");
		merge.onclick = (e) -> {
			result.value = "Merging...";
			window.setTimeout(() -> {
				result.value = mergeLoc(base, patch, skipGroupsField.value);
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
