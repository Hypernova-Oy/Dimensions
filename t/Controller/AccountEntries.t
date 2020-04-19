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

use_ok('Hypernova::Dimensions::Controller::AccountEntries');

subtest 'list() tests' => sub {
    plan tests => 9;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });

    foreach my $id (1..5) {
        $schema->resultset('AccountEntry')->create({
            account_id => $account->id,
            amount => sprintf('%.2f', rand(1000) * 1000),
            description => 'test entry description',
        });
    }

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/account/entries'), {
            auth => {
                permissions => { 'account_entries' => ['read'] }
            }
        }
    );

    $t->request_ok($tx)->status_is(200)
      ->json_is('/records/0/account_id', $account->id)
      ->json_has('/records/0/amount')
      ->json_has('/records/0/description')
      ->json_has('/records/0/created_at')
      ->json_has('/records/0/modified_at')
      ->json_has('/records/4/account_id')
      ->json_hasnt('/records/6');

    $schema->txn_rollback;
};

subtest 'get() tests' => sub {
    plan tests => 11;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });

    my $account_entry = $schema->resultset('AccountEntry')->create({
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry description',
    });

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/account/entries/-1'), {
            auth => {
                permissions => { 'account_entries' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/account/entries/' . $account_entry->id), {
            auth => {
                permissions => { 'account_entries' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(200)
      ->json_is('/account_id', $account_entry->account_id)
      ->json_is('/amount', $account_entry->amount)
      ->json_is('/description', $account_entry->description)
      ->json_like('/created_at', qr/^2\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d/)
      ->json_like('/modified_at', qr/^2\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d/)
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'add() tests' => sub {
    plan tests => 8;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });
    my $account_entry = {
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry description',
    };

    my $tx = $test->tx(
        $t->ua->build_tx(POST => '/api/account/entries/' => json => $account_entry), {
            auth => {
                permissions => { 'account_entries' => ['create'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(201)
      ->json_is('/account_id', $account->id)
      ->json_is('/amount', sprintf('%.2f', $account_entry->{amount}))
      ->json_is('/description', $account_entry->{description})
      ->json_like('/created_at', qr/^2\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d/)
      ->json_like('/modified_at', qr/^2\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d/)
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 11;

    $schema->txn_begin;

    my $admin;
    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });
    my $account_entry = {
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry description',
    };

    $account_entry = $schema->resultset('AccountEntry')->create($account_entry);
    $account_entry = { $schema->resultset('AccountEntry')->find($account_entry->id)->get_columns };

    $account_entry->{description} = 'test entry description edited';

    my $account_entry_id = delete $account_entry->{id};
    delete $account_entry->{created_at};
    delete $account_entry->{modified_at};

    my $tx = $test->tx(
        $t->ua->build_tx(PUT => '/api/account/entries/-1' => json => $account_entry), {
            auth => {
                permissions => { 'account_entries' => ['update'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(PUT => "/api/account/entries/$account_entry_id" => json => $account_entry), {
            auth => {
                permissions => { 'users' => ['update'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(200)
      ->json_is('/account_id', $account->id)
      ->json_is('/amount', $account_entry->{amount})
      ->json_is('/description', $account_entry->{description})
      ->json_like('/created_at', qr/^2\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d/)
      ->json_like('/modified_at', qr/^2\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d/)
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
    my $account_entry = {
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry description',
    };

    $account_entry = $schema->resultset('AccountEntry')->create($account_entry);
    $account_entry = { $schema->resultset('AccountEntry')->find($account_entry->id)->get_columns };

    my $tx = $test->tx(
        $t->ua->build_tx(DELETE => '/api/account/entries/-1'), {
            auth => {
                permissions => { 'account_entries' => ['delete'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(DELETE => '/api/account/entries/' . $account_entry->{id}), {
            auth => {
                permissions => { 'account_entries' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(204)
      ->content_is('', 'Empty response body');

    $schema->txn_rollback;
};

done_testing();
