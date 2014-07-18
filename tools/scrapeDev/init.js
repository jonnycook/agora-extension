$(function() {
	// var value = "// The bindings defined specifically in the Sublime Text mode\nvar bindings = {\n";
	// var map = CodeMirror.keyMap.sublime, mapK = CodeMirror.keyMap["sublime-Ctrl-K"];
	// for (var key in map) {
	// 	if (key != "Ctrl-K" && key != "fallthrough" && (!/find/.test(map[key]) || /findUnder/.test(map[key])))
	// 	value += "  \"" + key + "\": \"" + map[key] + "\",\n";
	// }
	// for (var key in mapK) {
	// 	if (key != "auto" && key != "nofallthrough")
	// 		value += "  \"Ctrl-K " + key + "\": \"" + mapK[key] + "\",\n";
	// }
	// value += "}\n\n// The implementation of joinLines\n";
	// value += CodeMirror.commands.joinLines.toString().replace(/^function\s*\(/, "function joinLines(").replace(/\n  /g, "\n") + "\n";
	window.editor = CodeMirror(document.getElementById('editor'), {
		lineNumbers: true,
		mode: "coffeescript",
		keyMap: "sublime",
		autoCloseBrackets: true,
		matchBrackets: true,
		showCursorWhenSelecting: true,
		theme: "monokai",
		lineWrapping: true,
		indentWithTabs: true,
		tabSize: 2
	});
})