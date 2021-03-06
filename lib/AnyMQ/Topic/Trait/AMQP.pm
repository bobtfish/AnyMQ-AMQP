package AnyMQ::Topic::Trait::AMQP;
use Moose::Role;

sub BUILD {}; after 'BUILD' => sub {
    my $self = shift;
    $self->bus->_rf_channel->bind_queue(
        queue       => $self->bus->_rf_queue,
        routing_key => $self->name,
        on_success  => $self->bus->cv,
    );
};

before publish => sub {
    my ($self, @events) = @_;
    $self->bus->_rf_channel->publish(
        exchange    => $self->bus->exchange,
        routing_key => $self->name,
        header      => { reply_to => $self->bus->_rf_queue },
        body => JSON::to_json($_)
    ) for @events;
};

sub DEMOLISH {}; after 'DEMOLISH' => sub {
    my $self = shift;
    $self->bus->_rf_channel->unbind_queue(
        queue       => $self->bus->_rf_queue,
        routing_key => $self->name,
        on_success  => $self->bus->cv,
    );
};

1;
