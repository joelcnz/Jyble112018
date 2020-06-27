//#Add on change skip to the bottom
//#repeat append function (DRY failure)
import base;

class MyHeaderBar : HeaderBar {
	bool decorationsOn = true;
	string title = "Jyble";
	string subtitle = "Poorly Programmed Productions";

	this() {
		super();
		setShowCloseButton(decorationsOn); // turns on all buttons: close, max, min
		version(Windows)
			setDecorationLayout("close:minimize,maximize,icon"); // no spaces between button IDs
		version(OSX)
			setDecorationLayout("close:maximize,icon");
		setTitle(title);
		setSubtitle(subtitle);
	}

} // class MyHeaderBar

/// main box
final class AppBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	BigBoxes bigBoxes;
	HistoryLabelBox historyLabelBox;
	HistoryBox historyBox;
	CommandBox commandBox;
	SearchBox searchBox;
	ExtractTitleBox extractTitleBox;
	ExtractTitleAndSubTitleBox extractSubTitleBox;

	MyTextView partnerHistoryMyTextView;
	Entry partnerCommandBoxEntry;
	Entry partnerSearchBoxEntry;

	public:
	/// this AppBox
	this() {
		super(Orientation.VERTICAL, globalPadding);
		
        g_ProcessTask = ProcessTask();

		bigBoxes = new BigBoxes();
		historyLabelBox = new HistoryLabelBox();
		historyBox = new HistoryBox();
		commandBox = new CommandBox();
		searchBox = new SearchBox(bigBoxes);
		extractTitleBox = new ExtractTitleBox();
		extractSubTitleBox = new ExtractTitleAndSubTitleBox();
		
		packStart(bigBoxes, expand, fill, localPadding);
		packStart(historyLabelBox, expand, fill, localPadding);
		packStart(historyBox, expand, fill, localPadding);
		packStart(commandBox, expand, fill, localPadding);
		packStart(searchBox, expand, fill, localPadding);
		packStart(extractTitleBox, expand, fill, localPadding);
		packStart(extractSubTitleBox, expand, fill, localPadding);

		g_ProcessTask.setup(bigBoxes, historyBox, commandBox, searchBox);
		
		addOnKeyPress(&keySelectFocusCallBack);

		addPartners(historyBox.scrolledTextWindowHistory.myTextView,
			commandBox.commandEntry,
			searchBox.getSearchEntry);
	} // this()

	/// 
	void addPartners(MyTextView partnerHistoryMyTextView,
						Entry partnerCommandBoxEntry,
						Entry partnerSearchBoxEntry) {
		this.partnerHistoryMyTextView = partnerHistoryMyTextView;
		this.partnerCommandBoxEntry = partnerCommandBoxEntry;
		this.partnerSearchBoxEntry = partnerSearchBoxEntry;
	}

	deprecated auto getShortHistoryMyTextView() {
		return partnerHistoryMyTextView;
	}

	deprecated auto getShortBigBoxesBoxCommandBoxEntry() {
		return partnerCommandBoxEntry;
	}

	deprecated auto getShortSearchBoxEntry() {
		return partnerSearchBoxEntry;
	}

	/// Read keys for choosing focus
	bool keySelectFocusCallBack(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK) {
			if (ev.key.keyval == GdkKeysyms.GDK_d) {
			
				g_RigWindow.setFocus(commandBox.getCommandEntry);
			
				return true;
			}
			
			if (ev.key.keyval == GdkKeysyms.GDK_s) {
			
				g_RigWindow.setFocus(searchBox.getSearchEntry);
				
				return true;
			}
		}

		return false;
	}

	auto getBigBoxes() {
		return bigBoxes;
	}

	deprecated auto getCommandEntry() {
		return commandBox.commandEntry;
	}

	auto getSearchBox() {
		return searchBox;
	}

	auto getExtractTitleEntry() {
		return extractTitleBox.getExtractTitleEntry;
	}

	auto getExtractSubTitleEntry() {
		return extractSubTitleBox.getExtractSubTitleEntry;
	}
} // class AppBox

/// The two big boxes at the top
class BigBoxes : HorizontalBox
{
	private:
	ScrolledTextWindow scrolledTextWindowLeft, scrolledTextWindowRight;

	string content2 = "Left/main text box", content3 = "right/secondary text box";
	
	public:
	/// 
	this()
	{
		scrolledTextWindowLeft = new ScrolledTextWindow();
		scrolledTextWindowRight = new ScrolledTextWindow();

		immutable height = 460;
		scrolledTextWindowLeft.setMinContentHeight(height);
		scrolledTextWindowRight.setMinContentHeight(height);

		import std.file : readText;
		content2 = readText("leftwindow.txt");
		content3 = readText("rightwindow.txt");
		if (content2.length) getMyTextViewLeft.getTextBuffer.setText = content2;
		if (content3.length) getMyTextViewRight.getTextBuffer.setText = content3;

		packStart(scrolledTextWindowLeft, expand, fill, localPadding);
		packStart(scrolledTextWindowRight, expand, fill, localPadding);
	} // this()

	/// 
	auto getMyTextViewLeft() {
		return scrolledTextWindowLeft.myTextView;
	}

	/// 
	auto getMyTextViewRight() {
		return scrolledTextWindowRight.myTextView;
	}
} // class Bigboxes

/// History
class HistoryLabelBox : HorizontalBox {
	private:
	Label historyLabel;

	public:
	/// 
	this() {
		historyLabel = new Label("History:");

		expand = fill = false;
		packStart(historyLabel, expand, fill, localPadding);
	}
}

/// 
class HistoryBox : VerticalBox
{
	private:
	ScrolledTextWindow scrolledTextWindowHistory;

	/// 
	public:
	/// constructor
	this()
	{
		immutable welcome = dateTimeString ~ " Welcome to Jyble\n";
		scrolledTextWindowHistory = new ScrolledTextWindow();
		g_ProcessTask.addToHistory(welcome[dateTimeString.length .. $]);

		scrolledTextWindowHistory.setMinContentHeight(100);
		//#Add on change skip to the bottom

		getMyTextViewHistory.getTextBuffer.setText = welcome;

		expand = fill = false;
		packStart(scrolledTextWindowHistory, expand, fill, localPadding);
	} // this()
	
    deprecated auto getMyTextViewHistory() {
		return scrolledTextWindowHistory.myTextView;
    }
} // class HistoryBox

/// 
class CommandBox : HorizontalBox
{
	private:
	string commandLabelText = "Enter Command:";
	Label commandLabel;
	Entry commandEntry;
	Button expandVersesButton;
	string expandVersesText = "Expand Verses";
	Button processTime;
	string processTimeText = "Pro Tim";
	
	/// 
	public:
	/// 
	this()
	{
		commandLabel = new Label(commandLabelText);
		commandEntry = new Entry();
		expandVersesButton = new Button(expandVersesText, &expandVersesClick);
		processTime = new Button(processTimeText, &processTimeClick);

		commandEntry.setSizeRequest(200, -1);

		commandEntry.setPlaceholderText("(Control + D)");
		commandEntry.addOnActivate(&doAddOnActivate);

		expand = fill = false;
		packStart(commandLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(commandEntry, expand, fill, localPadding);
		expand = fill = false;
		packStart(expandVersesButton, expand, fill, localPadding);
		packStart(processTime, expand, fill, localPadding);
	} // this()

	auto getCommandEntry() {
		return commandEntry;
	}

	void doAddOnActivate(Entry a) {
		g_ProcessTask.processTask(commandEntry.getText);
		commandEntry.setText("");
	}

	void expandVersesClick(Button b) {
		g_ProcessTask.processTask("expVers");
	}

	void processTimeClick(Button b) {
		g_ProcessTask.processTask("processTime");
	}
} // class CommandBox

final class SearchBox : HorizontalBox {
	private:
	string clearLeftButtonText = "Clear Left";
	Button clearLeftButton;
	string searchLabelText = "Search:";
	Label searchLabel;
	string searchEntryPlaceHolderText = "(Control + S)";
	Entry searchEntry;
	SearchRadioBox searchRadioBox;
	string caseText = "case";
	CheckButton caseCheckButton;
	string appendText = "Append";
	CheckButton appendCheckButton;
	
	BigBoxes partnerBigBoxes;

	public:
	this(BigBoxes bigBoxes) {
		addPartner(bigBoxes);

		clearLeftButton = new Button(clearLeftButtonText, &clearLeftClick);
		searchLabel = new Label(searchLabelText);
		searchEntry = new Entry();
		searchRadioBox = new SearchRadioBox();
		caseCheckButton = new CheckButton(caseText);
		appendCheckButton = new CheckButton(appendText);

        searchEntry.setPlaceholderText(searchEntryPlaceHolderText);
		searchEntry.addOnActivate(&doAddOnActivate);

		expand = fill = false;
		packStart(clearLeftButton, expand, fill, localPadding);
		packStart(searchLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(searchEntry, expand, fill, localPadding);
		expand = fill = false;
		packStart(searchRadioBox, expand, fill, localPadding);
		packStart(caseCheckButton, expand, fill, localPadding);
		packStart(appendCheckButton, expand, fill, localPadding);
	}

	void addPartner(BigBoxes bigBoxes) {
		partnerBigBoxes = bigBoxes;
	}

	/// 
	auto getSearchEntry() {
		return searchEntry;
	}

	auto getSearchRadioBox() {
		return searchRadioBox;
	}

	auto getCaseCheckButton() {
		return caseCheckButton;
	}

	auto getAppendCheckButton() {
		return appendCheckButton;
	}

	void clearLeftClick(Button b) {
		partnerBigBoxes.getMyTextViewLeft.getTextBuffer.setText("");
		resetVerseTags;
	}

	 void doAddOnActivate(Entry e) {
		doAppendQ;
		immutable caseSensitive = caseCheckButton.getActive ? "%caseSensitive " : "";
		immutable search = searchEntry.getText;

		g_ProcessTask.processTask(searchRadioBox.getObserved.getState ~ " " ~ caseSensitive ~ search);
	 }

	//#repeat append function (DRY failure)
	/// 
	void doAppendQ() {
		if (appendCheckButton.getActive == false) {
			partnerBigBoxes.getMyTextViewLeft.getTextBuffer.setText("");
		}
	}
} // class SearchBox

///
final class SearchRadioBox : Box
{
	int padding = 0;
	Observed observed = new Observed(null);
	RadioButton button1, button2, button3;
	
	this()
	{
		super(Orientation.HORIZONTAL, padding);
		
		button1 = new MyRadioButton("ws", observed);
		
		button2 = new MyRadioButton("pws", observed);
		button2.setGroup(button1.getGroup);                        // ** NOTE **
		
		button3 = new MyRadioButton("ps", observed);
		button3.setGroup(button1.getGroup);
		
		add(button1);
		add(button2);
		add(button3);
	} // this()

	auto getActivateButtonByNumber() {
		return button1.getActive() ? 1 : button2.getActive() ? 2 : button2.getActive() ? 2 : 3;
	}

	void setActivateButtonByNumber(int id) {
		if (id > 0 && id < 4)
			setActiveButton([button1, button2, button3][id - 1]);
		else
			"Error: invalid button set".gh;
	}
	
	auto getObserved() {
		return observed;
	}
	
	void setActiveButton(RadioButton rb)
	{
		// set which button is active on start-up
		observed.setState(rb.getLabel);      	// initial state
		rb.setActive(true);							// set AFTER all buttons are instantiated
	} // setActiveButton()
	
} // class Radiobox

// The first RadioButton created will have its mode set automatically?
class MyRadioButton : RadioButton
{
	Observed observed;
	
	this(string labelText, Observed extObserved)
	{
		super(labelText);
		addOnToggled(&onToggle); // this signal derives from Toggle
		
		observed = extObserved;
		
	} // this()
	

	void onToggle(ToggleButton b)  // because Radio derives from Toggle, we can (and must) do this.
	{
		observed.setState(getLabel);
		
	} // onToggle()

} // class MyRadioButton

class Observed
{
	private:
	string observedState;
	
	this(string extState)
	{
		setState(extState);
		
	} // this()

	
	public:
	
	void setState(string extState)
	{
		observedState = extState;

	} // setState()


	string getState()
	{
		return observedState;
		
	} // getState()

} // class Observed

class ExtractTitleBox : HorizontalBox {
	private:
	string extractTitleText = "Extract with title:";
	Label extractTitleLabel;
	string extractTitleEntryPlaceHolderText = `(eg. 'Other \/')`;
	Entry extractTitleEntry;

	/// 
	public:
	/// 
	this() {
		extractTitleLabel = new Label(extractTitleText);
		extractTitleEntry = new Entry();

		extractTitleEntry.setSizeRequest(600, -1);
        extractTitleEntry.setPlaceholderText(extractTitleEntryPlaceHolderText);
		extractTitleEntry.addOnActivate(&doAddOnActivate);

		expand = fill = false;
		packStart(extractTitleLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(extractTitleEntry, expand, fill, localPadding);
	}

	void doAddOnActivate(Entry a) {
		g_ProcessTask.processTask("extractNotes " ~ extractTitleEntry.getText);
	}

	auto getExtractTitleEntry() {
		return extractTitleEntry;
	}
} // class ExtractTitleBox

class ExtractTitleAndSubTitleBox : HorizontalBox {
	private:
	string extractTitleText = "Extract with title and sub title:";
	Label extractTitleAndSubtitleLabel;
	string extractTitleEntryPlaceHolderText = `(eg. 'Bible \/ Other \/b')`;
	Entry extractTitleAndSubEntry;

	public:
	this() {
		extractTitleAndSubtitleLabel = new Label(extractTitleText);
		extractTitleAndSubEntry = new Entry();

        extractTitleAndSubEntry.setPlaceholderText(extractTitleEntryPlaceHolderText);
		extractTitleAndSubEntry.addOnActivate(&doAddOnActivate);

		expand = fill = false;
		packStart(extractTitleAndSubtitleLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(extractTitleAndSubEntry, expand, fill, localPadding);
	}

	void doAddOnActivate(Entry a) {
		g_ProcessTask.processTask("extractSubNotes " ~ extractTitleAndSubEntry.getText);
	}

	auto getExtractSubTitleEntry() {
		return extractTitleAndSubEntry;
	}
}

class VerticalBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	public:
	this()
	{
		super(Orientation.VERTICAL, globalPadding);
		
	} // this()
	
} // class VerticalBox

class HorizontalBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	public:
	this()
	{
		super(Orientation.HORIZONTAL, globalPadding);
		
	} // this()
	
} // class HorizontalBox

class ScrolledTextWindow : ScrolledWindow {
	MyTextView myTextView;
	
	this()
	{
		super();
		
		myTextView = new MyTextView("(beyoom!)");
		add(myTextView);
		
	} // this()

	auto getMyTextView() {
		return myTextView;
	}
}

class MyTextView : TextView
{
	private:
	TextBuffer textBuffer;
	string _content;
	
	public:
	this(string content)
	{
		super();
		textBuffer = getBuffer();
		_content = content;
		setWrapMode(GtkWrapMode.WORD);
		textBuffer.setText(_content);
	}

	auto getTextBuffer() {
		return textBuffer;
	}
} // class MyTextView
