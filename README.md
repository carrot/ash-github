# Ash-Github

Ash-Github is an [Ash](https://github.com/ash-shell/ash) module that contains collection of utility scripts that help automate using Github.

Currently there's only support for bulk creating labels from config files, but this repository is generically named in hopes that it will be expanded upon in the future.

## Getting Started

#### Install

You're going to have to install [Ash](https://github.com/ash-shell/ash) to use this module.

After you have Ash installed, run either one of these two commands depending on your git clone preference:

- `ash apm:install git@github.com:carrot/ash-github.git --global`
- `ash apm:install https://github.com/carrot/ash-github.git --global`

#### Config

Inside of your [~/.ashrc](https://github.com/ash-shell/ash#the-ashrc-file) file, you'll need to add a Github token with permissions to your repositories you want to work with:

```bash
export GITHUB_TOKEN="YOUR_GITHUB_TOKEN_HERE"
```

## Labels

#### Labels Config File

The labels command will load in a label config file into a Github repo.

All label configs are located at `extras/label_configs` in this repo.

You can add your own custom label configs in that directory for your own use.

If you work with a team and have a consistent label config, it might make sense to fork this repo and add your own label config files.  If you're convinced you have a really good label config, feel free to create a PR for it.

Label config files are very simple, and follow the following format, with one label per line:

```
label_name:hex_color
```

An example file would look something like this:

```
blocked:000000
bug:fc2929
```

#### Deleting Labels

Sometimes you might want to delete some labels (likely Github's default labels) in the process of setting up a repo with your label config.

You can add in the your label config file a line with `-delete:tag-name` to go and delete a specific label.

For example:

```
-delete:wontfix
```

#### Importing other Label Configs

You may run into a case where you have a base label config, but you may have some slight differences between project types.

This case is handled, and you may use the `-import:label-config-file-name`.

For example, our iOS team and Android team use a majority of the same labels, but we have custom platform specific tags.  Here is what our Android config file looks like:

```
# Carrots Mobile
-import:carrots-mobile

# issue platform
android-4.0:a6c427
android-4.1:a6c427
android-4.4:a6c427
android-5.0:a6c427
android-6.0:a6c427
small-screens:a6c427
large-screens:a6c427
```

You will find `-import:carrots-mobile` at the top of our iOS config too.

You're absolutely allowed to import multiple config files, but just be sure to watch out for circular references, as this library doesn't handle that case (and your script will run forever).

#### Comments

Bash style comments are supported in Label Config files, so anything after `#` is ignored.

#### Using the Command

After you have a labels config file you're happy with, using this command is very straight forward.

If I were using the carrots-web label config I would run on the command line:

```bash
ash github:labels carrots-web
```

I would then be prompted to input the repository, and if it were for this repo, I would input:

```
carrot/ash-github
```

After entering this information in, your repository will be populated with the labels as defined in the labels config file.

To list out all the labels you currently have run:

```bash
ash github:labels list
```

## License

[MIT](LICENSE.txt)
