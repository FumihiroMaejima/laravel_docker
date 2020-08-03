<?php

$rules = [
    '@PSR2'        => true,
    'array_syntax' => ['syntax' => 'short'],
    'braces'       => false,
];
$excludes = ['bootstrap/cache', 'resources/assets', 'resources/views', 'storage', 'node_modules'];

return PhpCsFixer\Config::create()
    ->setRules($rules)
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->in(__DIR__)
            ->exclude($excludes)
            ->notName('README.md')
            ->notName('*.xml')
            ->notName('*.yml')
    );
