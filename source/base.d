public:

import std.stdio;
import std.string;
import std.array: split, replace;
import std.file;
import std.conv;
import std.process;
import std.range;
import std.datetime;

import gtk.Main;
import gtk.MainWindow;
import gtk.Grid;
import gtk.ComboBoxText;
import gtk.Box;
import gtk.Entry;
import gtk.Label;
import gtk.Button;
import gtk.CheckButton;
import gtk.TextTagTable;
import gtk.TextBuffer;
import gtk.TextView;
import gtk.Clipboard;
import gtk.Adjustment;
import gtk.ScrolledWindow;
import gtk.ViewPort;
import gtk.TextIter; // probably idle
import gtk.TextMark; // idle
import gtk.AccelGroup;
import gtk.MenuItem;
import gtk.Window;
import gtk.Widget;
import gtk.RadioButton;
import gtk.ToggleButton; // so we can use the toggle signal
import gtk.HeaderBar;

import gdk.Event;
import gdk.Keysyms;

import arsd.dom: Document, Element;

import bible, jmisc;

import processtask, maingui;

RigWindow g_RigWindow;
ProcessTask g_ProcessTask;

class RigWindow : MainWindow
{
	private:
	string title = "Poorly Programmed Productions presents: Jyble";
	AppBox appBox;
	
	public:
	this()
	{
		super(title);
		addOnDestroy(&quitApp);
		
		appBox = new AppBox();
		add(appBox);
		
		addOnKeyPress(&controlQCallBack);

		setFocus(appBox.getShortBigBoxesBoxCommandBoxEntry);

		resetVerseTags;

		setTitlebar(new MyHeaderBar());

		immutable iconFile = "../Res/ballicon.png";
		setIconFromFile(iconFile);

		move(0, 30);

		showAll();
	} // this()

	auto getAppBox() {
		return appBox;
	}
	
	private:
	bool controlQCallBack(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK &&
			ev.key.keyval == GdkKeysyms.GDK_q) {
			
			quitApp(w);

			return true;
		}
		
		return false;
	}

	void quitApp(Widget widget)
	{
		File("leftwindow.txt", "w").write(appBox.getBigBoxes.getMyTextViewLeft.getTextBuffer.getText);
		File("rightwindow.txt", "w").write(appBox.getBigBoxes.getMyTextViewRight.getTextBuffer.getText);
		File("filtersetc.txt", "w").writeln(//#'writeln' seems to be the same as just 'write' (thought it seems to work better with it)
			appBox.getShortBigBoxesBoxCommandBoxEntry.getText ~ "\n" ~
			appBox.getShortSearchBoxEntry.getText ~ "\n" ~
			appBox.getExtractTitleEntry.getText ~ "\n" ~
			appBox.getExtractSubTitleEntry.getText ~ "\n",
			appBox.getSearchBox.getSearchRadioBox.getActivateButtonByNumber, "\n",
			(appBox.getSearchBox.getCaseCheckButton.getActive ? 1 : 0), "\n",
			(appBox.getSearchBox.getAppendCheckButton.getActive ? 1 : 0));

		string exitMessage = "Bye.";
		
		writeln(exitMessage);
		
		Main.quit();
		
	} // quitApp()

} // class TestRigWindow
