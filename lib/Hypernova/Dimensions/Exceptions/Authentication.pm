package Hypernova::Dimensions::Exceptions::Authentication;

use Hypernova::Dimensions::Exception;

use Exception::Class (

    'Hypernova::Dimensions::Exception::Authentication::MissingParameter' => {
        isa    => 'Hypernova::Dimensions::Exception',
        fields => [ 'parameter' ],
    },
);

1;
