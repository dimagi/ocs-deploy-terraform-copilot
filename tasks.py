import boto3
from invoke import Context, Exit, task
from prettytable import PrettyTable


@task
def requirements(c: Context, upgrade_all=False, upgrade_package=None):
    if upgrade_all and upgrade_package:
        raise Exit("Cannot specify both upgrade and upgrade-package", -1)
    args = " -U" if upgrade_all else ""
    cmd_base = "pip-compile --resolver=backtracking"
    env = {"CUSTOM_COMPILE_COMMAND": "inv requirements"}
    if upgrade_package:
        cmd_base += f" --upgrade-package {upgrade_package}"
    c.run(f"{cmd_base} requirements.in{args}", env=env)


@task
def list_secrets(c: Context, aws_profile="ocs-test"):
    session = boto3.session.Session(profile_name=aws_profile)
    client = session.client('secretsmanager')
    rows = []
    for page in client.get_paginator('list_secrets').paginate():
        for secret in page["SecretList"]:
            rows.append([secret["Name"], secret["Description"]])
    print_table(["Name", "Description"], rows)


@task
def get_secret(c: Context, secret_name, aws_profile="ocs-test"):
    session = boto3.session.Session(profile_name=aws_profile)
    client = session.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    print_table(["Name", "Value"], [[response["Name"], response["SecretString"]]])


@task
def set_secret(c: Context, secret_name, secret_value, description="", tags="", aws_profile="ocs-test"):
    # TODO: update secret if it already exists
    session = boto3.session.Session(profile_name=aws_profile)
    client = session.client('secretsmanager')
    if tags:
        tags = [{"Key": key, "Value": value} for tag in tags.split(",") for key, value in tag.split(":")]
    client.create_secret(
        Name=secret_name, SecretString=secret_value, Description=description or None, tags=tags or None
    )


def print_table(fields, rows):
    table = PrettyTable()
    table.align = "l"
    table.field_names = fields
    table.add_rows(rows)
    print(table)
