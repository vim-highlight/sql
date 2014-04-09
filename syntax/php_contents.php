<?php

$vim_start = '" Vim syntax file for PHP
" Language:     PHP 4 / 5
" Maintainer:   Julien Rosset <jul.rosset@gmail.com>
"
" URL:          https://github.com/darkelfe/vim-php
" Version:      0.0.1
"
" List of constants, functions and classes of PHP\'s extensions
" Generated '.date('m/d/Y').' by '.__FILE__.'.php

';
$vim_end = '';

$groups = array();
$types  = array(
	'Constants',
	'Functions',
	'Classes'
);

foreach($types as $type)
	$groups[$type] = array();

$extensions = get_loaded_extensions(false);
foreach($extensions as $extension)
{
	$reflex = new ReflectionExtension($extension);

	$name = $reflex->getName();
	$vim_end .= "\n".'" '.$name."\n";

	foreach($types as $type)
	{
		$elements = call_user_func(array($reflex, 'get'.$type));

		if(count($elements) == 0)
			continue;

		$group = 'phpExtension'.$type.'_'.$name;
		$groups[$type][] = $group;

		$vim_end .= 'syntax keyword '.$group.' contained '.implode(' ', array_keys($elements))."\n".'highlight link '.$group.' phpExtension'.$type."\n\n";
	}

	unset($reflex);
}

$vim_middle = '';
foreach($types as $type)
	$vim_middle .= 'syntax cluster phpClExtension'.$type.' contains='.implode(',', $groups[$type])."\n";

print $vim_start.$vim_middle.$vim_end;

?>
