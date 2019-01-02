import click

@click.command()
@click.argument('foo')
@click.argument('thename')
@click.option('--config', '-c', help = "Path to config")
def main(foo, thename, config):
    """
    Just a silly Python app
    """
    print(f'config: {config}')
    my_function(foo)
    my_function(thename)

def my_function(x):
    print(f'text from my_function :: {x}')

if __name__ == '__main__':
    main()
