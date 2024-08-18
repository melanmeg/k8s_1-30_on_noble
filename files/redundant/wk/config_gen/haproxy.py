
# Environment
WK_IP_1 = '192.168.11.124'
WK_IP_2 = '192.168.11.125'
WK_IP_3 = '192.168.11.126'

lists = {
    # id           # service                # IP               # port   # nodeport
    'service99': [ 'test-service',          '192.168.11.199',  '3000',  '30099' ],
}

# config gen haproxy
from jinja2 import Template


def generate_script(template_path, output_path, **kwargs):
    with open(template_path, 'r') as file:
        template_content = file.read()

    template = Template(template_content)

    rendered_script = template.render(**kwargs)

    with open(output_path, 'w') as output_file:
        output_file.write(rendered_script)

generate_script('../haproxy/template.cfg', '../haproxy/haproxy.cfg', lists=lists, WK_IP_1=WK_IP_1, WK_IP_2=WK_IP_2, WK_IP_3=WK_IP_3)
