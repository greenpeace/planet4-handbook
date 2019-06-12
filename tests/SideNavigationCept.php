<?php
$I = new AcceptanceTester($scenario);
$I->wantTo('Check nav sidebar is there and it has the correct color');

$I->amOnPage('/');

// we see the navigation sidebar
$I->seeElement( 'nav#sidebar');

//check its color
$sidebarBackgroundColor = $I->getCSSValue('nav#sidebar', 'background-color');

$I->assertEquals('rgba(1, 34, 61, 1)', $sidebarBackgroundColor);
