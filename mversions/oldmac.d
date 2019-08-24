		// Crease widget to show in window
		_window.mainWidget = parseML(q{
			VerticalLayout {
				backgroundColor: "#80FF80"
				margins: 3
				padding: 3

				HorizontalLayout {
					EditBox {
						id: editBoxMain
						minWidth: 390; minHeight: 540; maxHeight: 540;
					}
					EditBox {
						id: editBoxRight
						minWidth: 390; minHeight: 540; maxHeight: 540;
					}
				}

				TextWidget {
					text: "History:"
				}
				EditBox {
					id: editBoxHistory
					minWidth: 780; minHeight: 100; maxHeight: 100;
				}

				HorizontalLayout {
					TextWidget {
						text: "Enter command:"
					}
					EditLine {
						id: editLineInWindowSpot
						minWidth: 350
					}
					Button {
						id: buttonActivate
						text: "Activate"
					}
					Button { id: buttonWrap; text: "Wrap Text" }
					Button {
						id: buttonExpVers
						text: "Expand Verses"
					}
				}
				
				HorizontalLayout {
					Button { id: buttonClearLeft; text: "Clear left" }
					TextWidget {
						text: "Search:"
					}
					EditLine {
						id: editLineSearch
						minWidth: 190
					}
					TextWidget { text: "pws-" }
					CheckBox { id: checkBoxPartWordSearch; }
					TextWidget { text: "ws-" }
					CheckBox { id: checkBoxWordSearch; }
					TextWidget { text: "ps-" }
					CheckBox { id: checkBoxPhraseSearch; }
					TextWidget {
						text: "case-"
					}					
					CheckBox { id: checkBoxSearchCaseSensitive; }
					Button {
						id: buttonActivateSearch
						text: "Activate Search"
					}
				}
			}
		});
