import os
import sys
from jinja2 import Environment, FileSystemLoader

# Capture our current directory
THIS_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_DIR = os.path.join(THIS_DIR, 'templates')


def compile_and_save_to_file(_file):
    j2_env = Environment(loader=FileSystemLoader(TEMPLATE_DIR),
                         trim_blocks=True)
    print "Compiling cloudformation template"
    output = j2_env.get_template('cf-master.jinja2.json').render()
    print "Saving output to file: " + _file
    with open(_file, 'w') as f:
        f.write(output)


if __name__ == '__main__':

    if len(sys.argv) < 2:
        raise Exception("No destination provided. Usage: " + sys.argv[0] + " <template_destination>")

    destination_file = sys.argv[1]
    compile_and_save_to_file(destination_file)
