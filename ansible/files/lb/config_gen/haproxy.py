# service  # IP  # port  # nodeport
lists = {
    ( 'argocd', '192.168.11.161', '443', '30001' ),
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

generate_script('./haproxy_template.cfg.j2', '../haproxy.cfg.j2', lists=lists)
