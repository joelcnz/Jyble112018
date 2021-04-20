
//#new
import base;

import maingui;

version(unittest) {
} else { void main(string[] args) {
	scope(exit) {
		import std.stdio : writeln;

		writeln;
		writeln("## ");
		writeln("# #");
		writeln("## ");
		writeln("# #");
		writeln("## ");
		writeln;
	}

	// loadCrossRefs("cross_references.txt"); //#new
	loadCrossRefs();

	Main.init(args);

	g_RigWindow = new RigWindow();

	import std.string : chomp;

	immutable fileName = "filtersetc.txt";
	enum Type {COMMAND, SEARCH, TITLE, SUB_TITLE, SEARCH_TYPE, CASE, APPEND}
	int i;
	foreach(data; File(fileName).byLine) {
		auto line = data.to!string.chomp;
		if (line.length)
			switch(i) with (Type) {
				default: gh(fileName ~ " - error"); return;
				case COMMAND: g_RigWindow.getAppBox.getShortBigBoxesBoxCommandBoxEntry.setText = line; break;
				case SEARCH: g_RigWindow.getAppBox.getShortSearchBoxEntry.setText = line; break;
				case TITLE: g_RigWindow.getAppBox.getExtractTitleEntry.setText = line; break;
				case SUB_TITLE: g_RigWindow.getAppBox.getExtractSubTitleEntry.setText = line; break;
				case SEARCH_TYPE:
					try {
						g_RigWindow.getAppBox.getSearchBox.getSearchRadioBox.setActivateButtonByNumber(line.to!int);
					} catch(Exception e) {
						"Invalid number. non fatal error".gh;
					}
				break;
				case CASE:
					g_RigWindow.getAppBox.getSearchBox.getCaseCheckButton.setActive(line == "1" ? true : false);
				break;
				case APPEND:
					g_RigWindow.getAppBox.getSearchBox.getAppendCheckButton.setActive(line == "1" ? true : false);
				break;
			}
		i += 1;
	}
	if (i - 1 < Type.max.to!int) {
		gh(fileName ~ " - error (wrong number of lines)");
		return;
	}

	Main.run();
}
} // version unittest