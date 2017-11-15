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
