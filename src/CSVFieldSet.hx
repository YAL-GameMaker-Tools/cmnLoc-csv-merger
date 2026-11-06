import CSV;
import js.html.FileReader;
import js.html.SelectElement;
import js.html.TextAreaElement;
import js.html.InputElement;
import js.html.FormElement;
import js.html.FieldSetElement;

class CSVFieldSet {
	public var fieldSet:FieldSetElement;
	public var form:FormElement;
	public var picker:InputElement;
	public var textArea:TextAreaElement;
	public var contextMode:SelectElement;
	public function new(fs:FieldSetElement) {
		fieldSet = fs;
		form = fs.querySelectorAuto("form");
		picker = form.querySelectorAuto("input");
		textArea = fs.querySelectorAuto("textarea");
		contextMode = fs.querySelectorAuto("select.context");
		//
		picker.addEventListener("change", (e) -> {
			var file = picker.files[0];
			if (file == null) return;
			textArea.value = "Loading...";
			window.setTimeout(() -> {
				var reader = new FileReader();
				reader.onerror = (e) -> {
					textArea.value += "\n" + e;
				}
				reader.onloadend = () -> {
					form.reset();
				}
				reader.onload = () -> {
					textArea.value = reader.result;
				}
				reader.readAsText(file);
			});
		});
	}
	public function parse():CSVData {
		return CSV.parse(textArea.value);
	}
	public function wantContext(table:CSVData) {
		return switch (contextMode.value) {
			case "on": true;
			case "off": false;
			default: table[0] != null && table[0][2] == "Context";
		}
	}
}