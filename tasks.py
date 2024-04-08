import dataclasses

import boto3
import prettytable
from invoke import Context, Exit, task


@dataclasses.dataclass
class Secret:
    name: str
    value: str
    description: str = ""
    tags: dict[str, str] = dataclasses.field(default_factory=dict)

    @classmethod
    def from_response(cls, response):
        tags = {tag['Key']: tag['Value'] for tag in response["Tags"]}
        return cls(response["Name"], response.get("SecretString", "***"), response["Description"], tags)

    @property
    def tags_str(self):
        return "\n".join([f"{key} = {value}" for key, value in self.tags.items()])

    @property
    def tags_list(self):
        return [{"Key": key, "Value": value} for key, value in self.tags.items()]

    def to_row(self):
        return [self.name, self.value, self.description, self.tags_str]


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
    secrets = []
    for page in client.get_paginator('list_secrets').paginate():
        for raw_secret in page["SecretList"]:
            secrets.append(Secret.from_response(raw_secret))
    print_secrets(secrets, show_value=False)


@task
def get_secret(c: Context, secret_name, aws_profile="ocs-test"):
    session = boto3.session.Session(profile_name=aws_profile)
    client = session.client('secretsmanager')
    secret = _get_secret(aws_profile, secret_name, client)
    print_secrets([secret])


def _get_secret(aws_profile, secret_name, client):
    try:
        response = client.get_secret_value(SecretId=secret_name)
    except client.exceptions.ResourceNotFoundException:
        raise Exit(f"Secret '{secret_name}' not found", -1)

    meta_response = client.describe_secret(SecretId=secret_name)
    return Secret.from_response({**response, **meta_response})


@task(help={"tags": "Comma separated key=value pairs", "remove_tags": "Comma separated keys"})
def set_secret(c: Context, secret_name, secret_value, description=None, tags=None, remove_tags=None, aws_profile="ocs-test"):
    """
    Create or update a secret value, description and tags
    """
    session = boto3.session.Session(profile_name=aws_profile)
    client = session.client('secretsmanager')
    if tags:
        tags = {parts[0]: parts[1] for tag in tags.split(",") if (parts := tag.split("="))}
    new_secret = Secret(secret_name, secret_value, description, tags or {})
    try:
        secret = _get_secret(aws_profile, secret_name, client)
    except Exit:
        secret = None

    if not secret:
        client.create_secret(
            Name=secret_name, SecretString=secret_value, Description=description or None, Tags=tags or None
        )
    else:
        if description:
            client.update_secret(SecretId=secret_name, SecretString=secret_value, Description=description)
        else:
            client.put_secret_value(SecretId=secret_name, SecretString=secret_value)

        if tags:
            if new_secret.tags_list:
                client.tag_resource(SecretId=secret_name, Tags=new_secret.tags_list)

            if remove_tags:
                remove_tags = remove_tags.split(",")
                client.untag_resource(SecretId=secret_name, TagKeys=remove_tags)

    get_secret(c, secret_name, aws_profile)


@task(help={"force": "Force delete without recovery"})
def delete_secret(c: Context, secret_name, force=False, aws_profile="ocs-test"):
    session = boto3.session.Session(profile_name=aws_profile)
    client = session.client('secretsmanager')
    try:
        response = client.delete_secret(SecretId=secret_name, ForceDeleteWithoutRecovery=force)
    except client.exceptions.ResourceNotFoundException:
        raise Exit(f"Secret '{secret_name}' not found", -1)

    deletion_date = response["DeletionDate"].strftime("%Y-%m-%d %H:%M:%S")
    print(f"Secret '{secret_name}' scheduled for deletion at {deletion_date}")


def print_secrets(secrets, show_value=True):
    rows = [secret.to_row() for secret in secrets]
    fields = ["Name", "Value", "Description", "Tags"]
    table = prettytable.PrettyTable(field_names=fields, align="l", max_width=50, hrules=prettytable.ALL)
    table.add_rows(rows)
    if not show_value:
        table.del_column("Value")
    print(table)
