package WordList::Tables;

# AUTHORITY
# DATE
# DIST
# VERSION

use parent qw(WordList);

our $DYNAMIC = 1;

our %PARAMS = (
    table => {
        summary => 'Tables::* module name without the prefix, e.g. Locale::US::States '.
            'for Tables::Locale::US::States',
        schema => 'perl::modname*',
        req => 1,
        completion => sub {
            my %args = @_;
            require Complete::Module;
            Complete::Module::complete_module(
                word => $args{word},
                ns_prefix => 'Tables',
            );
        },
    },
    column => {
        summary => 'Column name to retrieve from the table',
        schema => 'str*',
        req => 1,
    },
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my $mod = "Tables::$self->{params}{table}";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;
    $self->{_table} = $mod->new;
    my $columns = $self->{_table}->get_column_names;
    my $found;
    for my $i (0..$#{ $columns }) {
        if ($self->{params}{column} =~ /\A[0-9]+\z/ && $self->{params}{column} == $i ||
                $self->{params}{column} eq $columns->[$i]) {
            $self->{_colidx} = $i;
            $found++;
            last;
        }
    }
    die "Unknown column '$self->{params}{column}' in table module $mod, ".
        "available columns are: ".join(", ", @$columns) unless $found;
    $self;
}

sub next_word {
    my $self = shift;
    my $row = $self->{_table}->get_word_arrayref;
    return unless $row;
    $row->[ $self->{_colidx} ];
}

sub reset_iterator {
    my $self = shift;
    $self->{_table}->reset_iterator;
}

1;
# ABSTRACT: Wordlist from a column of table from Tables::* module

=head1 SYNOPSIS

 use WordList::Tables;

 my $wl = WordList::Tables->new(table => 'Locale::US::States', column => 'name');
 say $wl->first_word; # Alaska


=head1 DESCRIPTION

This is a dynamic, parameterized wordlist to get list of words from a
column of table from Tables::* module.


=head1 SEE ALSO

L<Tables> and C<Tables::*> modules

L<WordList>
