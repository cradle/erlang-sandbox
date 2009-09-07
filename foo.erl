-module(foo).
-compile(export_all).

run() ->
  A = B = 2,
  Var = if % if statements return values 
     "true" -> % gives a compile warning
       this_will_never_get_here;
      A == 2, B == 3 -> % A == 2 and B == 2
        nope;
      A == 3; B == 3 -> % A == 2 or B == 2
        nope_again;
      true -> % must have at least one true, or errors!
        ok 
  end,

  Anoth = case Var of
    nope_again -> never_true;
    nope -> still_nope;
    ok -> var_was_ok
  end,
  
  Anoth = var_was_ok.

% loop() ->
%   receive
%     stop ->
%       ok;
%     _ ->
%       io:format("looping"),
%       loop().
%   end