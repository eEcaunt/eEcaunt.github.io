#!/usr/bin/env raku

use JSON::Fast;

my $height = ((121/8.5)/7)~"in";
sub print-radical($kanji, $strokes) {
	#dd $kanji, $strokes;
	my $radical = 
	'<div class="radicals" style="height: '~$height~';">';
	$radical ~= '<span class=radical>';
	$radical ~= '<span class=rad-strokes style="margin-bottom:-1em;writing-mode:horizontal-tb;font-size:0.5em;text-align:center;font-family:sans-serif">'~$strokes~'</span>';
	$radical ~= '〘'~$kanji.substr(0,1)~ ('<span class=rad-var>'~$kanji.substr(2,*-1)~'</span>' if $kanji.chars > 1) ~'〙</span>' ~
	'</div>';
	return $radical;
}

sub print-kanji($kanji, $strokes, $last-strokes, @onyomi, @kunyomi, $nanori, @variants, $kokuji, @korean) {
	my $entry =
	'<div class="entry" style="height: '~$height~';">'~
	'<span class="strokes" style="writing-mode:horizontal-tb;text-align:center;margin-bottom:-1.5em;">'~ (+$strokes > +$last-strokes ?? $strokes !! "　" ) ~'</span>' ~
	'<span id='~$kanji~' class=kanji>'~($kokuji ?? '〖' !! '【')~$kanji;
	$entry ~= ($kokuji ?? '〗' !! '】')~'</span>';
	$entry ~= ('<span class=variants>《' ~(for @variants -> $variant {'<a class=variant href="#'~$variant~'">'~$variant~'</a>'}).join("") ~'》</span>' if @variants);
	$entry ~='<span class=reading>' ~
		('<span>'~ @onyomi.join("・") ~ '</span>'~
		(' ('~@korean.join("･")~')' if @korean[0]) ~ '<br />' if @onyomi[0]) ~
		('<span>'~ @kunyomi.join("・") ~ '</span> <br />' if @kunyomi[0]) ~
		('<span>㊔'~ $nanori.join("・") ~ '</span>' if $nanori) ~
	'</span>';
	$entry ~= '</div>';
	return $entry;
}

say '<!DOCTYPE html><html lang="jp"><head>';
#say '<meta http-equiv="refresh" content="3">';
say '<meta charset="utf-8"/><style>
@media print {
    .entry { page-break-before: always; } /* page-break-after works, as well */
}
body{
	//font-family: sans-serif;
	margin:0;
	font-size: 70%;
	//display: flex;
	//flex-direction: row;

}

#content{
	writing-mode: vertical-rl;
	//width: calc(100vw - 20px);
	//width: 8.5in;
	width: 11in;
	display:flex;
	flex-direction: column;
	flex-wrap: wrap;
	justify-content: flex-start;
	align-items: flex-start;
	align-content: flex-start;
	font-size: 100%;
}
.radicals {
	font-size: 3.5em;
	margin-left: 0.5em;
	margin-right: 1em;
} 
.radical {
	margin-top: 0.3em;
	margin-bottom: -2.5em;
}
.rad-var {
	margin-top: 0.3em;
	font-size: 0.5em;
}
.entry {
	font-size: 1em;
	display: grid;
	grid-template-columns: auto;
	grid-template-rows: auto;
	grid-template-areas: 
	"strokes kanji    reading"
	"....... variants reading"
	"....... ........ reading";
	justify-content: start;';

	#// in order for the border to not add extra unwanted vertical space
	#// i have to remove that space
say 'margin-bottom: calc(-0.01em + -1px);
	border-bottom: 1px solid black;
}
.strokes {
	grid-area: strokes;
}
.kanji {
	grid-area: kanji;
	font-size:2em;
//	max-width: 1.5em;
//	text-overflow: clip;
	//display: block;
	margin-bottom:-.4em;
}
.reading {
	grid-area: reading;
}

.variants {';
#//// for flex version that looks right in chrome, but doesnt print correctly…
#//	writing-mode: horizontal-tb;
#//	max-width: 1em;
#//	display: inline-flex;
#//	flex-direction: row-reverse;
#//	flex-wrap: wrap;
#//	justify-content: flex-start;
#//	align-items: flex-start;
#//	align-content: flex-start;
say '	//display: inline-grid;
//	grid-auto-flow: column;
//	grid-column-end: 2;
//	grid-template-rows: auto auto;
//	grid-gap: 0.05em;
//	margin-top: 0.03em;
	grid-area: variants;
	max-height: 5em;
	text-align: end;
}
.variant {
	max-width:1em;
	width:1em;

	color: unset;
	text-decoration: unset;
}
</style>
<style id="borders">
body {
	border: solid 3px black;
}
.radicals {
	border:solid 3px red;
}
.radical {
	border:solid 2px brown;
}
.rad-strokes {
	border:solid 1px green;
}
.rad-var {
	border: 1px solid green;
}
.entry {
	//border:solid 3px blue; 
}
.strokes {
	border:solid 2px green;
}
.kanji {
	border:solid 2px brown;
}
.reading {
	border:solid 2px red;
}
.variants {
	border: solid 2px blue;
}
.variant {
	border: solid 1px red;
}
</style>
<script>document.getElementById("borders").disabled= true ;</script>
</head><body><div id=content>';



#my $file = "kanji-small.json".IO.slurp or die "cant open kanji-sakuin.json";
my $file = "kanji-sakuin.json".IO.slurp or die "cant open kanji-sakuin.json";

my $radicals = from-json($file);

# print out the dictionary
for $radicals.kv -> $i, $rads {
	#dd $rads;
	say print-radical
		$rads{"radical"},
		$rads{"strokes"};
	# sort the characters by stroke count
	my $characters = $rads{"list"}.sort({+$_{"strokes"}});
	for $characters.kv -> $j, $char {
		#say $char;
		state $last-stroke-count="0";
		say print-kanji 
			$char{"kanji"},
			$char{"strokes"},
			$last-stroke-count,
			$char{"onyomi"},
			$char{"kunyomi"},
			$char{"nanori"},
			$char{"variants"},
			$char{"kokuji"},
			$char{"korean"};
		$last-stroke-count = $char{"strokes"};
	}
}

say '</div></body></html>';


#warn "DONE", time;
