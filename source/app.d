//#hmm..
//#There is a big gap between some verses (like Jude only has 1 chapter)
//#tried %-20 etc but it just mucks up
import std.stdio;
import std.string;
import std.array: split, replace;
import std.file;
import std.conv;
import std.process;
import std.range;
import std.datetime;

import dunit;
import dlangui;

import arsd.dom: Document, Element;
import arsd.terminal;

import bible.base, jmisc;

mixin APP_ENTRY_POINT;

class TestUnitTest {
	mixin UnitTest;

	@Test
	void tfail() {
		assert(false);
	}

	@Test
	void tpass() {
		assert(true);
	}

    @Test
    void assertEqualsFailure()
    {
        string expected = "bar";
        string actual = "baz";

        assertEquals(expected, actual);
    }
}

// production
struct MainWindow {
	Window _window;
	EditBox _editBoxMain;


	string _input;
	bool _done = false, _doVerse;

	int setup() {
		version(none)
			dunit_main(dargs);

		//#stuff at the start (in the terminal when the the program is run)
		immutable ESV = "esv";
		loadBible(ESV);

		g_wrap = true;

		_window = Platform.instance.createWindow(
			"GUI Jyble Bible Program", null, WindowFlag.Resizable, 1280, 800);
		
		// Crease widget to show in window
		_window.mainWidget = parseML(q{
			VerticalLayout {
				margins: 3
				padding: 3
				EditBox {
					id: editBoxMain
					minWidth: 640; minHeight: 700; maxHeight: 640;
				}

				Button { id: buttonActivate; maxWidth: 100; text: "Activate" }
			}
		});

		_editBoxMain = _window.mainWidget.childById!EditBox("editBoxMain");
		_window.mainWidget.childById!Button("buttonActivate").click = delegate(Widget w) {
			import std.conv: to;

			auto t = _editBoxMain.text.to!string;
			size_t i = t.lastIndexOf("\n");
			if (i != -1) {
				processLastLine(t[i + 1 .. $]);

				return true;
			}
			return false;
		};

		_editBoxMain.text = "Insert 'h' at the bottom of the line, then press the Activate button for help\n".to!dstring;

		_window.show();

		return 0;
	}

	void processLastLine(in string input) {
		string output;

		import std.stdio;
		import std.conv;

		_doVerse = true;
		//writeln("q - quit h - help. eg Joel 1 1 - -1 -- for whole chapter");
		if (input.length) {
			immutable base = input.split[0];
			immutable args = input.split[1 .. $];

	//		trace!base;

			_doVerse = false;
			switch(base) {
				default: _doVerse = true; break;
				case "q":
					_done = true;

					return; //#Hmm..
				case "h":
					output =
						"\nq - quit\n" ~
						"<verse ref> eg. 1) Joel 1, 2) Joel 1 5, 3) Joel 1 5 - 10, 4) Joel 1 -1 - 2 3\n" ~
						"ps <phrase search>\n" ~
						"ws <word search whole words>\n" ~
						"pws <word search includes part words>\n" ~
						"els <word> <book number> <start number> - code\n" ~
						"chp # - (for search results)\n" ~
						"btn <book name> book name to number\n" ~
						"marker # - draw marker\n" ~
						"*s - slide show\n" ~
						"books - list of book names\n" ~
						"everyChp - eg. 'everyChp Joh n 1' - John 1 1, John 2 1, etc\n" ~
						"everyBook - eg. 'everyBook 1 1' - Gen 1 1 .., Exo 1 1 .., etc\n" ~
						"expVers - eg. 'expVers highlites.txt' output to exp_highlites.txt\n" ~
						"info - number of verses etc\n" ~
						"bible <esv>/<kjv>\n" ~
						"h - help";
				break;
				case "bible":
					import std.algorithm: any;
					import std.string: toLower;

					auto biblesList = "esv kjv";
					auto bibleVersion = args[0].toLower;
					if (args.length == 1 && any!(a => a == bibleVersion)(biblesList.split)) {
						loadBible(bibleVersion);
						output = text(bibleVersion, " Bible version loaded..");
					} else
						output = args[0] ~ " - Invalid input, use one of these: " ~ biblesList;
				break;
				case "info":
					output = g_info.toString;
				break;
				case "expVers":
					if (args.length && args[0].exists) {
							auto fileName = "exp_" ~ args[0];
							
							output = g_bible.expVers(args[0], fileName) ~ "\n";
							output ~= "Out put file " ~ fileName;
					} else {
						output = args[0] ~ " doesn't exist!";
					}
				break;
				//#There is a big gap between some verses (like Jude only has 1 chapter)
				case "everyBook": // n 1 1 eg. Gen 1 1 .., Exo 1 1 ..
					auto args2 = args.dup;
					try {
						int chp = 1, ver = 1;
						foreach(n; 1 .. 66 + 1) {
							string result;
							
							//if wild card, use counter
							if (args[0] == "n")
								args2[0] = chp.to!string;

							if (args[1] == "n")
								args2[1] = ver.to!string;

							result = n.to!string ~ " " ~ args2.join(" ");
							auto output2 = g_bible.argReference(g_bible.argReferenceToArgs(result));
							if (output2 != "")
								output ~= output2;

							chp += 1;
							ver += 1;
						}
					}
					catch(Exception e) {
						output = "Could not be done!";
					}
				break;
				case "everyChp": // Joh n 1 (John 1 1 (verse), John 2 1 (verse) etc)
						mixin(trace("args"));
						try {
							if (args.length > 2) {
								foreach(n; 1 .. g_bible.getBook(g_bible.bookNumberFromTitle(args[0])).m_chapters.length + 1) {
									string result;

									result = text(args[0], ' ', n.to!string, ' ', args[2 .. $].join(" "));
									output ~= g_bible.argReference(g_bible.argReferenceToArgs(result));
								}
							}
						}
						catch(Exception e) {
							output = "Could not be done!";
						}
				break;
				case "books":
					string bookName(int bn) {
						return g_bible.getBook(bn).m_bookTitle ~ "\t";
					}
					foreach(bn; iota(1, 23, 1)) {
						import std.array : replicate;
						//#tried %-20 etc but it just mucks up
						string[] bookNames;
						bookNames ~= bookName(bn + 00);
						bookNames ~= bookName(bn + 22);
						bookNames ~= bookName(bn + 44);
						output ~= format("%20s%20s%20s\n",
							(bn + 00).to!string ~ (bn < 10 ? " -" : " ") ~ "-".replicate(17 - bookNames[0].length) ~ " " ~ bookNames[0],
							(bn + 22).to!string ~ " " ~ "-".replicate(17 - bookNames[1].length) ~ " " ~ bookNames[1],
							(bn + 44).to!string ~ " " ~ "-".replicate(17 - bookNames[2].length) ~ " " ~ bookNames[2]);
					}
				break;
				case "wrap":
					if (args.length == 0) {
						g_wrap = false;
						output = "Text wrap is off";
					} else {
						if (args.length == 1) {
							g_wrap = true;
							try {
								g_wrapWidth = args[0].to!int;
								output = "Wrap width set";
							} catch(Exception e) {
								g_wrap = false;
								output = "Error, text wrap has defaulted to off.";
							}
						}
					}
				break;
				case "btn":
					if (args.length == 1) {
						try {
							output = text("Book: ", args[0], " number: ", g_bible.bookNumberFromTitle(args[0]).to!string);
						} catch(Exception e) {
							output = "Invalid book name";
						}
					} else {
						output = "You missed the name of the book!";
					}
				break;
				case "els":
					size_t bookNumber, startNumber = 1;
					if (args.length == 3) {
						string s = args[2];
						try {
							startNumber = s.parse!size_t;
						} catch(Exception e) {
							output = text(s, " - invalid start number.");
							break;
						}
					}
					if (startNumber <= 0) {
						output = "Too lower start number.";
						break;
					}
					if (args.length >= 2) {
						if (args[0].length == 1) {
							output = "You need more than one character!";
							break;
						}
						try { //20 + 32 + 21 = 73
							output = equalDistanceLetterSequence(
								args[0],
								g_bible.bookNumberFromTitle(args[1]) - 1, startNumber);
						} catch(Exception e) {
							output = "Input error..";
						}
					}
				break;
				case "ps":
					output = args.join(" ").phraseSearch;
				break;
				case "ws":
					auto argsa = cast(string[])args;
					output = argsa.wordSearch(WordSearchType.wholeWords);
				break;
				case "pws":
					// can have word parts (house - can find houses, notice the s)
					auto argsa = cast(string[])args;
					output = argsa.wordSearch(WordSearchType.wordParts);
				break;
				case "chp":
					if (args.length == 1) {
						int index;
						auto argsa = cast(string)args[0];
						try {
							index = argsa.parse!int - 1;
						} catch(Exception e) {
							output = "Invalid number for chapter!";
							break;
						}
						if (index >= 0 && index < g_forChapter.length) {
							output = g_bible.argReference(g_bible.argReferenceToArgs(g_forChapter[index]));
						} else {
							output = "Out of range";
						}
					} else {
						if (args.length == 0)
							output = "Start again, but enter missing chapter number!";
						else
							output = "Wrong number of operants!";
					}
				break;
			} // switch
		}
		if (_doVerse) {
			output = g_bible.argReference(g_bible.argReferenceToArgs(input));
		}

		if (output != "") {
			_editBoxMain.text = _editBoxMain.text ~ text("\n",
				output).to!dstring;
		}
	}
} // main

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
	MainWindow mainWindow;
	mainWindow.setup;

    // run message loop
    return Platform.instance.enterMessageLoop();
}
