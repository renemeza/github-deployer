# github-deployer

CLI utility tool to create a Github deployment, it sends a deployment event to the specified repository

## Usage

``` bash
# Create a deployment in octocat/example repo for the develop branch and staging environemt
github-deployer --owner octocat --repo example --ref develop --env stag

```

## Options

`-h`, `--help`
> Show the help message

`-o`, `--owner`
> The repository owner

`-r`, `--repo`
> The target repository

`-e`, `--env`
> Name for the target deployment environment. Defaults to `dev` environment

`-f`, `--ref`
> The ref to deploy. This can be a branch, tag or SHA. Defaults to `master` branch

`-t`, `--token`
> The Github authentication token, if not provided the token will be taken from `GITHUB_TOKEN` env variable

`-p`, `--payload`
> The payload json object to send to the deployment webhook

`--task`
> The task to execute. Defaults to `deploy`

## Installation

Install with npm

* `npm install github-deployer`

## License

This software is available under the following licenses:

* MIT
* Apache 2
