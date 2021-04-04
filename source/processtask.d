import jmisc;

import base, maingui;

struct ProcessTask {
    private:
	string _input;
	bool _done = false;

	bool _clearHelpFirstTime = true;

	string _helpTxt;

    BigBoxes partnerBigBoxes;
    HistoryBox partnerHistoryBox;
	CommandBox partnerCommandBox;
	SearchBox partnerSearchBox;

    public:
    void setup(BigBoxes bigBoxes, HistoryBox historyBox, CommandBox commandBox, SearchBox searchBox) {
        _helpTxt = readText("help.txt");

		import std.path : buildPath;
		//#stuff at the start (in the terminal when the the program is run)
		immutable BIBLE_VER = "asv"; //"kjv"; //"asv";
		loadBible(BIBLE_VER, buildPath("..", "BibleLib", "Versions"));

		addPartners(bigBoxes, historyBox, commandBox, searchBox);
    }

    void addPartners(BigBoxes bigBoxes, HistoryBox historyBox, CommandBox commandBox, SearchBox searchBox) {
        partnerBigBoxes = bigBoxes;
        partnerHistoryBox = historyBox;
		partnerCommandBox = commandBox;
		partnerSearchBox = searchBox;
    }

    void addToHistory(T...)(in T args) {
		immutable status = jm_upDateStatus(args);
		if (partnerHistoryBox !is null) {
			immutable text = partnerHistoryBox.getMyTextViewHistory.getTextBuffer.getText;

			partnerHistoryBox.getMyTextViewHistory().getTextBuffer.setText(text ~ status);
		}
	}

	void processTask(T)(in T oinput) {
		string output;

		import std.stdio;
		import std.conv;

		auto input = oinput.to!string;
		bool doVerse = false;

		if (input.length) {
			immutable base = input.split[0];
			immutable args = input.split[1 .. $];

			switch(base) {
				default: doVerse = true; break;
				case "crossReferences", "cross":
					if (args.length) {
						doAppendQ;
						auto a = args.join(" ");
						string titleAndFooter = a~" -> Cross reference\n";
						string result = titleAndFooter;

						foreach(i, vr; bl_verRefs) {
							if (bl_vers[i] == a)
								result ~= vr ~ "\n";
						}

						result ~= titleAndFooter;
						if (partnerSearchBox.getAppendCheckButton.getActive == false)
							partnerBigBoxes.getMyTextViewRight.getTextBuffer.setText = result;
						else
							partnerBigBoxes.getMyTextViewRight.getTextBuffer.setText = 
								partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText ~ result;
						addToHistory("Do '", a, "' Cross references.");	
					}
				break;
				case "q", "quit", "exit", "disappear", "leave", "close", "hitTheRoad":
					doAppendQ;
					output = "Hold down [control] and tap [Q] to quit";
					addToHistory("Show quit instructions");
				break;
				case "lineSearch":
					if (args.length) {
						doAppendQ;
						auto a = args.join(" ");
						output = jm_searchCollect(a, partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText).join("\n");
						addToHistory("Line Search '", a, "'");
					}
				break;
				case "processTime":
					doAppendQ;
					output = processTime(partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText.split("\n"));
					addToHistory(output);
				break;
				case "marker":
					int len = 10;
					enum error = "Invalid input";

					if (args.length == 0)
						output = error;
					else
						try { len = args[0].to!int; } catch(Exception e) { output = error; }
					if (output != error) {
						addToHistory("Show marker");
						foreach(l; 1 .. len + 1) {
							auto line = "#".replicate(l) ~ "\n";
							l == 0 ? output = line : (output ~= line);
						}
						doAppendQ;
					}
				break;
				case "h", "help":
					doAppendQ;
					output = _helpTxt;
					addToHistory("Display help");
				break;
				case "extractNotes":
					doAppendQ;
					if (args.length == 0) {
						output = "Notes Extraction:\n" ~
							getNotesSortDaysToText(partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText);
						addToHistory("Notes Extraction, with no arguments");
					} else {
						immutable title = args.join(" ");
						output = "Notes Extraction:\n" ~
							getNotesSortFromTitle(title, partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText);
						addToHistory("Notes Extraction: " ~ title);
					}
				break;
				case "expVers":
					if (args.length) {
						doAppendQ;
						if (args[0].exists) {
							auto fileName = "exp_" ~ args[0];
							
							output = g_bible.expVers(args[0], fileName) ~ "\n";
							output ~= "Out put file " ~ fileName;
							addToHistory("expVers file name: ", args[0]);
						} else {
							output = args[0] ~ " - filename does not exist in folder!";
						}
					} else {
						if (partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText != "") {
							output = g_bible.expVers("dummy1", "dummy2",
								partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText);
							addToHistory("expVers from the main right");
						} else {
							output = "Empty right box!";
							addToHistory(output);
						}
					}
				break;
				// extractSubNotes Bible \/ Snare1.pdf \/b
				case "extractSubNotes":
					if (args.length == 0) {
						doAppendQ;
						output = "Sub Notes Extraction, with no arguments";
						addToHistory(output);
						break;
					}
					string title, subTitle;
					try {
						title = args.join(" ")[0 .. args.join(" ").indexOf(` \/`) + 3];
						if (title.length + 3 > args.join(" ").length)
							throw new Exception("Invalid input - " ~ args.join(" "));
						subTitle = args.join(" ")[title.length + 1 .. $];
					} catch(Exception e) {
						writeln(output = e.msg);
						addToHistory(e.msg);
						break;
					}
					doAppendQ;
					output = "Sub notes Extraction:\n" ~ getNotesSortFromTitleAndSubTitle(title, subTitle,
						partnerBigBoxes.getMyTextViewRight.getTextBuffer.getText);
					addToHistory("Sub notes Extraction: " ~ title ~ " " ~ subTitle);
				break;
				case "bible":
					import std.algorithm: any;
					import std.string: toLower, toUpper;
					import std.path : buildPath;

					auto biblesList = "ASV KJV";
					auto bibleVersion = args[0].toUpper;
					if (args.length == 1 && any!(a => a == bibleVersion)(biblesList.split)) {
						doAppendQ;
						loadBible(bibleVersion, buildPath("..", "BibleLib", "Versions"));
						output = text(bibleVersion, " Bible version loaded..");
						addToHistory("Set Bible version to: ", bibleVersion.toUpper);
					} else {
						doAppendQ;
						output = args[0] ~ " - Invalid input, use one of these: " ~ biblesList;
						addToHistory("Invalid Bible version: ", bibleVersion);
					}
				break;
				case "i", "info":
					doAppendQ;
					output = g_info.toString;
					addToHistory("Show info");
				break;
				//#upto with history
				case "everyBook": // `everyBook 1 1` eg. Gen 1 1 .., Exo 1 1 ..
					doAppendQ;
					auto args2 = args.dup;
					try {
						int chp = 1, ver = 1;
						foreach(n; 1 .. 66 + 1) {
							string result;
							
							//#I don't see "n" doing any thing?!
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
						addToHistory("Every book: ", args2.join(":"));
					}
					catch(Exception e) {
						output = "Could not be done!";
						addToHistory("Every book: could not be done!");
					}
				break;
				case "everyChp": // Joh n 1 (John 1 1 (verse), John 2 1 (verse) etc)
					doAppendQ;
					try {
						if (args.length > 2) {
							foreach(n; 1 .. g_bible.getBook(g_bible.bookNumberFromTitle(args[0])).m_chapters.length + 1) {
								string result;

								result = text(args[0], ' ', n.to!string, ' ', args[2 .. $].join(" "));
								output ~= g_bible.argReference(g_bible.argReferenceToArgs(result));
							}
						}
						addToHistory("EveryChp: ", args.join(" "));
					}
					catch(Exception e) {
						output = "Could not be done!";
						addToHistory("EveryChp: ", output);
					}
				break;
				case "books":
					doAppendQ;
					foreach(bn; iota(1, 33 + 1, 1)) {
						string bookName(in int start) {
							return g_bible.getBook(start + bn).m_bookTitle ~ "\t";
						}

						string[] bookNames;
						bookNames ~= bookName(00);
						bookNames ~= bookName(33);

						// eg. 1 ---- Genesis
						string numLineNBookName(int start, in string bookName) {
							import std.array : replicate;

							return (start + bn).to!string ~
								(start + bn < 10 ? " -" : " ") ~ "-".replicate(16 - bookName.length) ~ " " ~ bookName;
						}

						output ~= format("%20s%20s\n",
							numLineNBookName(0, bookNames[0]),
							numLineNBookName(33, bookNames[1]));
					}
					addToHistory("List books");
				break;
				case "wrap":
					doAppendQ;
					if (args.length == 0) {
						g_wrap = (g_wrap ? false : true);
						output = "Text wrap is " ~ (g_wrap ? "on" : "off");
						addToHistory("Wrap: ", output);
					} else {
						if (args.length == 1) {
							g_wrap = true;
							try {
								g_wrapWidth = args[0].to!int;
								output = "Wrap width set";
								addToHistory(output);
							} catch(Exception e) {
								g_wrap = false;
								output = "Error, text wrap has defaulted to off.";
								addToHistory(output);
							}
						}
					}
				break;
				case "btn":
					if (args.length == 1) {
						doAppendQ;
						try {
							output = text("Book: ", args[0], " number: ", g_bible.bookNumberFromTitle(args[0]).to!string);
							addToHistory("Book number: ", args[0]);
						} catch(Exception e) {
							output = "Invalid book name";
							addToHistory("Book number: ", output);
						}
					} else {
						output = "You missed the name of the book!";
						addToHistory("Book number: ", output);	
					}
				break;
				case "ps":
					doAppendQ;
					output = args.join(" ").phraseSearch;
					addToHistory("Phrase search: '", args.join(" "), "'");
				break;
				case "ws":
					doAppendQ;
					auto argsa = cast(string[])args;
					output = argsa.wordSearch(WordSearchType.wholeWords);
					addToHistory("Whole Word search: ", args.join(" "));
				break;
				case "pws":
					doAppendQ;
					// can have word parts (house - can find houses, notice the s)
					auto argsa = cast(string[])args;
					output = argsa.wordSearch(WordSearchType.wordParts);
					addToHistory("Part Word search: ", args.join(" "));
				break;
				case "chp":
					doAppendQ;
					if (args.length == 1) {
						int index;
						auto argsa = cast(string)args[0];
						try {
							index = argsa.parse!int - 1;
						} catch(Exception e) {
							output = "Invalid number for chapter!";
							addToHistory(output);
							break;
						}
						if (index >= 0 && index < g_forChapter.length) {
							output = g_bible.argReference(g_bible.argReferenceToArgs(g_forChapter[index]));
							addToHistory("Chapter from index number: ", index);
						} else {
							output = "Out of range";
							addToHistory("Chapter from index: ", output);
						}
					} else {
						if (args.length == 0) {
							output = "Start again, but enter missing chapter number!";
							addToHistory("Chapter from index: ", output);
						} else {
							output = "Wrong number of operants!";
							addToHistory("Chapter from index: ", output);
						}
					}
				break;
			} // switch
		} // if input.length

		if (doVerse) {
			auto history = input;
			if (input.length > 2) {
				size_t end = input.indexOf("->");
				if (end == -1)
					end = input.length;
				input = input[0 .. end].strip;
			}
			output = g_bible.argReference(g_bible.argReferenceToArgs(input));
			if (output.length)
				doAppendQ;
			addToHistory(history);
		}

		if (output != "") {
			partnerBigBoxes.getMyTextViewLeft.getTextBuffer.setText(
				partnerBigBoxes.getMyTextViewLeft.getTextBuffer.getText ~
				text(partnerBigBoxes.getMyTextViewLeft.getTextBuffer.getText != "" ? "\n" : "",
				output)
			);
		}
	}

	void doAppendQ() {
		if (partnerSearchBox.getAppendCheckButton.getActive == false) {
			partnerBigBoxes.getMyTextViewLeft.getTextBuffer.setText("");
		}
	}
} // struct ProcessTask
