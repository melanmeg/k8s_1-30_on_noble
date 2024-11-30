# ip
lists = [
    '192.168.11.161',
]

# config gen keepalived
from jinja2 import Template


def generate_script(template_path, output_path, **kwargs):
    with open(template_path, 'r') as file:
        template_content = file.read()
    template = Template(template_content)
    rendered_script = template.render(**kwargs)
    with open(output_path, 'w') as output_file:
        output_file.write(rendered_script)

generate_script('./keepalived_template.conf', '../keepalived_k8s-lb-1.conf.j2', lists=lists, state='MASTER', priority='101')
generate_script('./keepalived_template.conf', '../keepalived_k8s-lb-2.conf.j2', lists=lists, state='BACKUP', priority='99')
