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

use_ok('Hypernova::Dimensions::Controller::Accounts');

subtest 'list() tests' => sub {
    plan tests => 5;

    $schema->txn_begin;

    foreach my $id (1..5) {
        $schema->resultset('Account')->create({
            code => int(rand(1000)*1000),
            name => 'test account ' . int(rand(1000)*1000),
        });
    }

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/accounts'), {
            auth => {
                permissions => { 'accounts' => ['read'] }
            }
        }
    );

    $t->request_ok($tx)->status_is(200)
      ->json_has('/records/0/id')
      ->json_has('/records/1/name')
      ->json_hasnt('/records/6');

    $schema->txn_rollback;
};

subtest 'get() tests' => sub {
    plan tests => 8;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/accounts/-1'), {
            auth => {
                permissions => { 'accounts' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/accounts/' . $account->id), {
            auth => {
                permissions => { 'accounts' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(200)
      ->json_is('/id', $account->id)
      ->json_is('/name', $account->name)
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'add() tests' => sub {
    plan tests => 5;

    $schema->txn_begin;

    my $account = {
        code => 1000,
        name => 'test account',
    };

    my $tx = $test->tx(
        $t->ua->build_tx(POST => '/api/accounts' => json => $account), {
            auth => {
                permissions => { 'accounts' => ['create'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(201)
      ->json_has('/id')
      ->json_is('/name', $account->{name})
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 8;

    $schema->txn_begin;

    my $admin;
    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });
    $account = { $schema->resultset('Account')->find($account->id)->get_columns };

    $account->{name} = 'test account name edited';

    my $account_id = delete $account->{id};

    my $tx = $test->tx(
        $t->ua->build_tx(PUT => '/api/accounts/-1' => json => $account), {
            auth => {
                permissions => { 'accounts' => ['update'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(PUT => "/api/accounts/$account_id" => json => $account), {
            auth => {
                permissions => { 'accounts' => ['update'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(200)
      ->json_is('/id', $account_id)
      ->json_is('/name', $account->{name})
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 6;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });

    $account = { $schema->resultset('Account')->find($account->id)->get_columns };

    my $tx = $test->tx(
        $t->ua->build_tx(DELETE => '/api/accounts/-1'), {
            auth => {
                permissions => { 'accounts' => ['delete'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(DELETE => '/api/accounts/' . $account->{id}), {
            auth => {
                permissions => { 'accounts' => ['delete'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(204)
      ->content_is('', 'Empty response body');

    $schema->txn_rollback;
};

done_testing();
