#! /usr/bin/perl

$indent = "  ";           # used to indent within aggregates
$indent_length = length ($indent);

$separator = " ";         # used to separate tokens on same line
$separator_length = length ($separator);

$depth = 0;               # current "aggregate depth"
$depth_indent = "";       # corresponding indent
$depth_indent_length = 0; # length of $depth_indent

$bDepthRising = 0;        # whether the last change in depth was...
                          # ...an increase

$bStartingLine = 1;       # whether we're starting a new line
$bStartingAggregate = 0;  # whether we're starting to format...
                          # ...elements of an aggregate

$targetMaxLL = 73;        # target maximum line length (modulo...
                          # ...$minAfterIndent)
$minAfterIndent = 25;     # minimum number of characters in line...
                          # ...after indent
$currentLL = 0;           # current line length


while (<>) {
    # Look for whitespace-separated JSON elements.  The approach is
    # to first try to match JSON elements that can contain embedded
    # whitespace (strings, and the space character space (' ')), and
    # then match any non-whitespace.  In this expression, we use \042
    # for '"' and \047 for ''' to help keep emacs font-lock-mode
    # happy.

    while (/(\042[^\042]+\042:|,|\042([^\042]|\\\042])*\042|\d+|{|}|:)/g) {
        $token = $1;
        
        if ($token eq "{") {
            # if we aren't already starting a line, start one now
            if (! $bStartingLine) {
                print "\n";
            }
	    
	    print $depth_indent, "{ ";

	    $currentLL = $depth_indent_length + 1;

	    # set new depth
	    ++$depth;
	    $depth_indent = $indent x $depth;
	    $depth_indent_length = $indent_length * $depth;

	    $bDepthRising = 1;
	    $bStartingLine = 0;
	    $bStartingAggregate = 1;
	}
	elsif ($token eq "}")
	{
	    # if the depth is rising, we put the closing brace on the
	    # current line
	    if ($bDepthRising)
	    {
		print " }";
	    }

	    # if we aren't already starting a line, start one now
	    if (! $bStartingLine)
	    {
		print "\n";
	    }

	    # set new depth
	    --$depth;
	    $depth_indent = $indent x $depth;
	    $depth_indent_length = $indent_length * $depth;

	    if (! $bDepthRising)
	    {
		print $depth_indent, "}\n";
	    }

	    $currentLL = $depth_indent_length + 1;

	    $bDepthRising = 0;
	    $bStartingLine = 1;
	    $bStartingAggregate = 0;
	}
	else
	{
	    $token_length = length ($token);

	    if ($bStartingLine)
	    {
		# starting a new line -- print indent and initialize
		# line length for new line
		print $depth_indent;
		$currentLL = $depth_indent_length + $token_length;

		$bStartingLine = 0;	# no longer starting a new line
	    }
	    else
	    {
		# determine updated line length 
		$currentLL += $token_length + $separator_length;

		if ($currentLL > $targetMaxLL
		    && ! $bStartingAggregate
		    && ! ($currentLL < $depth_indent_length + $minAfterIndent))
		{
		    # wrap to new line and initialize line length for new
		    # line
		    print "\n", $depth_indent;
		    $currentLL = $depth_indent_length + $token_length;
		}
		else
		{
		    # continuing on current line -- print token separator
#		    print $separator;
		}

		$bStartingAggregate = 0;
	    }

	    print $token;	    # print the dang token
	}
    }
}
