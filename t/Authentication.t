#!/usr/bin/perl

use strict;
use warnings;

use Test::Mojo;
use Test::More;

use Digest::SHA qw(hmac_sha256_hex);
use Time::Local;

my $t = Test::Mojo->new('Hypernova::Dimensions');
my $schema = $t->app->schema;

use_ok('Hypernova::Dimensions::Authentication');

subtest 'API key tests' => sub {
    plan tests => 8;

    $schema->txn_begin;

    my $authentication = 'Hypernova::Dimensions::Authentication';
    ok($authentication->can('api_key_authentication'), 'Method found');

    subtest 'test missing parameters' => sub {
        plan tests => 8;

        eval{$authentication->api_key_authentication($schema)};
        is(ref($@),
            'Hypernova::Dimensions::Exception::Authentication::MissingParameter',
            'Exception thrown on missing parameters'
        );
        is($@->parameter, 'api_key', 'Missing api_key');

        eval{$authentication->api_key_authentication($schema, {
            api_key => 'test',
        })};
        is(ref($@),
            'Hypernova::Dimensions::Exception::Authentication::MissingParameter',
            'Exception thrown on missing parameters'
        );
        is($@->parameter, 'api_signature', 'Missing api_signature');

        eval{$authentication->api_key_authentication($schema, {
            api_key => 'test',
            api_signature => 'test',
        })};
        is(ref($@),
            'Hypernova::Dimensions::Exception::Authentication::MissingParameter',
            'Exception thrown on missing parameters'
        );
        is($@->parameter, 'nonce', 'Missing nonce');

        eval{$authentication->api_key_authentication($schema, {
            api_key => 'test',
            api_signature => 'test',
            nonce => 'test',
        })};
        is(ref($@),
            'Hypernova::Dimensions::Exception::Authentication::MissingParameter',
            'Exception thrown on missing parameters'
        );
        is($@->parameter, 'timestamp', 'Missing timestamp');
    };

    is($authentication->api_key_authentication($schema, {
        api_key => 'test',
        api_signature => 'test',
        nonce => 'test',
        timestamp => 123,
    }), 0, 'Returns false when API key not found');

    my $user = $schema->resultset('User')->create({
        username => 'Lari',
    });

    my $api_key = $schema->resultset('ApiKey')->create({
        api_key => 'key',
        api_secret => 'secret',
        user_id => $user->id,
    });

    my $api_signature = hmac_sha256_hex(
        $api_key->api_key,
        $api_key->api_secret.'test'.time()
    );

    my $success_key = $authentication->api_key_authentication($schema, {
        api_key => 'key',
        api_signature => $api_signature,
        nonce => 'test',
        timestamp => time(),
    });

    is(ref($success_key), ref($api_key), 'Returns api key on correct signature');
    is($success_key->api_key, $api_key->api_key, 'Correct key');

    is($authentication->api_key_authentication($schema, {
        api_key => 'key',
        api_signature => $api_signature,
        nonce => 'test',
        timestamp => time(),
    }), 0, 'Returns false when reusing same headers');

    $api_signature = hmac_sha256_hex(
        $api_key->api_key,
        $api_key->api_secret.'test'.time()
    );

    is($authentication->api_key_authentication($schema, {
        api_key => 'key',
        api_signature => 'secret',
        nonce => 'test',
        timestamp => time(),
    }), 0, 'Returns false on wrong signature');

    $api_signature = hmac_sha256_hex(
        $api_key->api_key,
        $api_key->api_secret.'test'.(time()-20*60)
    );

    is($authentication->api_key_authentication($schema, {
        api_key => 'key',
        api_signature => $api_signature,
        nonce => 'test',
        timestamp => (time()-20*60),
    }), 0, 'Returns false when too old timestamp');

    $schema->txn_rollback;
};

done_testing();
