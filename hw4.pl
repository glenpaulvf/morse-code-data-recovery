% Dih symbol. .
signal([1], .).
signal([1,1], .). % error, noise correction

% Dah symbol. -
signal([1,1,1], -).
signal([1,1], -). % error, noise correction
signal([1,1,1,1|More], Signal):- \+(member(0, More)), signal([1,1,1], Signal). % error

% Symbol delimiter.
signal([0], 0).
signal([0,0], 0). % error, noise correction

% Letter delimiter. ^
signal([0,0,0], ^).
signal([0,0], ^). % error, noise correction
signal([0,0,0,0], ^). % error, noise correction
signal([0,0,0,0,0], ^). % error, noise correction

% Word delimiter. #
signal([0,0,0,0,0,0,0], #).
signal([0,0,0,0,0], $). % error, noise correction
signal([0,0,0,0,0|More], Signal):- \+(member(1, More)), signal([0,0,0,0,0,0,0], Signal). % error

% Delimiters.
delimiter([], Signal) :- signal(Signal, 0).
delimiter([^], Signal) :- signal(Signal, ^).
delimiter([#], Signal) :- signal(Signal, #).

% Convert signals to morse code.
signal_morse([], []). % Empty signal
signal_morse(S, [M]):- signal(S, M). % Singleton
signal_morse(S, [M]):- % Convert symbol (dih/dah)
	append(Symbol, Symbol_Delimiter, S),
	signal(Symbol_Delimiter, 0),
	signal(Symbol, M).
signal_morse(S, [M]):- % Convert letter
	append(Letter, Letter_Delimiter, S),
	signal(Letter_Delimiter, ^),
	signal(Letter, M).
signal_morse(S, [M]):- % Convert word
	append(Word, Word_Delimiter, S),
	signal(Word_Delimiter, #),
	signal(Word, M).
signal_morse(S, M):-
	% Get prefixes and suffixes
	append(S_Head, S_Tail, S),
	% Get first signal but not a symbol delimiter
	signal(S_Head, Code), \+signal([0], Code),
	% Get signal based on delimiter, default is symbol delimiter
	delimiter(Delimiter, Signal),
	% Get next symbol (starts with 1) and not delimiter (starts with 0)
	% If fail, then continue to process current signal
	append(Signal, [Signal_Head|Signal_Tail], S_Tail), Signal_Head = 1,
	% Append morse code with delimiter
	append([Code], Delimiter, Morse_Head),
	% Convert the rest of the signal
	signal_morse([Signal_Head|Signal_Tail], Morse_Tail),
	% Append code together
	append(Morse_Head, Morse_Tail, M).
