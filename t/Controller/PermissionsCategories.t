#!/usr/bin/perl

use strict;
use warnings;

use Test::Mojo;
use Test::More;

use t::lib::TestHelper;

my $t = Test::Mojo->new('Hypernova::Dimensions');
my $schema = $t->app->schema;

my $test = t::lib::TestHelper->new({
    schema => $schema,
    t => $t,
});

use_ok('Hypernova::Dimensions::Controller::PermissionsCategories');

subtest 'list() tests' => sub {
    plan skip_all => 'todo';
};

subtest 'get() tests' => sub {
    plan skip_all => 'todo';
};

subtest 'add() tests' => sub {
    plan skip_all => 'todo';
};

subtest 'edit() tests' => sub {
    plan skip_all => 'todo';
};

subtest 'delete() tests' => sub {
    plan skip_all => 'todo';
};

done_testing();
