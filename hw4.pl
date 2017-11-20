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

% Morse code table.
morse(a, [.,-]).			% A
morse(b, [-,.,.,.]).		% B
morse(c, [-,.,-,.]).		% C
morse(d, [-,.,.]).			% D
morse(e, [.]).				% E
morse('e''', [.,.,-,.,.]).	% É (accented E)
morse(f, [.,.,-,.]).		% F
morse(g, [-,-,.]).			% G
morse(h, [.,.,.,.]).		% H
morse(i, [.,.]).			% I
morse(j, [.,-,-,-]).		% J
morse(k, [-,.,-]).			% K or invitation to connect
morse(l, [.,-,.,.]).		% L
morse(m, [-,-]).			% M
morse(n, [-,.]).			% N
morse(o, [-,-,-]).			% O
morse(p, [.,-,-,.]).		% P
morse(q, [-,-,.,-]).		% Q
morse(r, [.,-,.]).			% R
morse(s, [.,.,.]).			% S
morse(t, [-]).				% T
morse(u, [.,.,-]).			% U
morse(v, [.,.,.,-]).		% V
morse(w, [.,-,-]).			% W
morse(x, [-,.,.,-]).		% X or multiplication sign
morse(y, [-,.,-,-]).		% Y
morse(z, [-,-,.,.]).		% Z
morse(0, [-,-,-,-,-]).		% 0
morse(1, [.,-,-,-,-]).		% 1
morse(2, [.,.,-,-,-]).		% 2
morse(3, [.,.,.,-,-]).		% 3
morse(4, [.,.,.,.,-]).		% 4
morse(5, [.,.,.,.,.]).		% 5
morse(6, [-,.,.,.,.]).		% 6
morse(7, [-,-,.,.,.]).		% 7
morse(8, [-,-,-,.,.]).		% 8
morse(9, [-,-,-,-,.]).		% 9
morse(., [.,-,.,-,.,-]).	% . (period)
morse(',', [-,-,.,.,-,-]).	% , (comma)
morse(:, [-,-,-,.,.,.]).	% : (colon or division sign)
morse(?, [.,.,-,-,.,.]).	% ? (question mark)
morse('''',[.,-,-,-,-,.]).	% ' (apostrophe)
morse(-, [-,.,.,.,.,-]).	% - (hypen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).		% / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).	% ( left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]).	% ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]).	% " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).		% = (double hyphen)
morse(+, [.,-,.,-,.]).		% + (cross or addition sign) 
morse(@, [.,-,-,.,-,.]).	% @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).		% AS (wait A Second)
morse(ct, [-,.,-,.,-]).		% CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).	% SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).		% SN (understood, Sho' 'Nuff)

% Convert signal to message
morse_message([], []). % Empty morse
morse_message(Morse, [Letter]):- morse(Letter, Morse). % Singleton
morse_message(Morse, Word):- % Convert morse code to character
	append(MorseLetter_Head, [^|MorseLetter_Tail], Morse),
	morse_message(MorseLetter_Head, Letter),
	morse_message(MorseLetter_Tail, Letters),
	append(Letter, Letters, Word).
morse_message(Morse, Message):- % Convert morse code to message
	append(MorseWord_Head, [#|MorseWord_Tail], Morse),
	morse_message(MorseWord_Head, Word),
	morse_message(MorseWord_Tail, Words),
	append(Word, [#|Words], Message).

% Correct errors in message
correct_message([], Proper):- % Empty message
	Proper = [].
correct_message(Improper, Proper):- % Starting with error
	append([error|_], ImproperTail, Improper),
	correct_message(ImproperTail, ProperTail),
	append([error|_], ProperTail, Proper).
correct_message(Improper, Proper):- % Starting with #, error
	append([#,error], ImproperTail, Improper),
	correct_message(ImproperTail, ProperTail),
	append([#,error], ProperTail, Proper).
correct_message(Improper, Proper):- % Starting with # and contains error
	Improper = [#|_],
	member(error, Improper),
	append(Head, [_, error|ImproperTail], Improper),
	append(ProperHead, [#|_], Head),
	correct_message(ImproperTail, ProperTail),
	append(ProperHead, [#|ProperTail], Proper).
correct_message(Improper, Proper):- % Starting with # and does not contain error
	append([#], ImproperTail, Improper),
	correct_message(ImproperTail, ProperTail),
	append([#], ProperTail, Proper).
correct_message(Improper, Proper):- % Iterate
	append(ProperHead, ImproperTail, Improper),
	(ImproperTail = [#|_]; ImproperTail = [error|_]),
	correct_message(ImproperTail, ProperTail),
	append(ProperHead, ProperTail, Proper).
correct_message(Improper, Proper):- % Message containing only characters
	Proper = Improper.

% Convert signals to morse code then to message
signal_message(Signal, Message):-
	signal_morse(Signal, Morse),
	morse_message(Morse, Interpretation),
	correct_message(Interpretation, Message).

