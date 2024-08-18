
# Environment
WK_IP_1 = '192.168.11.124'
WK_IP_3 = '192.168.11.125'

lists = {
    # id           # LB_ID  # vrId  # IP
    'service83': [ '99',    '99',   '192.168.11.199' ],
}

# config gen keepalived
from jinja2 import Template


def generate_script(template_path, output_path, **kwargs):
    with open(template_path, 'r') as file:
        template_content = file.read()

    template = Template(template_content)

    rendered_script = template.render(**kwargs)

    with open(output_path, 'w') as output_file:
        output_file.write(rendered_script)

generate_script('../keepalived/template.conf', '../keepalived/keepalived_master.conf', lists=lists, WK_IP_1=WK_IP_1, WK_IP_3=WK_IP_3, state='MASTER', priority='101')
generate_script('../keepalived/template.conf', '../keepalived/keepalived_backup.conf', lists=lists, WK_IP_1=WK_IP_1, WK_IP_3=WK_IP_3, state='BACKUP', priority='102')